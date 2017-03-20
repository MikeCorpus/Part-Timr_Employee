//
//  HirerHandler.swift
//  Part-Timr for Employee
//
//  Created by Michael V. Corpus on 02/03/2017.
//  Copyright © 2017 Michael V. Corpus. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol PartTimrController: class {
    func acceptPartTimr(lat: Double, long: Double)
    func hirerCanceledParttimr()
    func parttimrCanceledRequest()
    func updateHirersLocation(lat: Double, long: Double)
    
}

class HireHandler {
    
    private static let _instance = HireHandler()
    
    weak var delegate: PartTimrController?
    
    var hirer = ""
    var parttimr = ""
    var parttimr_id = ""
    
    static var Instance: HireHandler {
        return _instance
    }
    
    func observeMessagesForParttimr() {
        // hirer requested a Part-Timr
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        // inform the parttimr VC
                        
                        self.delegate?.acceptPartTimr(lat: latitude, long: longitude)
                        
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.hirer = name
                    
                }
            }
            //hirer CANCELLED
            
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved, with: { (snapshot: FIRDataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.hirer {
                            
                            self.hirer = ""
                            self.delegate?.hirerCanceledParttimr()
                            
                            
                        }
                    }
                }
                
            })
        }
        
        // parttimr UPDATING LOCATION
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childChanged) { (snapshot:FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateHirersLocation(lat: lat, long: long);
                    }
                }
            }
            
            
        }
        
        // PARTTIMR ACCEPTS parttimr
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.parttimr {
                        self.parttimr_id = snapshot.key;
                    }
                }
            }
            
        }
        
        // PARTTIMR CANCELED
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.parttimr {
                        self.delegate?.parttimrCanceledRequest();
                    }
                }
            }
            
        }
        
        
    } //Observe messages for parttimr
    
    func parttimrAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: parttimr, Constants.LATITUDE: lat, Constants.LONGITUDE: long]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelRequestForParttimr() {
        DBProvider.Instance.requestAcceptedRef.child(parttimr_id).removeValue()
    }
    
    func updateParttimrLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedRef.child(parttimr_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
}











