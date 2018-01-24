//
//  UberHandler.swift
//  RiderApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
    
    func requestUber(latitude: Double, longitude: Double){
        let data: Dictionary<String, Any> = [Constants.NAME : rider, Constants.LATITUDE : latitude, Constants.LONGITUDE : longitude]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }
    
    func cancelUber(){
        DBProvider.Instance.requestRef.child(rider_id).removeValue()
    }
    
    func updateRiderLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(rider_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
}




































