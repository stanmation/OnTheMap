//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

// this line tells the Playground to execute indefinitely
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let request = NSMutableURLRequest(URL: NSURL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
let session = NSURLSession.sharedSession()
let task = session.dataTaskWithRequest(request) { data, response, error in
    if error != nil { // Handle error...
        return
    }
    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
}
task.resume()
