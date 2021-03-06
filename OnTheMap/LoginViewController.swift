//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 26/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UIAlertViewDelegate, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //setup facebook button
        let loginButton = FBSDKLoginButton()
        loginButton.center = CGPoint(x: self.view.center.x, y: self.view.frame.height - 100)
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            print("Access token is successful")
            fetchFBProfile()
        }
    }
    
    func fetchFBProfile() {
        // for facebook authentication
        let token = FBSDKAccessToken.currentAccessToken().tokenString
        OTMClient.sharedInstance().POSTingASessionWithFacebook(token) { (success, errorString) in
            
            if (success) {
                
                OTMClient.sharedInstance().GETtingPublicUserData() {(success, errorString) in
                    
                    if success {
                        performUIUpdatesOnMain {
                            self.completeLogin()
                        }
                    }
                }

            } else {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", messageText: "Your facebook ID is not connected to your Udacity account")
                }
            }
        }
    }
    
    @IBAction func loginPressed(sender: UIButton) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            displayAlert("Can't Login", messageText: "Username or password is empty")
        } else {
            OTMClient.sharedInstance().authenticateWithViewController(self) {success, errorString in
                if success {
                    performUIUpdatesOnMain {
                        self.completeLogin()
                    }
                } else {
                    performUIUpdatesOnMain {
                        self.displayAlert("Error", messageText: errorString!)
                    }
                }
            }
        }
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
        
    }
    
    func completeLogin () {

        performUIUpdatesOnMain {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func displayAlert(messageTitle: String, messageText: String){
        let alert = UIAlertController(title: messageTitle, message: messageText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    //MARK: Facebook Delegate methods
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error != nil {
            print(error)
            return
        }
        
        if (result.declinedPermissions != nil) || (!result.isCancelled) {
            self.fetchFBProfile()
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

    }

    

}

