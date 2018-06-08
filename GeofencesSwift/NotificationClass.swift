//
//  Notification.swift
//  GeofencesSwift
//
//  Created by Laura Mira Torres on 7/6/18.
//  Copyright © 2018 altran. All rights reserved.
//

import Foundation
import UserNotifications

@objc public class NotificationClass: NSObject, UNUserNotificationCenterDelegate{
    
    var timeToRemember: Double = 5
    internal func permissionNotification() {

        let center = UNUserNotificationCenter.current()
        center.delegate = self as? UNUserNotificationCenterDelegate
        center.requestAuthorization(options: [.alert, .sound ]) { (accepted, error) in
            if !accepted {
                print("Permiso denegado")
            }
        }

    }

    internal func executeActions(respuesta: String) {
        if respuesta == "rememberAction" {
            timeToRemember = 6
            createNotification()
        }else if respuesta == "deleteAction" {
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["category"])
        }
    }
    
    
    internal func createNotification () {
        

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeToRemember, repeats: false) //condiciones
        
        let content = UNMutableNotificationContent()
        content.title = "Hay una campaña activa"
        content.body = "Esta es la descripcion o cuerpo de la campaña"
        content.subtitle = "Este es el subtítulo"
        content.sound = UNNotificationSound.default()
        
        //Acciones
        let rememberAction = UNNotificationAction(identifier: "rememberAction", title: "Recordar más tarde", options: [])
        let deleteAction = UNNotificationAction(identifier: "deleteAction", title: "Eliminar ntificación", options: [])
        let category = UNNotificationCategory(identifier:"category", actions:[rememberAction, deleteAction], intentIdentifiers:[], options:[])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "category"
        
        //Añadir imagen
        if let path = Bundle.main.path(forResource: "sonicw", ofType: "gif"){
            let url = URL(fileURLWithPath: path)
            
            do{
                let attachment = try UNNotificationAttachment(identifier: "sonicw", url: url, options: nil)
                content.attachments = [attachment]
            }catch{
                print("La imagen no se ha cargado")
            }
            
        }
        
        let request = UNNotificationRequest(identifier: "NotificacionCampaña", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("No se ha podido mostrar la notificacion: \(error)")
            }
        }
    }
}
