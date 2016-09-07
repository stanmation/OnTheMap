//
//  NavigationBar.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 3/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

class NavigationBar: NSObject {
    
    override init() {
        super.init()
    }
    
    func setupButtons (view: UIViewController, nav: UINavigationItem) {

        nav.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: view, action: #selector(logout))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: view, action: #selector(refresh))
        let pinButton = UIBarButtonItem(image: UIImage(named: "PinIcon"), style: .Plain, target: view, action: #selector(pinTapped))
        nav.rightBarButtonItems = [refreshButton, pinButton]
        
    }
    
    func logout() {
        print("test")
    }
    
    func refresh() {
        
    }
    
    func pinTapped() {
        
    }

    
}
