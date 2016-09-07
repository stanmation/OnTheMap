//
//  MainNavigationItem.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 3/09/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import UIKit

class MainNavigationItem: UINavigationItem {
    
    
    override init(title: String) {
        super.init(title: title)
        self.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }
}
