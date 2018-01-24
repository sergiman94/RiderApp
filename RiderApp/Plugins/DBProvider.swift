//
//  DBProvider.swift
//  RiderApp
//
//  Created by Sergio Manrique on 1/22/18.
//  Copyright © 2018 smm. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider{
    
    private static let _instance = DBProvider()
    
    static var Instance : DBProvider {
        return _instance
    }
    
    // referencia de la DB
    var dbRef : DatabaseReference {
        return Database.database().reference()
    }
    
    var ridersRef : DatabaseReference {
        return dbRef.child(Constants.RIDERS)
    }
    
    var requestRef: DatabaseReference {
        return dbRef.child(Constants.UBER_REQUEST)
    }
    
    var requestAcceptedRef: DatabaseReference {
        return dbRef.child(Constants.UBER_ACCEPTED)
    }
    
    // RequestAccepted
    
    func saveUser (withID: String, email: String, password: String){
        
        let data: Dictionary<String, Any> = [Constants.EMAIL : email, Constants.PASSWORD : password, Constants.isRider: true]

        ridersRef.child(withID).child(Constants.DATA).setValue(data)
        
    }
    
}
