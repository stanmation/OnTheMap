//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDelegate: AppDelegate!
    
    var students: [Student]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        students = OTMClient.sharedInstance().students
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "ListTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        // setup "locations" array
        let student = students![indexPath.row]
        let first = student.firstName
        let last = student.lastName
        
        /* Set cell defaults */
        cell.textLabel!.text = "\(first) \(last)"
        cell.imageView!.image = UIImage(named: "PinIcon")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students!.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = students![indexPath.row]
        UIApplication.sharedApplication().openURL(NSURL(string: student.mediaUrl)!)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }

}
