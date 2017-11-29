//
//  SensorDAO.swift
//  MOSProject
//
//  Created by Darko on 2017/11/29.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation
import CoreData

public class SensorDAO: CoreDataDAO {
    
    private var dateFormatter = DateFormatter()
    
    public static let sharedInstance: SensorDAO = {
       let instance = SensorDAO()
//        instance.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return instance
    }()
    
    public func create(_ model: Sensor) {
        
        let context = persistentContainer.viewContext
        let sensor = NSEntityDescription.insertNewObject(forEntityName: "Sensor", into: context) as! SensorManagedObject
        
        sensor.time = model.time
        sensor.pm25Data = model.pm25Data
        sensor.pm10Data = model.pm10Data
        
        print("model: \(model.time)")
        self.saveContext()
    }
    
    public func remove(_ model: Sensor) {
        
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Sensor", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "time = %@", model.time)
        
        do {
            let listData = try context.fetch(fetchRequest)
            if listData.count > 0 {
                let sensor = listData[0] as! NSManagedObject
                context.delete(sensor)
                
                self.saveContext()
            }
        } catch {
            print("delete failed")
        }
    }
    
    public func findAll() -> NSMutableArray {
        
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Sensor", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        
        let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        let resListData = NSMutableArray()
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            if listData.count > 0 {
                for item in listData {
                    let tmp = item as! SensorManagedObject
                    let sensor = Sensor(time: tmp.time!, pm25Data: tmp.pm25Data, pm10Data: tmp.pm10Data)
                    resListData.add(sensor)
                    print("model time: \(tmp.time!.description)")
                    print("modelT: \(tmp.time!)")
                }
            }
        } catch {
            print("findAll failed")
        }
        
        return resListData
    }
    
    public func findById(_ model: Sensor) -> Sensor? {
        
        let context = persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Sensor", in: context)
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entity
        fetchRequest.predicate = NSPredicate(format: "time = %@", model.time)
        
        do {
            let listData = try context.fetch(fetchRequest)
            
            if listData.count > 0 {
                let tmp = listData[0] as! SensorManagedObject
                let sensor = Sensor(time: tmp.time!, pm25Data: tmp.pm25Data, pm10Data: tmp.pm10Data)
                return sensor
            }
        } catch {
            print("findById failed")
        }
        return nil
    }
    
}
