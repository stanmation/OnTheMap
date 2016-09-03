//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 26/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sharedSession = NSURLSession.sharedSession()
    var sessionID: String? = nil


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }


}

// MARK: Create URL from Parameters

extension AppDelegate {
    
    func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.OTM.ApiScheme
        components.host = Constants.OTM.ApiHost
        components.path = Constants.OTM.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}
