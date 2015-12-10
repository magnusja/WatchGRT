//
//  PredictViewController.swift
//  WatchGRT
//
//  Created by M J on 09/12/15.
//  Copyright © 2015 jahnen. All rights reserved.
//

import Foundation
import UIKit
import WatchConnectivity

class PredictViewController: UIViewController, WCSessionDelegate {
    @IBOutlet private weak var urlTextField: UITextField!
    
    private let session = WCSession.defaultSession()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        session.delegate = self
        session.activateSession()
    }
    
    @IBAction func transfer() {
        let data = NSData(contentsOfURL: NSURL(string: urlTextField.text!)!)
        
        let path = NSTemporaryDirectory() + "/train.grt"
        
        NSFileManager.defaultManager().createFileAtPath(path, contents: data, attributes: nil)
        
        session.transferFile(NSURL(string: "file:///" + path)!, metadata: nil)
    }
    
    @IBAction func paste() {
        urlTextField.text = UIPasteboard.generalPasteboard().string?.stringByReplacingOccurrencesOfString("dl=0", withString: "dl=1") // Dropbox ;)
    }
    
    func session(session: WCSession, didFinishFileTransfer fileTransfer: WCSessionFileTransfer, error: NSError?) {
        print(error)
    }
}