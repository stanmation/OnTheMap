//
//  GCDBlackBox.swift
//  OnTheMap
//
//  Created by Stanley Darmawan on 26/08/2016.
//  Copyright © 2016 Stanley Darmawan. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}