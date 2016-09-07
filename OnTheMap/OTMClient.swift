//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

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
    var objectID: String?


    
    // MARK: Initializers
    override init() {
        super.init()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

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
            
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))

            
            self.students = Student.studentsFromResults(results)
            
            completionHandlerForGETStudentLocations(result: results, errorString: nil)
            
        }
        
        task.resume()
    }
    
    func GETtingAStudentLocation(completionHandlerForGETtingAStudentLocation: (studentExist: Bool, errorString: String?) -> Void) {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(11111983)%22%7D"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error
                return
            }
//            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let results = parsedResult["results"] as? NSArray else {
                completionHandlerForGETtingAStudentLocation(studentExist: false, errorString: nil)
                print("cannot find key value result in parsedResult")
                return
            }
            
            guard let objectID = results.firstObject?["objectId"] as? String else {
                completionHandlerForGETtingAStudentLocation(studentExist: false, errorString: nil)
                print("cannot find key value ObjectId in results")
                return
            }
            
            completionHandlerForGETtingAStudentLocation(studentExist: true, errorString: nil)

            
            self.objectID = objectID
        }
        task.resume()
    }
    
    func POSTingAStudentLocation(mapString: String, latitude: Double, longitude: Double, mediaURL: String, completionHandlerForPOSTingAStudentLocation: (result: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"11111983\", \"firstName\": \"Stanley\", \"lastName\": \"Darmawan\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
//            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let objectID = parsedResult["objectId"] as? String else {
                print("Could not find the key objectID in parsedResult")
                return
            }
            
            self.objectID = objectID
            
            
        }
        task.resume()
        
    }
    
    func PUTtingAStudentLocation(mapString: String, latitude: Double, longitude: Double, mediaURL: String, completionHandlerForPUTtingAStudentLocation: (result: Bool, errorString: String?) -> Void) {
        
        print(objectID)
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(objectID!)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"11111983\", \"firstName\": \"Stanley\", \"lastName\": \"Darmawan\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            
            completionHandlerForPUTtingAStudentLocation(result: true, errorString: nil)
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func DELETEingSession(completionHandlerForDELSession: (result: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            completionHandlerForDELSession(result: true, errorString: nil)

            self.appDelegate.sessionID = nil

        }
        task.resume()
    }
    
    // MARK: Debug Area
    func DELETEingAUser(tempObjectID: String ,completionHandlerForDELSession: (result: Bool, errorString: String?) -> Void) {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(tempObjectID)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
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
