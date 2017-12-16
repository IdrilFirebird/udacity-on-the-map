//
//  ViewControllerExtension.swift
//  OnTheMap
//
//  Created by Sebastian on 16.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func addRefreshPinObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPins), name: NSNotification.Name(rawValue: "refreshStudenData"), object: nil)
    }

    @objc func refreshPins() {
        
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
    func setNavBar(title:String) {
        self.navigationItem.title = title
        // Is there a way to do Buttons in Swift without target/action? to get rid of @objc anno at function?
        let rightButton = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_addpin") , style: .plain, target: self, action: #selector(addPin))
        self.navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(title: "Logout" , style: .plain, target: self, action: #selector(logout))
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc func addPin() {
        confirmAlert(alertMessage: "You have already a pin set, do you want to change it?", alertTitle: "Pin already set!", actionButtonLabel: "Change Pin") { (action) in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "setPinViewModal") as! LocationSearchController
//            controller.mapViewController = self
            controller.modalPresentationStyle = .overFullScreen
            self.present(controller, animated: true, completion: nil)
        }
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
    
    func confirmAlert(alertMessage: String, alertTitle: String, actionButtonLabel: String, confirmActionHandler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (handler: UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        })
        
        alertController.addAction(UIAlertAction(title: actionButtonLabel, style: .default, handler: confirmActionHandler))
        
        present(alertController, animated: true, completion: nil)
        
    }

}
