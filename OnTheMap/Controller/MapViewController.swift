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
       
        setNavBar(title: "Map")
        addRefreshPinObserver()
        
        refreshPins()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshAnnotaions), name: NSNotification.Name(rawValue: "dataUpdated"), object: nil)
        
    }

    @IBAction func unwindToMainMenu(sender: UIStoryboardSegue)
    {
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
    
  
    
}

