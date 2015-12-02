//
//  CoreMotionManager.swift
//  WatchGRT
//
//  Created by M J on 02/12/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import Foundation
import CoreMotion

class AccelerometerManager {
    private let motionManager = CMMotionManager()
    private let motionQueue = NSOperationQueue()
    
    init() {
        motionQueue.name = "CoreMotion"
        
        motionManager.accelerometerUpdateInterval = 1/30.0 // 30 fps
    }
    
    func start() {
        let handler: CMDeviceMotionHandler = {(motion: CMDeviceMotion?, error: NSError?) -> Void in
            guard let acceleration = motion?.userAcceleration else {
                print("Error: motion is nil: \(error)")
                return
            }
            
            print("Motion: x: \(acceleration.x) y: \(acceleration.y) z: \(acceleration.z)")
        }
        
        if (motionManager.deviceMotionAvailable) {
            motionManager.startDeviceMotionUpdatesToQueue(motionQueue, withHandler: handler)
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}