//
//  UberHandler.swift
//  RiderApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//
/*
 Clase que gestiona los cambios en la base de datos para asi determinar
 el funcionamiento y flujo de trabajo de la aplicacion como tal, en si
 acá esta la conexion con la otra aplicacion(rider).
*/

import Foundation
import FirebaseDatabase

// protocolo para intercambio de datos entre ViewControllers
protocol UberController: class {
    func canCallUber(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
    func updateDriversLocation(lat: Double, long: Double)
}

class UberHandler{
    
    private static let _instance = UberHandler()
    static var Instance : UberHandler{
        return _instance
    }
    weak var delegate : UberController?
    
    var rider = ""
    var driver = ""
    var rider_id = ""
    
    
    
    func observeMessagesForRider(){
        
        // RIDER REQUESTED UBER
        // Observa cuando el rider ha enviado la solicitud, cuando esta instancia esta en la bd pasa lo sgte:
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot : DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.rider_id = snapshot.key
                        self.delegate?.canCallUber(delegateCalled: true)
                    }
                }
            }
        }
        
        // RIDER CANCELLED UBER
        // Observa cuando el rider ha cancelado la solicitud
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved) { (snapshot : DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.rider {
                        self.delegate?.canCallUber(delegateCalled: false)
                    }
                }
            }
        }
        
        // DRIVER ACCEPTED REQUEST
        // Observa cuando el uber ha aceptado una solicitud, cuando se crea una instancia en la bd
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
//                    if self.driver == ""{
//
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: self.driver)
//
//                    }
                }
            }
        }
        
        // DRIVER CANCELED REQUEST
        // Observa cuando el driver ha cancelado la solicitud, cuando se ha creado una instancia en la bd
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
        }
        
        // DRIVER UPDATING LOCATION
        // observa cuando el driver ha actualizado su ubicacion en la base de datos en un intervalo de tiempo
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.driver {
                        if let latitude = data[Constants.LATITUDE] as? Double {
                            if let longitude = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateDriversLocation(lat: latitude, long: longitude)
                            }
                        }
                    }
                }
            }
        }
        
        
    }
    
    // funcion que ejecuta una solicitud a la base de datos
    func requestUber(latitude: Double, longitude: Double){
        let data: Dictionary<String, Any> = [Constants.NAME : rider, Constants.LATITUDE : latitude, Constants.LONGITUDE : longitude]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    // funcion que ejecuta la cancelacion de una solicitud, es decir, la elimina de la base de datos
    func cancelUber(){
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    
    // funcion que actualiza la ubicacion del rider, enviando su ubicacion durante un intervalo de tiemoo a la base de datos
    func updateRiderLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
}




































