//
//  ViewController.swift
//  WatchGRT
//
//  Created by M J on 25/11/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import UIKit
import WatchConnectivity

class RecordViewController: UIViewController, WCSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet private weak var recordingFileNameTextField: UITextField!
    
    private let session = WCSession.defaultSession()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        session.delegate = self
        session.activateSession()
        
        recordingFileNameTextField.delegate = self
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
        session.sendMessage(["command": "trigger_record"],
            replyHandler: { (reply) -> Void in
                print(reply)
            }) { (error) -> Void in
                print(error)
        }
    }
    
    @IBAction func getFile() {
        session.sendMessage(["command": "send_file", "filename": recordingFileNameTextField.text!],
            replyHandler: { (reply) -> Void in
                print(reply)
            }) { (error) -> Void in
                print(error)
        }
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        // This has to be the .csv file
        
        print(file)
        
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileUrl = documentsUrl.URLByAppendingPathComponent("\(self.recordingFileNameTextField.text!)")
        
        // Remove if already existing
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(fileUrl)
        
        try! NSFileManager.defaultManager().moveItemAtURL(file.fileURL, toURL: fileUrl)
        
        dispatch_async(dispatch_get_main_queue(), {
            let controller = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

