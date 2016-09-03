//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // We will create an MKPointAnnotation for each dictionary in "locations". The
    // point annotations will be stored in this array, and then provided to the map view.
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure map functionalities
        mapView.pitchEnabled = false
        
        // set UI Navigation Item
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.logout))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: nil)
        let pinButton = UIBarButtonItem(image: UIImage(named: "PinIcon"), style: .Plain, target: self, action: nil)
        self.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        
        OTMClient.sharedInstance().GETtingStudentLocations() { (results, errorString) in
            if results != nil {

                for dictionary in results! {
                    
                    var latValue = dictionary[Constants.OTMResponseKeys.Latitude] as? Double
                    if latValue == nil  {latValue = 0}
                    let lat = CLLocationDegrees(latValue!)
                    
                    var longValue = dictionary[Constants.OTMResponseKeys.Longitude] as? Double
                    if longValue == nil  {longValue = 0}
                    let long = CLLocationDegrees(longValue!)
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    var first = dictionary[Constants.OTMResponseKeys.FirstName] as? String
                    if first == nil {first = ""}
                    
                    var last = dictionary[Constants.OTMResponseKeys.LastName] as? String
                    if last == nil {last = ""}
                    
                    var mediaURL = dictionary[Constants.OTMResponseKeys.MediaURL] as? String
                    if mediaURL == nil {mediaURL = ""}

                    
                    performUIUpdatesOnMain {
                    
                        // Here we create the annotation and set its coordiate, title, and subtitle properties
                        let annotation = MKPointAnnotation()
                        annotation.coordinate = coordinate
                        annotation.title = "\(first) \(last)"
                        annotation.subtitle = mediaURL
                        
                        // Finally we place the annotation in an array of annotations.
                        self.annotations.append(annotation)
                        
                        // When the array is complete, we add the annotations to the map.
                        self.mapView.addAnnotations(self.annotations)
                    }
                }
                
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
        print ("logout")
    }
}