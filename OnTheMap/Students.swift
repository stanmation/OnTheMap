//
//  Students.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 15/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

class Students {
    
    var allStudents: [Student] = [Student]()
    
    class func sharedInstance() -> Students {
        struct Singleton {
            static var sharedInstance = Students()
        }
        return Singleton.sharedInstance
    }
    
}

