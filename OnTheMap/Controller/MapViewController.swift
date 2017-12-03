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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    @objc func refreshPins() {
        print("refreshPins function")
    }

    func initNavigationBar() {
        self.navigationItem.title = "Map"
        // Is there a way to do Buttons in Swift without target/action? to get rid of @objc anno at function?
        let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_pin") , style: .plain, target: self, action: #selector(addPin))
        self.navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_refresh") , style: .plain, target: self, action: #selector(refreshPins))
        self.navigationItem.rightBarButtonItem = rightButton
    }

}

