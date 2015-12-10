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
        sampleCounter = 0
        accelerometerManager.start { (x, y, z) -> Void in
            let vector = VectorDouble()
            vector.pushBack(x)
            vector.pushBack(y)
            vector.pushBack(z)
            let result = self.pipeline.predict(vector)
            self.predictedClassLabel.setText("\(result):\(self.pipeline.predictedClassLabel)")
            self.sampleLabel.setText("\(self.sampleCounter++)")
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