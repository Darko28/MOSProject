//
//  MOSAction.swift
//  MOSProject
//
//  Created by Darko on 2017/10/18.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation

public class MOSAction: NSObject {
    
    var key: String?
    var label: String?
    var information: String?
    var cmdID: NSNumber?
    var acks: Bool?
    
    public override init() {
        super.init()
        self.key = "N/A"
        self.label = "N/A"
        self.information = ""
        self.cmdID = -1;
        self.acks = false
    }
    
    public init(jsonDictionary: NSDictionary) {
        let jsonKey = jsonDictionary.object(forKey: "key") as? String
        if let _ = jsonKey {
            self.key = jsonKey
        }
        
        let jsonCommandLabel = jsonDictionary.object(forKey: "label") as? String
        self.label = jsonCommandLabel
        
        let jsonCommandInfo = jsonDictionary.object(forKey: "info") as? String
        self.information = jsonCommandInfo
        
        let jsonCmdID = jsonDictionary.object(forKey: "json_id") as? String
        var result: UInt64 = 0
        if jsonCmdID != nil {
            let scanner: Scanner = Scanner.init(string: jsonCmdID!)
            scanner.scanLocation = 2    // bypass '0x' character
            scanner.scanHexInt64(&result)
            self.cmdID = NSNumber.init(value: result)
        }
        
        let jsonAck = jsonDictionary.object(forKey: "ack") as? Bool
        self.acks = jsonAck
    }
    
}
