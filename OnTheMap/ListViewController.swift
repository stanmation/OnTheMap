//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 27/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit
import FBSDKLoginKit


class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDelegate: AppDelegate!
    var studentExist = false

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        // set navigationBar
        NavigationBar().setupButtons(self, nav: self.navigationItem)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
        
        OTMClient.sharedInstance().GETtingAStudentLocation { (studentExist, errorString) in
            if studentExist == true {
                self.studentExist = true
            } else {
                self.studentExist = false
            }
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.sharedApplication().canOpenURL(url)
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "ListTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as UITableViewCell!
        
        if Students.sharedInstance().allStudents.count != 0 {
            // setup "locations" array
            let student = Students.sharedInstance().allStudents[indexPath.row]
            let first = student.firstName
            let last = student.lastName
            
            /* Set cell defaults */
            cell.textLabel!.text = "\(first) \(last)"
            cell.imageView!.image = UIImage(named: "PinIcon")
            cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if Students.sharedInstance().allStudents.count != 0 {
            return Students.sharedInstance().allStudents.count
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let student = Students.sharedInstance().allStudents[indexPath.row]
        if verifyUrl(student.mediaUrl){
            UIApplication.sharedApplication().openURL(NSURL(string: student.mediaUrl)!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func logout () {
        OTMClient.sharedInstance().DELETEingSession() { (results, errorString) in
            if results {
                performUIUpdatesOnMain {
                    self.dismissViewControllerAnimated(true, completion: {
                        let loginManager = FBSDKLoginManager()
                        loginManager.logOut() // this is an instance function
                    })
                }
            }
        }
    }
    
    func refresh() {
        OTMClient.sharedInstance().GETtingStudentLocations() { (results, errorString) in
            if errorString != nil {
                performUIUpdatesOnMain{
                    self.displayAlert(errorString!, alertType: "NoConnection")
                }
            } else  {
                
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func pinTapped(){
        if studentExist == true {
            performUIUpdatesOnMain{
                self.displayAlert("You have already posted a student location. Would you like to overwrite your current location?", alertType: "Overwrite")
            }
        } else {
            self.navigateToInformationPostingVC(false)
        }
    }
    
    func navigateToInformationPostingVC(studentExist: Bool) {
        let informationPostingViewController = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
        informationPostingViewController.studentExist = studentExist
        self.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        informationPostingViewController.modalPresentationStyle = .OverFullScreen
        presentViewController(informationPostingViewController, animated: true, completion: nil)
    }
    
    // MARK: other delegate methods
    
    func displayAlert(messageText: String, alertType: String){
        let alert = UIAlertController(title: "", message: messageText, preferredStyle: .Alert)
        
        if alertType == "Overwrite" {
            alert.addAction(UIAlertAction(title: "Overwrite?", style: .Default, handler: { (handler) in
                self.navigateToInformationPostingVC(true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        } else if alertType == "NoConnection" {
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        }
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
