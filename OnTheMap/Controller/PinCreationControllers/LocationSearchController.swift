//
//  LocationSearchController.swift
//  OnTheMap
//
//  Created by Sebastian on 02.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit
import CoreLocation

class LocationSearchController: UIViewController {

    var locationString: String = ""
    var location: CLLocation?
    
    @IBOutlet weak var locationStringTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func searchLocation(_ sender: Any) {
        guard let locationString = locationStringTextField.text, locationString != "" else {
            showErrorAlert(viewController: self, message: "You have to enter your location first")
            return
        }
        
        
        
        // Overlay loading indicator
        // SHOW
        // TODO: implement loading overlay
        
        CLGeocoder().geocodeAddressString(locationString) { (placemark, error) in
            // Overlay loading indicator
            // HIDE
            // TODO: implement loading overlay
            
            guard error == nil else {
                showErrorAlert(viewController: self, message: "Could not find your location")
                return
            }
            
            self.locationString = placemark!.first!.name!
            self.location = placemark!.first!.location!
            
            
            let controller: AddLinkController
            controller = self.storyboard?.instantiateViewController(withIdentifier: "enterLinkView") as! AddLinkController
            controller.modalPresentationStyle = .overFullScreen
            controller.location = self.location
            controller.locationString = self.locationString
            
            
            
            self.present(controller, animated: true, completion: nil)
        }

        
        
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
