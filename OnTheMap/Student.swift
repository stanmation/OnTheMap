//
//  Student.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 2/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit


struct Student {
    
    let firstName: String
    let lastName: String
    let mediaUrl: String
    
    init(dictionary: [String: AnyObject]) {
        
        var first = dictionary[Constants.OTMResponseKeys.FirstName] as? String
        if first == nil {first = ""}
        firstName = first!

        var last = dictionary[Constants.OTMResponseKeys.FirstName] as? String
        if last == nil {last = ""}
        lastName = last!
        
        var mediaURLRaw = dictionary[Constants.OTMResponseKeys.MediaURL] as? String
        if mediaURLRaw == nil {mediaURLRaw = ""}
        mediaUrl = mediaURLRaw!
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


