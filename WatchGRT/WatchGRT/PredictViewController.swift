//
//  PredictViewController.swift
//  WatchGRT
//
//  Created by M J on 09/12/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class PredictViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet private weak var recordingFileNameTextField: UITextField!
    
    private let session = WCSession.defaultSession()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        session.delegate = self
        session.activateSession()
    }
    
}