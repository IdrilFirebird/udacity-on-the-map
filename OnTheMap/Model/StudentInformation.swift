//
//  StudentInformation.swift
//  OnTheMap
//
//  Created by Sebastian on 02.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import Foundation
import CoreLocation

struct StudentInformation {
    var firstName: String
    var lastName: String
    var location: CLLocation
    var mapString: String
    var link: URL?
    var objectId: String
    var uniqueKey: String
    
    // init StudentInfo
    init(dictionary: [String : AnyObject]) {
        firstName = dictionary["firstName"] as! String!
        lastName = dictionary["lastName"] as! String!
        let longitude = dictionary["longitude"] as! Double
        let latitude = dictionary["latitude"] as! Double
        location = CLLocation(latitude: latitude, longitude: longitude)
        mapString = dictionary["mapString"] as! String
        link = URL(string: dictionary["mediaURL"] as! String!)
        objectId = dictionary["objectId"] as! String!
        uniqueKey = dictionary["uniqueKey"] as! String!
    }
    
    init(firstName: String, lastName: String, location: CLLocation, link: URL?, locationString: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.location = location
        self.link = link
        self.mapString = locationString
        self.objectId = ""
        self.uniqueKey = ""
    }
}
