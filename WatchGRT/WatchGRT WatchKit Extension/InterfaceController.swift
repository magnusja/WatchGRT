//
//  InterfaceController.swift
//  WatchGRT WatchKit Extension
//
//  Created by M J on 25/11/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let filePath = documentsPath!.stringByAppendingString("/test.txt")
        NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil)
        
        let pipeline = GestureRecognitionPipeline()
        pipeline.load(filePath);
        
        print(pipeline.predictedClassLabel)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
