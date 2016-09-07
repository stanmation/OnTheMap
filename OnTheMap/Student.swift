//
//  Student.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 2/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import MapKit


struct Student {
    
    let firstName: String
    let lastName: String
    let mediaUrl: String
    let lat: Double
    let long: Double

    
    init(dictionary: [String: AnyObject]) {
        
        var first = dictionary[Constants.OTMResponseKeys.FirstName] as? String
        if first == nil {first = ""}
        firstName = first!

        var last = dictionary[Constants.OTMResponseKeys.LastName] as? String
        if last == nil {last = ""}
        lastName = last!
        
        var mediaURLRaw = dictionary[Constants.OTMResponseKeys.MediaURL] as? String
        if mediaURLRaw == nil {mediaURLRaw = ""}
        mediaUrl = mediaURLRaw!
        
        var latValue = dictionary[Constants.OTMResponseKeys.Latitude] as? Double
        if latValue == nil  {latValue = 0}
        lat = CLLocationDegrees(latValue!)
        
        var longValue = dictionary[Constants.OTMResponseKeys.Longitude] as? Double
        if longValue == nil  {longValue = 0}
        long = CLLocationDegrees(longValue!)
        
    }
    
    static func studentsFromResults(results: [[String: AnyObject]]) -> [Student] {
        var students = [Student]()
        
        // iterate through array of dictionaries, each Student is a dictionary
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        return students
    }


}


