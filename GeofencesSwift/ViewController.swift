//
//  ViewController.swift
//  GeofencesSwift
//
//  Created by usuario on 8/5/18.
//  Copyright © 2018 altran. All rights reserved.
//
import UIKit
import CoreLocation
import MapKit
import UserNotifications
import SQLite3

class ViewController: UIViewController, UNUserNotificationCenterDelegate, MKMapViewDelegate {
    
    var hamBtnSwitch = false
    var buttonEnabled = true
    var auxFunctions = Metods()
    var DBFunctions = dataBase()
    var locationManager : CLLocationManager?
    var notifyFunctions = NotificationClass()
    
    @IBOutlet weak var geofencesLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var coordTextField: UITextField!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var stackMenu: UIStackView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var mapTrailing: NSLayoutConstraint!
    @IBOutlet weak var mapLeading: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UNUserNotificationCenter.current().delegate = self
        notifyFunctions.createNotification()
        // creamos BD
        DBFunctions.createDB()
        // Inicializa Location Manager y establece los primeros parametros
        auxFunctions.initLocManager()
        // recargamos la base de datos
        auxFunctions.reloadGeoFencesDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.delegate = self
        mapView.showsUserLocation = true
        //regionsCache = auxFunctions.initGeoFencesExamples()
        imagen.loadGif(name: "sonicw")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func hamburgerBtn(_ sender: Any) {
        if !hamBtnSwitch {
            mapLeading.constant = 180
            mapTrailing.constant = 0
            print("moviendo a")
            hamBtnSwitch = true
        }else{
            mapLeading.constant = 0
            mapTrailing.constant = 0
            print("moviendo b")
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }) {(animationComplete) in print("animacion")}
            hamBtnSwitch = false
        }
    }
    
    //Boton para activar/desactivar geofences
    @IBAction func toggleGeofences(_ sender: UIButton) {
        buttonEnabled = auxFunctions.switchGeoFences(buttonEnabled: buttonEnabled, geofencesLabel: geofencesLabel, mapView: mapView, imagen: imagen)
    }
    
    @IBAction func addGeoByDB(_ sender: UIButton) {
        auxFunctions.addGeoByDB(mapView: mapView, geofencesLabel: geofencesLabel)
    }
    
    @IBAction func deleteDBAndRefresh(_ sender: UIButton) {
        auxFunctions.deleteDBAndRefresh(mapView: mapView)
        geofencesLabel.text = "Base de datos borrada"
    }
    
    //Boton para agregar geofences desde TextField de manera manual con XX.XXXXX,-XX.XXXXX sin espacios
    @IBAction func addGeoByText (_ sender: UIButton){
        if coordTextField.text == ""{
            print("TF vacio")
        }else{
            auxFunctions.addGeoByText(coordTextField: coordTextField.text!)
            self.geofencesLabel.text = "Zona añadida"
        }
        
    }
    
    // Dibujado de las Geofences en el MapView
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = auxFunctions.regionColor()
        return circleRenderer
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        withCompletionHandler([.alert, .sound])
    }
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let respuesta = response.actionIdentifier
        notifyFunctions.executeActions(respuesta: respuesta)
    }
}

