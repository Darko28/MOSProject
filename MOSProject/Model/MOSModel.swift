//
//  MOSModel.swift
//  MOSProject
//
//  Created by Darko on 2017/10/18.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation

public class MOSModel: NSObject {

    // MARK: -- JSON-Based UI
    var jsonSections: Array<MOSSection>? = []
    
    // MARK: -- Logs
    var logs: Array<NSDictionary>? = []
    
    
    // load the config.json file
    public func loadConfiguration() {
        
        let configFileURL: URL = Bundle.main.url(forResource: "config", withExtension: "json")!
        let configFileContent: Data = try! Data(contentsOf: configFileURL)
        let error: Error? = nil
        var jsonConfigFile: NSDictionary = NSDictionary()
        do {
        let jsonConfigFileTemp: NSDictionary = try (JSONSerialization.jsonObject(with: configFileContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary)
            jsonConfigFile = jsonConfigFileTemp
        } catch {
            //
        }

        
        if error != nil {
            NSLog("Critical config.json parsing error:\n\(error!)\n")
        } else {
            self.jsonSections!.removeAll()
            
            let allKeys: NSArray = jsonConfigFile.allKeys as NSArray
            
            for index in 0..<allKeys.count {
                let sectionName: String = allKeys.object(at: index) as! String
                let jsonContent = jsonConfigFile.object(forKey: sectionName)
                let newSection: MOSSection = MOSSection(sectionName: sectionName, jsonContent: jsonContent as! Array<Any>)
                
                self.jsonSections!.append(newSection)
            }
        }
    }
    
    public typealias MOSModelLogChangedBlock = () -> Void
    var logChangedBlock: MOSModelLogChangedBlock? = nil
    
    public func addLog(newLogEntry: String) {
        self.logs?.append(["timestamp": Date()])
        self.logs?.append(["log": newLogEntry])
        
        if self.logChangedBlock != nil  {
            print("logChangedBlock is not equal to nil\n")
            self.logChangedBlock!()
        }
    }
    
}
