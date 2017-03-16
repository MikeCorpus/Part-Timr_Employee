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
        
    } //Observe messages for employee
    
    func parttimrAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.LATITUDE: lat, Constants.LONGTITUDE: long]
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data)
    }
    
}











