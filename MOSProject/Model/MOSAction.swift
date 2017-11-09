//
//  MOSAction.swift
//  MOSProject
//
//  Created by Darko on 2017/10/18.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation

public class MOSAction: NSObject {
    
    var key: String? = "N/A"
    var label: String? = "N/A"
    var information: String? = ""
    var cmdID: NSNumber? = -1
    var acks: Bool? = false
    var sensorData: Double? = 0.0
    
    public override init() {
        super.init()
        self.key = "N/A"
        self.label = "N/A"
        self.information = ""
        self.cmdID = -1;
        self.acks = false
        self.sensorData = 0.1
    }
    
    public init(jsonDictionary: NSDictionary) {
        
        let jsonKey = jsonDictionary.object(forKey: "key") as? String
        if let _ = jsonKey {
            self.key = jsonKey
        }
        
        let jsonCommandLabel = jsonDictionary.object(forKey: "label") as? String
        if jsonCommandLabel != nil {
            self.label = jsonCommandLabel
        }
        
        let jsonCommandInfo = jsonDictionary.object(forKey: "info") as? String
        self.information = jsonCommandInfo
        
        let jsonCmdID = jsonDictionary.object(forKey: "cmd_id") as? String
//        self.cmdID = jsonCmdID as! NSNumber
        if jsonCmdID != nil {
            var result: UInt64 = 0
            let scanner: Scanner = Scanner(string: jsonCmdID!)
            scanner.scanLocation = 2    // bypass '0x' character
            scanner.scanHexInt64(&result)
            self.cmdID = NSNumber(value: result)
        }
        
        let jsonAck = jsonDictionary.object(forKey: "ack") as? Bool
        self.acks = jsonAck
        
//        let jsonSensorData = jsonDictionary.object(forKey: "sensorData") as? Double
//        self.sensorData = jsonSensorData
    }
    
}
