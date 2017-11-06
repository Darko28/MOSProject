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
    var connectedProduct: DJIBaseProduct? = nil
    var sentCmds: NSMutableDictionary?
    
    public override init() {
        super.init()
        self.sentCmds = NSMutableDictionary()
        self.appDelegate = UIApplication.shared.delegate as? AppDelegate
        self.registerWithProduct()
    }
    
    public func registerWithProduct() {
        let registrationID = "4fbb7e69c745a7ac8635380c"
        self.appDelegate?.model?.addLog(newLogEntry: "Registering Product with ID: \(registrationID)")
        DJISDKManager.registerApp(with: self)
    }
    
    // MARK: -- OnBoardSDK Communication
    public func commandIDStringKeyFromData(data: NSData) -> String {
        var cmdId: UInt16 = 1
        data.getBytes(&cmdId, length: UInt16.bitWidth)
        let key = String(format: "%d", cmdId)
        print(key)
        self.appDelegate?.model?.addLog(newLogEntry: key)
        return key
    }
    
    public typealias MOSAckBlock = (NSData, NSError?) -> Void
    
    public func sendData(data: NSData, with completion: @escaping () -> Void, and ackBlock: @escaping MOSAckBlock) {
        
        print("MOS send data")
        self.appDelegate?.model?.addLog(newLogEntry: "MOS send data")
        
        let fc: DJIFlightController? = (self.connectedProduct as? DJIAircraft)?.flightController
        fc?.delegate = self
        
        if fc == nil {
            self.appDelegate?.model?.addLog(newLogEntry: "fc is nil")
        } else {
            fc!.sendData(toOnboardSDKDevice: data as Data, withCompletion: { [weak self] (error) in
                print("send data to onboard device")
                self!.appDelegate?.model?.addLog(newLogEntry: "send data to onboard device")
                if error != nil {
                    self!.appDelegate?.model?.addLog(newLogEntry: "send data error")
                } else {
                    self!.appDelegate?.model?.addLog(newLogEntry: "sending data")
                    print("Sending data")
                    
                    
                    let key = self!.commandIDStringKeyFromData(data: data)
                    self?.appDelegate?.model?.addLog(newLogEntry: "onboard key: \(key)")
                    self!.sentCmds!.setObject(ackBlock, forKey: key as NSCopying)
                }
//                completion()
//                ackBlock(data, error as NSError?)
                }
            )
        }
    }
    
    
    // MARK: -- DJIFlightControllerDelegate
    public func flightController(_ fc: DJIFlightController, didReceiveDataFromOnboardSDKDevice data: Data) {
        print("flightController receiving data")
        self.appDelegate?.model?.addLog(newLogEntry: "flightController receiving data")
        let key = self.commandIDStringKeyFromData(data: data as NSData)
        let ackBlock: MOSAckBlock? = self.sentCmds!.object(forKey: key) as? MOSProductCommunicationManager.MOSAckBlock
        
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
//        if error != nil {
//            self.appDelegate?.model?.addLog(newLogEntry: "Error registering App: \(error!)")
//        } else {
//            DJISDKManager.enableBridgeMode(withBridgeAppIP: "192.168.1.101")
//            DJISDKManager.startConnectionToProduct()
//            self.appDelegate?.model?.addLog(newLogEntry: "MOS Registration succeeded")
//        }
    }
//
//    public func productConnected(_ product: DJIBaseProduct?) {
//        if product != nil {
//            self.connectedProduct = product
//            let flightController = (DJISDKManager.product() as? DJIAircraft)?.flightController
//            flightController?.delegate = self
//            self.appDelegate?.model?.addLog(newLogEntry: "product is connected")
//            DJISDKManager.userAccountManager().logIntoDJIUserAccount(withAuthorizationRequired: false) { (state, error) in
//                if error != nil {
//                    self.appDelegate?.model?.addLog(newLogEntry: "Login failed")
//                    print("Login failed")
//                }
//            }
//        } else {
//            self.appDelegate?.model?.addLog(newLogEntry: "product is nil")
//        }
//    }
//
}
