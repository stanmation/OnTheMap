//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController, UIAlertViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var objectIDText: UITextField!
    
    var students: [Student]?

    var studentExist = false
    
    // We will create an MKPointAnnotation for each dictionary in "locations". The
    // point annotations will be stored in this array, and then provided to the map view.
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure map functionalities
        mapView.pitchEnabled = false
        
        // set navigationBar
        NavigationBar().setupButtons(self, nav: self.navigationItem)
        
        
        // refresh when first load the screen
        refresh()
    }

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        OTMClient.sharedInstance().GETtingAStudentLocation { (studentExist, errorString) in
            if studentExist == true {
                self.studentExist = true
            } else {
                self.studentExist = false
            }
        }
    }
    
    
    // MARK: - MKMapViewDelegate

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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(NSURL(string: toOpen)!)
            }
        }
    }

    func logout () {
        OTMClient.sharedInstance().DELETEingSession() { (results, errorString) in
            if results == true {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func refresh() {
        OTMClient.sharedInstance().GETtingStudentLocations() { (results, errorString) in
            if results != nil {
                
                self.students = OTMClient.sharedInstance().students

                // empty array of anontations
                self.annotations.removeAll()
                
                for student in self.students! {
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: student.lat, longitude: student.long)
    
                    
                    // Here we create the annotation and set its coordiate, title, and subtitle properties
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(student.firstName) \(student.lastName)"
                    annotation.subtitle = student.mediaUrl
                    
                    // Finally we place the annotation in an array of annotations.
                    self.annotations.append(annotation)
                }
                
                performUIUpdatesOnMain {
                    
                    // remove mapAnnotation
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    // When the array is complete, we add the annotations to the map.
                    self.mapView.addAnnotations(self.annotations)
                }
                
            }
            
        }

    }
    
    func pinTapped(){
        
        if studentExist == true {
            self.displayAlert("You have already posted a student location. Would you like to overwrite your current location?")
        } else {
            self.navigateToInformationPostingVC(false)
        }
    }
    
    func navigateToInformationPostingVC(studentExist: Bool) {
        let informationPostingViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        informationPostingViewController.studentExist = studentExist
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        informationPostingViewController.modalPresentationStyle = .OverCurrentContext
        presentViewController(informationPostingViewController, animated: true, completion: nil)
    }
    
    
    // MARK: Debug area
    
    @IBAction func deleteAUser(sender: AnyObject) {
        
        OTMClient.sharedInstance().DELETEingAUser(objectIDText.text!) { (result, errorString) in
            print("user deleted")
        }
    }
    
    // MARK: other delegate methods
    
    func displayAlert(messageText: String){
        let alert = UIAlertController(title: "", message: messageText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Overwrite?", style: .Default, handler: { (handler) in
            self.navigateToInformationPostingVC(true)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

        self.presentViewController(alert, animated: true, completion: nil)
    }
}