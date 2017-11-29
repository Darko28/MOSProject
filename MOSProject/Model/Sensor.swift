//
//  Sensor.swift
//  MOSProject
//
//  Created by Darko on 2017/11/29.
//  Copyright © 2017年 Darko. All rights reserved.
//

import UIKit

public class Sensor: NSObject , NSCoding{
    
    public var time: String
    public var pm25Data: Double
    public var pm10Data: Double
    
    public override init() {
        self.time = ""
        self.pm25Data = 0
        self.pm10Data = 0
    }
    
    public init(time: String, pm25Data: Double, pm10Data: Double) {
        self.time = time
        self.pm25Data = pm25Data
        self.pm10Data = pm10Data
    }
    
    // NSCoding Protocol
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(time, forKey: "time")
        aCoder.encode(pm25Data, forKey: "pm25Data")
        aCoder.encode(pm10Data, forKey: "pm10Data")
    }
    
   public  required init?(coder aDecoder: NSCoder) {
    self.time = aDecoder.decodeObject(forKey: "time") as! String
    self.pm25Data = aDecoder.decodeObject(forKey: "pm25Data") as! Double
    self.pm10Data = aDecoder.decodeObject(forKey: "pm10Data") as! Double
    }
}
