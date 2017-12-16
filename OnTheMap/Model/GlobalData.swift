//
//  GlobalData.swift
//  OnTheMap
//
//  Created by Sebastian on 03.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import Foundation



class Global {
    
//    static let sharedInstance = Global()
    let loadingOverlayTag = 63463
    
    var students:[StudentInformation] = []
    var userFirstName: String = "Max"
    var userLastName: String = "Tester"
    
    var userID: String? = nil
    var sessionID: String? = nil
    
    var ownStudentInfo: StudentInformation? = nil
    
   
    class func sharedInstance() -> Global {
        struct Singleton {
            static var sharedInstance = Global()
        }
        return Singleton.sharedInstance
    }
    
    func loadStudentInfo(_ completionHandler: @escaping (Bool?, NSError?) -> Void) {
        let udacitMapApiClient = UdacityMapApiClient()
        udacitMapApiClient.getStudentsLocations() {(studentsInfo: [StudentInformation]?, error: NSError?) in
            
            guard (error == nil) else {
                completionHandler(false, error)
                return
            }
            Global.sharedInstance().students = studentsInfo!
            Global.sharedInstance().ownStudentInfo = self.findOwnMapEntry(students: studentsInfo!, userID: Global.sharedInstance().userID!)
            completionHandler(true, nil)
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "dataUpdated"), object: nil)
            }
            
        }
    }
    
    
    func findOwnMapEntry(students: [StudentInformation], userID: String) -> StudentInformation? {
        for student in students {
            if student.uniqueKey == userID {
                return student
            }
        }
        return nil
    }
    
}
