//
//  RiderVC.swift
//  RiderApp
//
//  Created by Sergio Manrique on 1/18/18.
//  Copyright © 2018 smm. All rights reserved.
//
/*
 Clase encargada de gestionar la localizacion y de recibir la solicitud del rider,
 al mismo tiempo de enviar la solicitud para cancelarla al rider
*/

import UIKit
import MapKit
import FirebaseDatabase

// recibe el protocolo UberController de la clase UberHandler
class RiderVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UberController {
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var callUberBtn: UIButton!
    
    
    private var locationManager = CLLocationManager()
    private var userLocation : CLLocationCoordinate2D?
    private var driverLocation : CLLocationCoordinate2D?
    
    private var timer = Timer()
    
    private var canCallUber = true
    private var riderCanceledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager()
        
        UberHandler.Instance.delegate = self
        UberHandler.Instance.observeMessagesForRider()
    }
    
    /* funcion encargada de de definir e inicializar el delegado del location manager, como tambien de pedir
     la autorizacion al usuario de usar su localizacion y demas requisitos necesarios para una
     buena conexion y localizacion */
    private func initializeLocationManager(){
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    /*
     Funcion encargada de conocer la localizacion del usuario u objeto y gestionar su movimiento en el mapa
     tambien de realziar las anotaciones necesarias con respecto al driver en el mapa para asi
     poder visualizarlo, demás gestiones
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // if we have the locations from the manager
        if let location = locationManager.location?.coordinate{
            
            userLocation = CLLocationCoordinate2D(latitude:location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
            
            myMap.removeAnnotations(myMap.annotations)
            
            if driverLocation != nil {
                if !canCallUber {
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver Location"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = userLocation!
            annotation.title = "Riders Location"
            myMap.addAnnotation(annotation)
            
        }
    }
    
    // funcion que actualiza la ubicacion del rider
    @objc func updateRidersLocation(){
        UberHandler.Instance.updateRiderLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    /*
     funcion que determina si se puede realizar la solicitud o si no es posible
     funcion del protocolo uberController
    */
    func canCallUber(delegateCalled: Bool) {
        if delegateCalled {
            callUberBtn.setTitle("Cancel Uber", for: UIControlState.normal)
            canCallUber = false
        } else {
            callUberBtn.setTitle("Call Uber", for: UIControlState.normal)
            canCallUber = true
        }
    }
    
    /*
     funcion que gestiona y determina si se ha aceptado o cancelado la solicitud
     funcion del protocolo uberController
    */
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        
        if !riderCanceledRequest{
            if requestAccepted {
                alertTheUser(title: "Uber Accepted", message: " \(driverName) Accepted Your Uber Request")
            } else {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
                alertTheUser(title:"Uber Canceled" , message: "\(driverName) Canceled Uber Request")
            }
        }

        riderCanceledRequest = false
    }
    
    /*
     funciom que actualiza la ubicacion del driver en el mapa
     funcion del protocolo uberController
    */
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    /*
     Boton llamar uber
     crea una instancia en la base de datos con la solicitud al driver
     si se cancela la solicitud esta se elimina de la base de datos
    */
    @IBAction func callUberr(_ sender: Any) {
        
        if userLocation != nil {
            if canCallUber {
                UberHandler.Instance.requestUber(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(RiderVC.updateRidersLocation), userInfo: nil, repeats: true)
                
            } else {
                riderCanceledRequest = true
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
        }
        
    }
    
    /*
     Boton de cerrar sesion
     cierra la sesion del rider eliminando las solicitudes y dejando de actualizar su ubicacion
    */
    @IBAction func logOut(_ sender: Any) {
        
        if AuthProvider.Instance.logOut() {
            if !canCallUber {
                UberHandler.Instance.cancelUber()
                timer.invalidate()
            }
            
            dismiss(animated: true, completion: nil)
            
        }else{
        
            alertTheUser(title: "Could Not Logout", message: "We could not logout at the moment, please try again later")
        }
    }
    
    /*
     Funcion que contiene los distintos mensajes de alerta para mostrar al rider
    */
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
