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
            completionHandler(true, nil)
        }
    }
    
}
