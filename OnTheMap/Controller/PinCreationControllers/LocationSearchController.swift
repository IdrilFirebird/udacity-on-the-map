//
//  LocationSearchController.swift
//  OnTheMap
//
//  Created by Sebastian on 02.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit
import CoreLocation

class LocationSearchController: UIViewController, UITextFieldDelegate {

    var locationString: String = ""
    var location: CLLocation?
    
    @IBOutlet weak var locationStringTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationStringTextField.delegate = self
    }
    
    // MARK: Textfield Delegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        locationStringTextField.resignFirstResponder()
        return true
    }
    
    // MARK: Actions
    @IBAction func searchLocation(_ sender: Any) {
        guard let locationString = locationStringTextField.text, locationString != "" else {
            showErrorAlert(viewController: self, message: "You have to enter your location first")
            return
        }
        
        
        
        
        let loadingIndicatorView = showLoadingIndicator(viewController: self)
        
        CLGeocoder().geocodeAddressString(locationString) { (placemark, error) in
            
            guard error == nil else {
                showErrorAlert(viewController: self, message: "Could not find your location")
                self.view.viewWithTag(Global.sharedInstance().loadingOverlayTag)?.removeFromSuperview()
                return
            }
            
            self.locationString = placemark!.first!.name!
            self.location = placemark!.first!.location!
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "enterLinkView") as! AddLinkController
            controller.modalPresentationStyle = .overFullScreen
            controller.location = self.location
            controller.locationString = self.locationString
            
            
            self.view.viewWithTag(Global.sharedInstance().loadingOverlayTag)?.removeFromSuperview()
            self.present(controller, animated: true, completion: nil)
        }

        
        
    }

}
