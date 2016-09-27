//
//  OTMClient.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class OTMClient : NSObject {
    
    var studentLocations: [[String: AnyObject]]?
    
    // shared session
    var session = NSURLSession.sharedSession()
    
    // authentication state
    var sessionID : String? = nil
    var objectID: String?

    // user data for POSTING
    var userFirstname: String?
    var userLastname: String?
    var uniqueKey: String?

    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    func authenticateWithViewController(hostViewController: LoginViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        self.POSTingASession(hostViewController.emailTextField.text!, password: hostViewController.passwordTextField.text!) {success, errorString in
            if success {
                self.GETtingPublicUserData() {(success, errorString) in
                    
                    if success {
                        
                    }
                    
                    completionHandlerForAuth(success: success, errorString: errorString)
                }

            }
            completionHandlerForAuth(success: success, errorString: errorString)
        }

    }

    
    func POSTingASession(username: String, password: String, completionHandlerForPOSTingASession: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print (error)
                if error!.code == -1009 || error!.code == -1001 {
                    completionHandlerForPOSTingASession(success: false, errorString: "Unable to connect: Please Try Again")

                } else {
                    completionHandlerForPOSTingASession(success: false, errorString: "email or password is not correct")
                }
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode  where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                completionHandlerForPOSTingASession(success: false, errorString: "email or password is not correct")
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
            
            if let session = parsedResult[Constants.OTMResponseKeys.Session] as? [String: AnyObject], let sessionID = session[Constants.OTMResponseKeys.SessionID] as? String {
                self.sessionID = sessionID
            }
            
            if let account = parsedResult[Constants.OTMResponseKeys.Account] as? [String: AnyObject], let accountKey = account[Constants.OTMResponseKeys.AccountKey] as? String {
                self.uniqueKey = accountKey

            }
            
            completionHandlerForPOSTingASession(success: true, errorString: nil)
        }
        task.resume()

    }
    
    func GETtingPublicUserData(completionHandlerForGettingPublicUserData: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.uniqueKey!)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandlerForGettingPublicUserData(success: false, errorString: "failed in getting Public User data")
                print(error)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode  where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                completionHandlerForGettingPublicUserData(success: false, errorString: "Failed in getting your data")
                return
            }
            
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let user = parsedResult["user"] as? [String: AnyObject] else {
                print ("can't find key 'results' in parsedResults")
                return
            }
            
            // getting first and last name
            if let firstname = user["first_name"] as? String, let lastname = user["last_name"] as? String {
                self.userFirstname = firstname
                self.userLastname = lastname
            } else {
                completionHandlerForGettingPublicUserData(success: false, errorString: "failed in getting Public User data")
                return
            }
            
            
            completionHandlerForGettingPublicUserData(success: true, errorString: nil)
        }
        task.resume()
    }
    
    
    func GETtingStudentLocations(completionHandlerForGETStudentLocations: (result: [[String: AnyObject]]?, errorString: String?) -> Void) {
        
        let parameters: [String: AnyObject] = [Constants.OTMParameterKeys.Limit: Constants.OTMParameterValues.Limit,
                                               Constants.OTMParameterKeys.Order: Constants.OTMParameterValues.Order]
        let request = NSMutableURLRequest(URL: otmURLFromParameters(parameters, withPathExtension: "/parse/classes/StudentLocation"))

        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                completionHandlerForGETStudentLocations(result: nil, errorString: "Failed in retrieving data, please check your network connection or the data exists")
                print(error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode  where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                completionHandlerForGETStudentLocations(result: nil, errorString: "Failed in retrieving data, please check your network connection or the data exists")
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
            
//            print(NSString(data: data!, encoding: NSUTF8StringEncoding))

            Students.sharedInstance().allStudents = Student.studentsFromResults(results)
            
            
            completionHandlerForGETStudentLocations(result: results, errorString: nil)
            
        }
        
        task.resume()
    }
    
    func GETtingAStudentLocation(completionHandlerForGETtingAStudentLocation: (studentExist: Bool, errorString: String?) -> Void) {
        
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?where=%7B%22\(Constants.OTMParameterKeys.UniqueKey)%22%3A%22\(uniqueKey!)%22%7D"
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
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode  where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
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
    

    
    func POSTingAStudentLocation(mapString: String, latitude: Double, longitude: Double, mediaURL: String, completionHandlerForPOSTingAStudentLocation: (success:
        Bool, errorString: String?) -> Void) {

        let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey!)\", \"firstName\": \"\(self.userFirstname!)\", \"lastName\": \"\(self.userLastname!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandlerForPOSTingAStudentLocation(success: false, errorString: "Failed in storing student information into the server")
                print(error)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode  where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
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
            
            completionHandlerForPOSTingAStudentLocation(success: true, errorString: nil)
            
            self.objectID = objectID
            
        }
        task.resume()
        
    }
    
    func PUTtingAStudentLocation(mapString: String, latitude: Double, longitude: Double, mediaURL: String, completionHandlerForPUTtingAStudentLocation: (success: Bool, errorString: String?) -> Void) {
                
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(objectID!)"
        let url = NSURL(string: urlString)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "PUT"
        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(uniqueKey!)\", \"firstName\": \"\(self.userFirstname!)\", \"lastName\": \"\(self.userLastname!)\",\"mapString\": \"\(mapString)\", \"mediaURL\": \"\(mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                completionHandlerForPUTtingAStudentLocation(success: false, errorString: "Failed in storing student information into the server")
                print(error)
                return
            }
            
            completionHandlerForPUTtingAStudentLocation(success: true, errorString: nil)
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

            self.sessionID = nil

        }
        task.resume()
    }
    
    func POSTingASessionWithFacebook(token: String, completionHandlerForPOSTingASessionWithFacebook: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(token);\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error...
                print(error)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
//            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode  where statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
                        
            //Parse the data
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            if let session = parsedResult[Constants.OTMResponseKeys.Session] as? [String: AnyObject], let sessionID = session[Constants.OTMResponseKeys.SessionID] as? String {
                self.sessionID = sessionID
            }
            
            if let account = parsedResult[Constants.OTMResponseKeys.Account] as? [String: AnyObject], let accountKey = account[Constants.OTMResponseKeys.AccountKey] as? String {
                self.uniqueKey = accountKey
            }
            
            completionHandlerForPOSTingASessionWithFacebook(success: true, errorString: nil)
        }
        task.resume()
    }

    
    // MARK: Debug Area
