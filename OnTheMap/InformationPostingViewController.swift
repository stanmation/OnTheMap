//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 4/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var inputTextField: UITextField!
    var studentExist = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.backgroundColor = UIColor.clearColor()
        inputTextField.delegate = self
    }

    @IBAction func findOnTheMap(sender: AnyObject) {
        
        if (inputTextField.text != "" ) || (inputTextField.text != "Enter Your Location Here") {
            self.performSegueWithIdentifier("URLPostingVC", sender: self)
            dismissViewControllerAnimated(false, completion: nil)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! URLPostingViewController
        controller.locationInfoText = inputTextField.text
        controller.studentExist = studentExist


    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: delegate methods

    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Enter Your Location Here" {
            textField.text = ""
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // dismissing the keyboard when enter key is hit
        textField.resignFirstResponder()
        
        return true
    }

    
}