//
//  URLPostingViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 5/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import MapKit


class URLPostingViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var linkText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    
    var locationInfoText: String?
    let regionRadius: CLLocationDistance = 5000
    var location: CLLocation?
    var studentExist = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        linkText.delegate = self
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // disable submit button before the location is updated
        submitButton.enabled = false

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationInfoText!) { (placemarks, error) in
            
            if error  != nil {
                performUIUpdatesOnMain {
                    self.displayAlert("Error", messageText: "Please check your keyword or network connection")
                    self.activityIndicator.alpha = 0.0
                }
                print (error)
            } else {
                let placemarksArray = placemarks! as NSArray
                let placemark = placemarksArray.lastObject as! CLPlacemark
                
                let location = CLLocation(latitude: (placemark.location?.coordinate.latitude)!, longitude: (placemark.location?.coordinate.longitude)!)

                performUIUpdatesOnMain {
                    self.centerMapOnLocation(location)
                    self.location = location
                    self.activityIndicator.alpha = 0.0
                    self.submitButton.enabled = true

                }
            }
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        self.mapView.addAnnotation(annotation)
    }
    
    
    // MARK: Action methods
    
    @IBAction func submitButtonClicked(sender: AnyObject) {
        
        if studentExist == true {
            // will update the location of your pin
            OTMClient.sharedInstance().PUTtingAStudentLocation(locationInfoText!, latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, mediaURL: linkText.text!) { (success, errorString) in
                if errorString != nil {
                    performUIUpdatesOnMain{
                        self.displayAlert("Error", messageText: errorString!)
                    }
                    return
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        } else {
            // will post your pin
            OTMClient.sharedInstance().POSTingAStudentLocation(locationInfoText!, latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, mediaURL: linkText.text!) { (result, errorString) in
                if errorString != nil {
                    performUIUpdatesOnMain{
                        self.displayAlert("Error", messageText: errorString!)
                    }
                    return
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: delegate methods
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == "Enter a Link to Share Here" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // dismissing the keyboard when enter key is hit
        textField.resignFirstResponder()
        
        return true
    }
    
    func displayAlert(messageTitle: String, messageText: String){
        let alert = UIAlertController(title: messageTitle, message: messageText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    

    
    
}