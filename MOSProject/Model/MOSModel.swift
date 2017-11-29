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
    var logs: Array<Dictionary<String, Any>>? = []
    
    
    // load the config.json file
    public func loadConfiguration() {
        
        let configFileURL: URL = Bundle.main.url(forResource: "config", withExtension: "json")!
        var configFileContent: Data = Data()
        do {
            let configFileContentTmp: Data = try Data(contentsOf: configFileURL)
            configFileContent = configFileContentTmp
        } catch {
            print("URL file not exists.")
        }
        
        var jsonConfigFile: NSDictionary = NSDictionary()
        do {
            let jsonConfigFileTemp: NSDictionary = try (JSONSerialization.jsonObject(with: configFileContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary)
            jsonConfigFile = jsonConfigFileTemp
        } catch {
            NSLog("Critical config.json parsing error.\n")
        }
        
        self.jsonSections!.removeAll()
        
        let allKeys: NSArray = jsonConfigFile.allKeys as NSArray
        
        for index in 0..<allKeys.count {
            print("allKeys: \(allKeys.count)")
            
            let sectionName: String = allKeys.object(at: index) as! String
            let jsonContent = jsonConfigFile.object(forKey: sectionName)
            let newSection: MOSSection = MOSSection(sectionName: sectionName, jsonContent: jsonContent as! Array<Any>)
            
            self.jsonSections!.append(newSection)
        }
    }
    
    
    public typealias MOSModelLogChangedBlock = () -> Void
    var logChangedBlock: MOSModelLogChangedBlock? = nil
    
    public func addLog(newLogEntry: String) {
        
        let currentTime = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.init(identifier: "UTC")
        dateFormatter.defaultDate = currentTime
        let current = dateFormatter.string(from: currentTime)

        self.logs!.append(["timestamp": current])
        self.logs!.append(["log": newLogEntry])
        
        if self.logChangedBlock != nil  {
            print("logChangedBlock is not equal to nil\n")
            self.logChangedBlock!()
        }
    }
    
}
