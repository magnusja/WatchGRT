//
//  PredictViewController.swift
//  WatchGRT
//
//  Created by M J on 09/12/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class PredictInterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var currentFileLabel: WKInterfaceLabel!
    @IBOutlet var predictedClassLabel: WKInterfaceLabel!
    
    
    @IBAction func start() {
    }
}