//    func DELETEingAUser(tempObjectID: String! ,completionHandlerForDELSession: (result: Bool, errorString: String?) -> Void) {
//        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(tempObjectID)"
//        let url = NSURL(string: urlString)
//        let request = NSMutableURLRequest(URL: url!)
//        request.HTTPMethod = "DELETE"
//        request.addValue(Constants.OTMParameterValues.AppKey, forHTTPHeaderField: Constants.OTMParameterKeys.AppKey)
//        request.addValue(Constants.OTMParameterValues.RestApiKey, forHTTPHeaderField: Constants.OTMParameterKeys.RestApiKey)
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(request) { data, response, error in
//            if error != nil { // Handle error…
//                return
//            }
//            print(NSString(data: data!, encoding: NSUTF8StringEncoding))
//            
//            completionHandlerForDELSession(result: true, errorString: nil)
//        }
//        task.resume()
//    }
    

    
    // MARK: Shared Instance
    
    class func sharedInstance() -> OTMClient {
        struct Singleton {
            static var sharedInstance = OTMClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: Helper methods
    
    // create a URL from parameters
    func otmURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.OTM.ApiScheme
        components.host = Constants.OTM.ApiHost
        components.path = Constants.OTM.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        print(components.URL)
        
        return components.URL!
    }
}
