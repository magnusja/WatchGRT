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
    @IBOutlet var sampleLabel: WKInterfaceLabel!
    
    private let accelerometerManager = AccelerometerManager()
    private let pipeline = GestureRecognitionPipeline()
    private var sampleCounter = 0
    private var isRunning = false
    
    private func startPrediction() {
        sampleCounter = 0
        isRunning = true
        accelerometerManager.start { (x, y, z) -> Void in
            let vector = VectorDouble()
            vector.pushBack(x)
            vector.pushBack(y)
            vector.pushBack(z)
            self.pipeline.predict(vector)
            self.predictedClassLabel.setText("\(self.pipeline.predictedClassLabel)")
            self.sampleLabel.setText("\(self.sampleCounter++)")
        }
    }
    
    private func stopPrediction() {
        isRunning = false
        accelerometerManager.stop()
    }
    
    @IBAction func start() {
        if isRunning {
            stopPrediction()
        } else {
            startPrediction()
        }
    }
}