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
    func employerCanceledParttimr()
    func parttimrCanceledRequest()
    func updateEmployersLocation(lat: Double, long: Double)
    
}

class HireHandler {
    
    private static let _instance = HireHandler()
    
    weak var delegate: PartTimrController?
    
    var employer = ""
    var employee = ""
    var employee_id = ""
    
    static var Instance: HireHandler {
        return _instance
    }
    
    func observeMessagesForEmployee() {
        // Employer requested a Part-Timr
        
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGTITUDE] as? Double {
                        // inform the employee VC
                        
                        self.delegate?.acceptPartTimr(lat: latitude, long: longitude)
                        
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.employer = name
                    
                }
            }
            //EMPLOYER CANCELLED
            
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved, with: { (snapshot: FIRDataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.employer {
                            
                            self.employer = ""
                            self.delegate?.employerCanceledParttimr()
                            
                            
                        }
                    }
                }
                
            })
        }
        
        // EMPLOYEE UPDATING LOCATION
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childChanged) { (snapshot:FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGTITUDE] as? Double {
                        self.delegate?.updateEmployersLocation(lat: lat, long: long);
                    }
                }
            }
            
            
        }
        
        // PARTTIMR ACCEPTS EMPLOYEE
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.employee {
                        self.employee_id = snapshot.key;
                    }
                }
            }
            
        }
        
        // PARTTIMR CANCELED
        
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.employee {
                        self.delegate?.parttimrCanceledRequest();
                    }
                }
            }
            
        }
        
        
    } //Observe messages for employee
    
    func parttimrAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: employee, Constants.LATITUDE: lat, Constants.LONGTITUDE: long]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
    func cancelParttimrForEmployee() {
        DBProvider.Instance.requestAcceptedRef.child(employee_id).removeValue()
    }
    
    func updateParttimrLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedRef.child(employee_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGTITUDE: long])
    }
    
}











