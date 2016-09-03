//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 26/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var appDelegate: AppDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    @IBAction func loginPressed(sender: UIButton) {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            print("Username or Password Empty")
        } else {
            
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    performUIUpdatesOnMain {
                        self.displayAlert("Error", messageText: "email or password is not correct")
                    }
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    print("Your request returned a status code other than 2xx!")
                    performUIUpdatesOnMain {
                        self.displayAlert("Error", messageText: "email or password is not correct")
                    }
                    return
                }
                
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                
                //Parse the data
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
                } catch {
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                if let session = parsedResult[Constants.OTMResponseKeys.Session] as? [String: AnyObject], sessionID = session[Constants.OTMResponseKeys.SessionID] as? String {
                    self.appDelegate.sessionID = sessionID
                }
                
                self.completeLogin()
            }
            task.resume()
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
    

    

}

