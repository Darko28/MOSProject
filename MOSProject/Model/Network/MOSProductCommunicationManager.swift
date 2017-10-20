//
//  MOSProductCommunicationManager.swift
//  MOSProject
//
//  Created by Darko on 2017/10/19.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation
import DJISDK


public class MOSProductCommunicationManager: NSObject, DJISDKManagerDelegate, DJIFlightControllerDelegate {
    
    var appDelegate: AppDelegate? = nil
    let connectedProduct: DJIBaseProduct? = nil
    var sentCmds: NSMutableDictionary?
    
    public override init() {
        super.init()
        self.sentCmds = NSMutableDictionary()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.registerWithProduct()
    }
    
    public func registerWithProduct() {
        let registrationID = ""
        self.appDelegate?.model?.addLog(newLogEntry: "Registering Product with ID: \(registrationID)")
        DJISDKManager.registerApp(with: self)
    }
    
    // MARK: -- OnBoardSDK Communication
    public func commandIDStringKeyFromData(data: NSData) -> String {
        var cmdId: UInt16?
        data.getBytes(&cmdId, length: cmdId!.bitWidth)
        let key = String(format: "%d", cmdId!)
        return key
    }
    
    public typealias MOSAckBlock = (NSData, NSError?) -> Void
    
    public func sendData(data: NSData, with completion: () -> Void, and ackBlock: @escaping MOSAckBlock) {
        let fc: DJIFlightController? = (self.connectedProduct! as! DJIAircraft).flightController
        fc!.delegate = self
        fc?.sendData(toOnboardSDKDevice: data as Data, withCompletion: { (error) in
            if error != nil {
                
            } else {
                let key = self.commandIDStringKeyFromData(data: data)
                self.sentCmds?.setObject(ackBlock, forKey: key as NSCopying)
            }
        })
    }
    
    
    // MARK: -- DJIFlightControllerDelegate
    public func flightController(_ fc: DJIFlightController, didReceiveDataFromOnboardSDKDevice data: Data) {
        let key = self.commandIDStringKeyFromData(data: data as NSData)
        let ackBlock: MOSAckBlock? = self.sentCmds?.object(forKey: key) as? MOSProductCommunicationManager.MOSAckBlock
        
        self.appDelegate?.model?.addLog(newLogEntry: "Received data from FC [\(data)]")
        
        if ackBlock != nil {
            ackBlock!(data as NSData, nil)
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "Received Non-ACK data [\(data)]")
        }
        
        self.sentCmds?.removeObject(forKey: key)
    }
    
    // MARK: -- DJISDKManagerDelegate
    public func appRegisteredWithError(_ error: Error?) {
        if error != nil {
            self.appDelegate?.model?.addLog(newLogEntry: "Error registering App: \(error!)")
        } else {
            self.appDelegate?.model?.addLog(newLogEntry: "Registration succeeded")
            self.appDelegate?.model?.addLog(newLogEntry: "Connecting to product")
            
            let startedResult: Bool = DJISDKManager.startConnectionToProduct()
            
            if startedResult {
                self.appDelegate?.model?.addLog(newLogEntry: "Connecting to product started successfully")
            } else {
                self.appDelegate?.model?.addLog(newLogEntry: "Connecting to product failed to start")
            }
        }
    }
        
}
