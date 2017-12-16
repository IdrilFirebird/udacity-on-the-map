//
//  AddLinkController.swift
//  OnTheMap
//
//  Created by Sebastian on 02.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit
import MapKit

class AddLinkController: UIViewController, UITextFieldDelegate {
    
    var locationString: String?
    var location: CLLocation?
//    var mapViewController: MapViewController?
    var ownStudentInfo: StudentInformation?
    
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkTextField.delegate = self
        
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

        
    }

    // MARK: Textfield Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        linkTextField.resignFirstResponder()
        return true
    }
        
    // MARK: Actions
    @IBAction func submitNewLocation(_ sender: Any) {
        
        guard let studentURL = URL(string: linkTextField.text!), UIApplication.shared.canOpenURL(studentURL) else {
            showErrorAlert(viewController: self, message: "your entered text doesn't seem to be a valid link")
            return
        }
        
        let loadingIndicatorView = showLoadingIndicator(viewController: self)
        let udacityClient = UdacityClient()
        udacityClient.getUserInfo(userId: Global.sharedInstance().userID!) { (user, error) in
            guard (error == nil) else {
                DispatchQueue.main.async {
                    showErrorAlert(viewController: self, message: "Getting User infos failed")
                    self.view.viewWithTag(Global.sharedInstance().loadingOverlayTag)?.removeFromSuperview()
                }
                return
            }
            
            self.ownStudentInfo = StudentInformation(firstName: user!["firstName"]!, lastName: user!["lastName"]!, location: self.location!, link: studentURL, locationString: self.locationString!, uniqueKey: user!["userID"]!)
            
            let udacityMapClient = UdacityMapApiClient()
            if Global.sharedInstance().ownStudentInfo == nil {
                udacityMapClient.addStudent(student: self.ownStudentInfo!, completionHander: self.updatingStudent(objectID:error:))
            } else {
                self.ownStudentInfo!.objectId = (Global.sharedInstance().ownStudentInfo?.objectId)!
                udacityMapClient.updateStudent(student: self.ownStudentInfo!, completionHander: self.updatingStudent(objectID:error:))
            }
        }
    }
    
    
    
    func updatingStudent(objectID: String?, error: NSError?) {
        guard (error == nil) else {
            DispatchQueue.main.async {
                showErrorAlert(viewController: self, message: "Updating User to Service failed, try again.")
                self.view.viewWithTag(Global.sharedInstance().loadingOverlayTag)?.removeFromSuperview()
            }
            return
        }
        
        if let objectID = objectID { ownStudentInfo!.objectId = objectID }
        Global.sharedInstance().ownStudentInfo = ownStudentInfo
        DispatchQueue.main.async {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true) { () in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshStudenData"), object: nil)
            }
        }
    }
    


}
