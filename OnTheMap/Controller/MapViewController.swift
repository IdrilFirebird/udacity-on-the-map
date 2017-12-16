//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Sebastian on 29.11.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        mapView.delegate = self
        initNavigationBar()
        refreshPins()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAnnotaions), name: NSNotification.Name(rawValue: "dataUpdated"), object: nil)
        
    }


    @objc func addPin() {
        confirmAlert(alertMessage: "You have already a pin set, do you want to change it?", alertTitle: "Pin already set!", actionButtonLabel: "Change Pin") { (action) in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "setPinViewModal") as! LocationSearchController
            controller.mapViewController = self
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
    }
    
    @objc func logout() {
        confirmAlert(alertMessage: "Do you wan't to logout?", alertTitle: "Logout", actionButtonLabel: "Logout") { (action) in
            let udacityClient = UdacityClient()
            udacityClient.destroySession() { (result, error) in
                DispatchQueue.main.async {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func refreshPins() {
        
        let loadingIndicatorView = showLoadingIndicator(viewController: self)
        Global.sharedInstance().loadStudentInfo() { (success, error) in
            DispatchQueue.main.async {
                self.view.viewWithTag(Global.sharedInstance().loadingOverlayTag)?.removeFromSuperview()
                guard error == nil else  {
                    showErrorAlert(viewController: self, message: "Fetching students data went wrong, try agian")
                    return
                }
            }
        }
    }
    
    @objc func refreshAnnotaions()  {
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        var studentPins = [MKPointAnnotation]()
        
        for student in Global.sharedInstance().students {
            let pin = MKPointAnnotation()
            pin.coordinate = student.location.coordinate
            pin.title = "\(student.firstName) \(student.lastName)"
            pin.subtitle = "\(student.link?.absoluteString ?? "")"
            
            studentPins.append(pin)
        }
        
        self.mapView.addAnnotations(studentPins)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKMarkerAnnotationView
        
        if pin == nil {
            pin = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        } else {
            pin!.annotation = annotation
        }
        
        pin!.glyphImage = #imageLiteral(resourceName: "icon_pin")
        return pin
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let url = URL(string: (view.annotation?.subtitle!)!) {
                UIApplication.shared.open(url)
            } else {
                showErrorAlert(viewController: self, message: "That's no link")
            }
        }
    }
    
    
    func initNavigationBar() {
        self.navigationItem.title = "Map"
        // Is there a way to do Buttons in Swift without target/action? to get rid of @objc anno at function?
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_addpin") , style: .plain, target: self, action: #selector(addPin))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(title: "Logout" , style: .plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    func confirmAlert(alertMessage: String, alertTitle: String, actionButtonLabel: String, confirmActionHandler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (handler: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(UIAlertAction(title: actionButtonLabel, style: .default, handler: confirmActionHandler))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    
    
}

