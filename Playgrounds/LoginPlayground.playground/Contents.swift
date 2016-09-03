//: Playground - noun: a place where people can play

import UIKit
import XCPlayground

// this line tells the Playground to execute indefinitely
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
request.HTTPMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
request.HTTPBody = "{\"udacity\": {\"username\": \"stanmation@gmail.com\", \"password\": \"Simba1981\"}}".dataUsingEncoding(NSUTF8StringEncoding)
let session = NSURLSession.sharedSession()
let task = session.dataTaskWithRequest(request) { data, response, error in
    if error != nil { // Handle error…
        return
    }
    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
    print(NSString(data: newData, encoding: NSUTF8StringEncoding))
}
task.resume()