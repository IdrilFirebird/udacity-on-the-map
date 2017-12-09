//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Sebastian on 09.12.17.
//  Copyright © 2017 IdrilsBlog. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

   
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func loginAction(_ sender: Any) {
        
        let username = usernameTextField.text
        let password = passwordTextField.text
        
        guard username!.isEmpty == false, password!.isEmpty == false else {
            showErrorAlert(viewController: self, message: "Username or Password empty!")
            return
        }
        
        let udacityClient = UdacityClient()
        
        udacityClient.createUserSession(username: username!, password: password!) { (result: AnyObject?, error:NSError?) in
            
            DispatchQueue.main.async {
                if let error = error {
                    showErrorAlert(viewController: self, message: error.userInfo[NSLocalizedDescriptionKey] as! String)
                    return
                }
                
                if let userID = result?["userID"] as? String, let sessionID = result?["sessionID"] as? String {
                    Global.sharedInstance().userID = userID
                    Global.sharedInstance().sessionID = sessionID
                } else {
                    showErrorAlert(viewController: self, message: "Session not found in response")
                }
                
                self.finishLoginShowApp()
            }
        }
    }
    

    
    func finishLoginShowApp()  {
        let controller = storyboard!.instantiateViewController(withIdentifier: "MainNavigationController") as! UITabBarController
        present(controller, animated: true, completion: nil)
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
