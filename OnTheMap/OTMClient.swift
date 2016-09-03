//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import Foundation

class OTMClient : NSObject {
    
    var appDelegate: AppDelegate!
    
    var students: [Student] = [Student]()
    
    var studentLocations: [[String: AnyObject]]?
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID : String? = nil
    var userID : Int? = nil

    
    // MARK: Initializers
    override init() {
        super.init()
        
    }
    
    
    func GETtingStudentLocations(completionHandlerForGETStudentLocations: (result: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation?limit=100")!)
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandlerForGETStudentLocations(result: nil, errorString: "failed GETtingStudentLocations")
                return
            }
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results = parsedResult["results"]! as? [[String: AnyObject]] else {
                print ("can't find key 'results' in parsedResults")
                return
            }
            
            self.students = Student.studentsFromResults(results)
            
            completionHandlerForGETStudentLocations(result: results, errorString: nil)
            
        }
        
        task.resume()
    }

    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
}
