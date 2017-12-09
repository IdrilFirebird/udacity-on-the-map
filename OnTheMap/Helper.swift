//
//  Helper.swift
//  OnTheMap
//
//  Created by Sebastian on 03.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit

// move somewhere else
func showErrorAlert(viewController: UIViewController, message: String, dismissButtonTitle: String = "OK") {
    let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    
    controller.addAction(UIAlertAction(title: dismissButtonTitle, style: .default) { (action: UIAlertAction!) in
        controller.dismiss(animated: true, completion: nil)
    })
    
    viewController.present(controller, animated: true, completion: nil)
}
