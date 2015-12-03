//
//  ViewController.swift
//  WatchGRT
//
//  Created by M J on 25/11/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet private weak var recordingFileNameTextField: UITextField!
    
    private let session = WCSession.defaultSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        session.delegate = self
        session.activateSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func newRecording() {
        session.sendMessage(["command": "new_recording", "filename": recordingFileNameTextField.text!],
            replyHandler: { (reply) -> Void in
                print(reply)
            }) { (error) -> Void in
                print(error)
        }
    }

    @IBAction func recordSample() {
        session.sendMessage(["command": "trigger_record", "filename": recordingFileNameTextField.text!],
            replyHandler: { (reply) -> Void in
                print(reply)
            }) { (error) -> Void in
                print(error)
        }
    }
}

