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
import HealthKit

class PredictInterfaceController: WKInterfaceController, WCSessionDelegate, HKWorkoutSessionDelegate {
    @IBOutlet private var currentFileLabel: WKInterfaceLabel!
    @IBOutlet private var predictedClassLabel: WKInterfaceLabel!
    @IBOutlet private var sampleLabel: WKInterfaceLabel!
    @IBOutlet private var statusLabel: WKInterfaceLabel!
    
    private let accelerometerManager = AccelerometerManager()
    private let pipeline = GestureRecognitionPipeline()
    private var sampleCounter = 0
    private var isRunning = false
    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession!
    
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
        let vector = VectorDouble()
        
        sampleCounter = 0
        accelerometerManager.start { (x, y, z) -> Void in
            vector.clear()
            vector.pushBack(x)
            vector.pushBack(y)
            vector.pushBack(z)
            let result = self.pipeline.predict(vector)
            if self.pipeline.predictedClassLabel != currentClassLabel {
                currentClassLabel = self.pipeline.predictedClassLabel
                self.predictedClassLabel.setText("\(result):\(currentClassLabel)")
                WKInterfaceDevice.currentDevice().playHaptic(.Success)
            }
            if (self.sampleCounter % 30) == 0 {
                self.sampleLabel.setText("\(self.sampleCounter)")
            }
            self.sampleCounter++
        }
        isRunning = true
        
        session = HKWorkoutSession(activityType: .Running, locationType: .Indoor)
        session.delegate = self
        healthStore.startWorkoutSession(session)
    }
    
    private func stopPrediction() {
        accelerometerManager.stop()
        isRunning = false
        
        healthStore.endWorkoutSession(session)
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
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        statusLabel.setText("WS: \(toState)")
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        statusLabel.setText(error.localizedDescription)
    }
}