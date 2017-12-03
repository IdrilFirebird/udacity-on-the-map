//
//  AddLinkController.swift
//  OnTheMap
//
//  Created by Sebastian on 02.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit
import MapKit

class AddLinkController: UIViewController {
    
    var locationString: String?
    var location: CLLocation?
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let location = location, let locationString = locationString else {
            print("error")
            return
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        annotation.title = locationString
        
        let region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
        mapView.regionThatFits(region)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitNewLocation(_ sender: Any) {
        
        // TODO: Check if URL is real url
        let studentURL = URL(string: linkTextField.text!)
        
        let newStudentEntry = StudentInformation(firstName: Global.sharedInstance().userFirstName, lastName: Global.sharedInstance().userLastName, location: self.location!, link: studentURL!)
        
        Global.sharedInstance().students.append(newStudentEntry)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
