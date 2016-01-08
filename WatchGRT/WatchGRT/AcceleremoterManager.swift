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
        
        motionManager.accelerometerUpdateInterval = 1/15.0
    }
    
    func start(accHandler: (x: Double, y: Double, z: Double) -> Void) {
        let handler: CMAccelerometerHandler  = {(data: CMAccelerometerData?, error: NSError?) -> Void in
            guard let acceleration = data?.acceleration else {
                print("Error: data is nil: \(error)")
                return
            }
            
            accHandler(x: acceleration.x, y: acceleration.y, z: acceleration.z)
        }
        
        motionManager.startAccelerometerUpdatesToQueue(motionQueue, withHandler: handler)
        
    }
    
    func stop() {
        motionManager.stopAccelerometerUpdates()
    }
}