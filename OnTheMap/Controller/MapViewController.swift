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
        // Do any additional setup after loading the view, typically from a nib.
        mapView.delegate = self
        initNavigationBar()
        refreshPins()
    }

//    override func viewDidAppear(_ animated: Bool) {
//        refreshAnnotaions()
//    }

    @objc func addPin() {
        let controller: UIViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "setPinViewModal") as! UIViewController
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true, completion: nil)
        print("addPin function")
    }
    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
    }
    
    @objc func logout() {
        let udacityClient = UdacityClient()
        udacityClient.destroySession() { (result, error) in
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: nil)
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
                self.refreshAnnotaions()
                
            }
        }
    }
    
    func refreshAnnotaions()  {
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
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            pin!.image = #imageLiteral(resourceName: "icon_pin")
        } else {
            pin!.annotation = annotation
        }
        
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

}

