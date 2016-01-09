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
    @IBOutlet private var currentFileLabel: WKInterfaceLabel!
    @IBOutlet private var predictedClassLabel: WKInterfaceLabel!
    @IBOutlet private var sampleLabel: WKInterfaceLabel!
    @IBOutlet private var statusLabel: WKInterfaceLabel!
    
    private let accelerometerManager = AccelerometerManager()
    private let pipeline = GestureRecognitionPipeline()
    private var sampleCounter = 0
    private var isRunning = false
    
    override func willActivate() {
        let session = WCSession.defaultSession()
        session.delegate = self
        session.activateSession()
    }
    
    private func startPrediction() {
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileUrl = documentsUrl.URLByAppendingPathComponent("train.grt")
        
        statusLabel.setText("Load \(pipeline.load(fileUrl.path))")
        
        
        var currentClassLabel = 0 as UInt
        var labelUpdateTime = NSDate.timeIntervalSinceReferenceDate()
        let vector = VectorDouble()
        
        sampleCounter = 0

        accelerometerManager.start { (x, y, z) -> Void in
            //let startTime = NSDate.timeIntervalSinceReferenceDate()
            vector.clear()
            vector.pushBack(x)
            vector.pushBack(y)
            vector.pushBack(z)
            let result = self.pipeline.predict(vector)
            let localClassLabel = self.pipeline.predictedClassLabel
            
            if localClassLabel != currentClassLabel {
                let currentTime = NSDate.timeIntervalSinceReferenceDate()
                let timeInterval = currentTime - labelUpdateTime
                let maximumLikelihood = self.pipeline.maximumLikelihood
                
                guard timeInterval > 0.5 else {
                    return
                }
                
                labelUpdateTime = currentTime
                currentClassLabel = localClassLabel
                self.statusLabel.setText("t:\(timeInterval)")
                self.predictedClassLabel.setText("\(result):\(currentClassLabel):\(maximumLikelihood)")
                if currentClassLabel != 0 {
                    WKInterfaceDevice.currentDevice().playHaptic(.Success)
                }
            }
            if (self.sampleCounter % 30) == 0 {
                self.sampleLabel.setText("\(self.sampleCounter)")
            }
            self.sampleCounter++
            //let endTime = NSDate.timeIntervalSinceReferenceDate()
            //self.sampleLabel.setText("\(endTime - startTime)")
        }
        isRunning = true
        
    }
    
    private func stopPrediction() {
        accelerometerManager.stop()
        isRunning = false
        
    }
    
    @IBAction func start() {
        if isRunning {
            stopPrediction()
        } else {
            startPrediction()
        }
        
        currentFileLabel.setText("\(isRunning)")
    }
    
    func session(session: WCSession, didReceiveFile file: WCSessionFile) {
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let fileUrl = documentsUrl.URLByAppendingPathComponent("train.grt")
        
        // Remove if already existing
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(fileUrl)
        
        try! NSFileManager.defaultManager().moveItemAtURL(file.fileURL, toURL: fileUrl)
        
        statusLabel.setText("Load \(pipeline.load(fileUrl.path))")
    }
}