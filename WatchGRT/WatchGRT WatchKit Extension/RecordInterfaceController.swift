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

class RecordInterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet private var currentFileLabel: WKInterfaceLabel!
    @IBOutlet private var sampleCounterLabel: WKInterfaceLabel!
    @IBOutlet private var currentRecordSampleLabel: WKInterfaceLabel!
    @IBOutlet private var recordingLabel: WKInterfaceLabel!
    
    private let accelerometerManager = AccelerometerManager()
    private var currentFilePath: String!
    private var currentFileHandle: NSFileHandle?
    private var recordCounter = 0
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
        currentRecordSampleLabel.setText("\(recordCounter)")
        recordingLabel.setText("Recording: YES")
        accelerometerManager.start({ (x, y, z) -> Void in
            self.sampleCounter++
            self.sampleCounterLabel.setText("\(self.sampleCounter)")
            self.currentFileHandle?.writeData("\(self.recordCounter); \(x); \(y); \(z)\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        })
        sampleCounter = 0
        sampleCounterLabel.setText("\(self.sampleCounter)")
    }
    
    private func stopRecording() {
        WKInterfaceDevice.currentDevice().playHaptic(.Stop)
        recordingLabel.setText("Recording: NO")
        accelerometerManager.stop()
        
        // wait a second to accelerometer actually has stopped
        let delta = Int64(UInt64(1) * NSEC_PER_SEC)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue()) {
            self.recordCounter++
            self.sampleCounter = 0
            self.sampleCounterLabel.setText("\(self.sampleCounter)")
        }
        
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
            
            let header = "record; x; y; z\n"
            NSFileManager.defaultManager().createFileAtPath(fileUrl.path!, contents: header.dataUsingEncoding(NSUTF8StringEncoding)!, attributes: nil)
            
            currentFileHandle = NSFileHandle(forWritingAtPath: currentFilePath)
            currentFileHandle?.seekToEndOfFile()
            recordCounter = 0
            
            currentFileLabel.setText(message["filename"] as? String)
            currentRecordSampleLabel.setText("\(recordCounter)")
            sampleCounter = 0
            sampleCounterLabel.setText("\(self.sampleCounter)")
            
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
            currentFileHandle?.closeFile()
            
            guard let fileName = message["filename"] as? String else {
                currentFileLabel.setText("No file name given!")
                return
            }
            
            let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let fileUrl = documentsUrl.URLByAppendingPathComponent("/\(fileName).csv")
            
            session.transferFile(fileUrl, metadata: nil)
            
        default:
            print("unknown command")
        }
    }

}
