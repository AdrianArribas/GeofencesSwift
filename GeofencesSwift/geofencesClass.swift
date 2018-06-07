//
//  geofencesClass.swift
//  GeofencesSwift
//
//  Created by usuario on 9/5/18.
//  Copyright © 2018 altran. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import SQLite3

@objc public class Metods: NSObject, CLLocationManagerDelegate {
    var locationManager : CLLocationManager!
    var firstTimeFill = true
    var currentLocation : CLLocationCoordinate2D?
    var regionsCache = [CLCircularRegion]()
    var closeLocations: [CLCircularRegion] = []
    var nearest : CLLocation?
    var refreshGeofences = 0
    let ControlSwichDistance = 270.0
    var onSpot = false
    var DBFunctions = dataBase()
    var coordinateList = [Coordinate]()
   
    
    internal func initLocManager(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            locationManager = appDelegate.locationManager
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.pausesLocationUpdatesAutomatically = false
        }
        //comprueba los permisos y si OK empieza a rastrear posicion
        if CLLocationManager.locationServicesEnabled(){
            locationManager?.startUpdatingLocation()
        }
    }
    
    //Localizando al usuario
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation], mapView : MKMapView, geofencesLabel : UILabel) {
        currentLocation = manager.location?.coordinate
        print("posicion del usuario= \(currentLocation!.latitude, currentLocation!.longitude)")
        refreshGeofences += 1
        if refreshGeofences == 25 {
            for CLCircularRegion in closeLocations {
                locationManager?.stopMonitoring(for: CLCircularRegion)
            }
            mapView.removeOverlays(mapView.overlays)
            closeLocations = fillArrayGeofences()
            for CLCircularRegion in closeLocations {
                locationManager?.startMonitoring(for: CLCircularRegion)
                mapView.add(MKCircle(center: CLCircularRegion.center, radius: CLCircularRegion.radius))
            }
            geofencesLabel.text = nearestRegion()
            refreshGeofences = 0
        }
        if let userLocation = locations.last{
            let ViewRegion = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 1000, 1000)
            mapView.setRegion(ViewRegion, animated: false)
        }
    }
    
    //actualiza GeoFences cada 25 refrescos de posicion
    func fillArrayGeofences() -> [CLCircularRegion] {
        if firstTimeFill == true {
            for item in regionsCache{
                let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
                let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
                let distance = itemUbication.distance(from: userUbication)
                print("distancia hasta la ubicacion = \(distance)")
                print("distancia de control en insercion inicial = \(ControlSwichDistance)")
                if (distance < ControlSwichDistance){
                    closeLocations.append(item)
                    print("añadida region inicial \(item.identifier)")
                }
            }
            firstTimeFill = false
        }
        closeLocations.removeAll()
        print("despejando closelocations")
        for item in regionsCache{
            let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
            let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let distance = itemUbication.distance(from: userUbication)
            print("distancia hasta la ubicacion en insercion = \(distance)")
            print("distancia de control = \(ControlSwichDistance)")
            if (distance < ControlSwichDistance){
                closeLocations.append(item)
                print("añadida region \(item.identifier)")
            }
        }
        print("valor de distancia de control  = \(ControlSwichDistance)")
        return closeLocations
    }
    
    func switchGeoFences(buttonEnabled : Bool, geofencesLabel : UILabel, mapView : MKMapView, imagen : UIImageView) -> Bool{
        if let locationManager = self.locationManager {
            print("posiciones monitorizadas = \(locationManager.monitoredRegions.count)")
            print("conenido de closelocations = \(closeLocations.count)")
            print("conenido de regiones = \(regionsCache.count)")
            print("boton de encendido \(buttonEnabled)")
            if(buttonEnabled == true) {
                geofencesLabel.text = "Geofences OFF"
                for CLCircularRegion in closeLocations {
                    locationManager.stopMonitoring(for: CLCircularRegion)
                }
                mapView.removeOverlays(mapView.overlays)
                imagen.stopAnimating()
                imagen.loadGif(name: "sonicw")
                print("No estamos mirando...")
                return false
            } else {
                geofencesLabel.text = "Geofences ON"
                closeLocations = fillArrayGeofences()
                for CLCircularRegion in closeLocations {
                    locationManager.startMonitoring(for: CLCircularRegion)
                    mapView.add(MKCircle(center: CLCircularRegion.center, radius: CLCircularRegion.radius))
                }
                imagen.loadGif(name:"sonic")
                imagen.startAnimating()
                print("Observando...")
                return true
            }
        } else {
            print("problema al crear las geofences")
            return false
        }
    }
    
    //recargar array desde BDD
    func reloadGeoFencesDB(){
        coordinateList.removeAll()
        coordinateList = DBFunctions.getLocalCoordinates(distControl: Double(ControlSwichDistance))
        for item in coordinateList{
            regionsCache.append(CLCircularRegion(center: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude), radius: CLLocationDistance(item.radius), identifier: "Zona Personal"))
            print("añadido a cache: \(regionsCache[0].center.latitude, regionsCache[0].center.longitude, regionsCache[0].radius)")
        }
    }
    
    func addGeoByText(coordTextField: String){
        let XY: String = coordTextField
        var XYArr = XY.split(separator: ",")
        let X : Double = Double(XYArr[0])!
        let Y : Double = Double(XYArr[1])!
        let zonaPersonal = CLCircularRegion(center: CLLocationCoordinate2D(latitude: X, longitude: Y), radius: 30, identifier: "Zona Personal")
        zonaPersonal.notifyOnExit = true
        zonaPersonal.notifyOnEntry = true
        //regionsCache.append(zonaPersonal)
        DBFunctions.insertCoordinate(name: zonaPersonal.identifier, latitude: X, longitude: Y, radius: 150)
        reloadGeoFencesDB()
    }

    func addGeoByDB(mapView : MKMapView, geofencesLabel : UILabel){
        //añadir Geo por DB
        for CLCircularRegion in closeLocations {
            locationManager?.stopMonitoring(for: CLCircularRegion)
        }
        mapView.removeOverlays(mapView.overlays)
        reloadGeoFencesDB()
        closeLocations = fillArrayGeofences()
        for CLCircularRegion in closeLocations {
            locationManager?.startMonitoring(for: CLCircularRegion)
            mapView.add(MKCircle(center: CLCircularRegion.center, radius: CLCircularRegion.radius))
        }
        geofencesLabel.text = "Base de datos recargada"
    }
    
    func distanceFN(item:CLCircularRegion, currentLocation: CLLocationCoordinate2D) {
        let distance: CLLocationDistance
        let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
        let userUbication = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        distance = itemUbication.distance(from: userUbication)
        print("distancia hasta la ubicacion en insercion = \(distance)")
    }
    
    func regionColor()-> UIColor{
        let naranja = UIColor.orange.withAlphaComponent(0.4)
        let azul = UIColor.blue.withAlphaComponent(0.4)
        let rojo = UIColor.red.withAlphaComponent(0.4)
        let verde = UIColor.green.withAlphaComponent(0.4)
        var colores = [naranja, azul, rojo, verde]
        let random = Int(arc4random_uniform(UInt32(colores.count)))
        return colores[random]
    }
    
    func nearestRegion()->(String){
        var retorno = "control de regiones"
        var distancemin = 9999999999.99
        var cont = 0
        var min = 0
        for item in closeLocations{
            let itemUbication = CLLocation(latitude: item.center.latitude, longitude: item.center.longitude)
            let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let distance = itemUbication.distance(from: userUbication)
            if distance < distancemin {
                distancemin = distance
                min = cont
            }
            cont += 1
        }
        if closeLocations.isEmpty{
            print("closelocations esta vacio")
        }else{
            nearest = CLLocation(latitude: closeLocations[min].center.latitude, longitude: closeLocations[min].center.longitude)
            let userUbication = CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
            let distance = nearest!.distance(from: userUbication)
            if onSpot == false{
                if distance < closeLocations[min].radius {
                    print("entrando en zona")
                    retorno = "has entrado en una región"
                    onSpot = true
                }
            }else{
                if distance > closeLocations[min].radius {
                    print("saliendo de zona")
                    retorno = "has salido de una región"
                    onSpot = false
                }
            }
        }
        return retorno
    }
    
    func deleteDBAndRefresh(mapView : MKMapView){
        for CLCircularRegion in closeLocations {
            locationManager?.stopMonitoring(for: CLCircularRegion)
        }
        mapView.removeOverlays(mapView.overlays)
        DBFunctions.deleteAllCoordinates()
    }
    
    
    /*/ funcion de notificacion NO FUNCIONA--------------------!!!!!
    func notify(msg : String) {
        let content = UNMutableNotificationContent()
        content.title = "notificacion de geofence"
        content.body = msg
        let request = UNNotificationRequest(identifier: "geofence", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }*/
    
    //rellenado de array de posiciones por primera vez con algunos ejemplos
   /* func initGeoFencesExamples()-> [CLCircularRegion]{
        var regionsCache = [CLCircularRegion]()
        let altran = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.445852, longitude: -3.582682), radius: 40, identifier: "Altran")
        altran.notifyOnExit = true
        altran.notifyOnEntry = true
        
        let plenilunio = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.447302, longitude: -3.587428), radius: 200, identifier: "Plenilunio")
        plenilunio.notifyOnExit = true
        plenilunio.notifyOnEntry = true
        
        let parque = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.441688, longitude: -3.578146), radius: 300, identifier: "Parque")
        parque.notifyOnExit = true
        parque.notifyOnEntry = true
        
        regionsCache.append(altran)
        regionsCache.append(plenilunio)
        regionsCache.append(parque)
        
        return regionsCache
        
    }*/
}

