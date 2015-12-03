//
//  InterfaceController.swift
//  WatchGRT WatchKit Extension
//
//  Created by M J on 25/11/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet private var currentFileLabel: WKInterfaceLabel!
    @IBOutlet private var currentRecordSampleLabel: WKInterfaceLabel!
    @IBOutlet private var recordingLabel: WKInterfaceLabel!
    
    private let accelerometerManager = AccelerometerManager()
    private var currentFilePath: String!
    private var currentFileHandle: NSFileHandle!
    private var sampleCounter = 0
    private var isRecording = false

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
        
    }
    
    private func startRecording() {
        WKInterfaceDevice.currentDevice().playHaptic(.Start)
        currentRecordSampleLabel.setText("\(sampleCounter)")
        recordingLabel.setText("Recording: YES")
        accelerometerManager.start({ (x, y, z) -> Void in
            self.currentFileHandle.writeData("\(self.sampleCounter); \(x); \(y); \(z)".dataUsingEncoding(NSUTF8StringEncoding)!)
        })
    }
    
    private func stopRecording() {
        WKInterfaceDevice.currentDevice().playHaptic(.Stop)
        recordingLabel.setText("Recording: NO")
        accelerometerManager.stop()
        sampleCounter++
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        guard let command = message["command"] as? String else {
            print("Not command specified")
            return
        }
        
        switch command {
        case "new_recording":
            let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileUrl = documentsUrl.URLByAppendingPathComponent("/\(message["filename"]).csv")
            currentFilePath = fileUrl.path!
            
            let header = "sample; x; y; z";
            NSFileManager.defaultManager().createFileAtPath(fileUrl.path!, contents: header.dataUsingEncoding(NSUTF8StringEncoding)!, attributes: nil)
            
            currentFileHandle = NSFileHandle(forWritingAtPath: currentFilePath)
            currentFileHandle.seekToEndOfFile()
            sampleCounter = 0
            
            currentFileLabel.setText(message["filename"] as? String)
            currentRecordSampleLabel.setText("\(sampleCounter)")
            
            replyHandler(["status": "ok"])

        case "trigger_record":
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
            
            isRecording = !isRecording
            
            replyHandler(["status": "ok", "isRecording": isRecording])
            
        case "send_file":
            currentFileHandle.closeFile()
            session.sendMessageData(NSFileManager.defaultManager().contentsAtPath(currentFilePath)!, replyHandler: nil, errorHandler: nil)
            
        default:
            print("unknown command")
        }
    }

}
