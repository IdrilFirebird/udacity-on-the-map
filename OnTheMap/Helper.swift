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


func showLoadingIndicator(viewController: UIViewController) -> UIView {
    let overlay = UIView(frame: UIScreen.main.bounds)
    overlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
    overlay.tag = Global.sharedInstance().loadingOverlayTag
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    loadingIndicator.center = overlay.center
    loadingIndicator.startAnimating()
    
    overlay.addSubview(loadingIndicator)

    viewController.view.addSubview(overlay)
    return overlay
}
