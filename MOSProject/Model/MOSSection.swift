//
//  MOSSection.swift
//  MOSProject
//
//  Created by Darko on 2017/10/18.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation

public class MOSSection: NSObject {
    
    var name: String?
    var actions: Array<MOSAction>?
    
    public override init() {
        super.init()
        self.name = "N/A"
        self.actions = self.actionsInJSONArray(jsonArray: Array<MOSAction>())
    }
    
    public init(sectionName: String, jsonContent: Array<Any>) {
        super.init()
        self.name = sectionName
        self.actions = self.actionsInJSONArray(jsonArray: jsonContent)
    }
    
    public func actionsInJSONArray(jsonArray: Array<Any>) -> Array<MOSAction> {
        var actions = Array<MOSAction>()
        for jsonObject in jsonArray {
            let jsonActions: NSDictionary = jsonObject as! NSDictionary
            let action: MOSAction? = MOSAction(jsonDictionary: jsonActions)
            if action != nil {
                actions.append(action!)
            }
        }
        return actions
    }
    
    
}
