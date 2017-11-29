//
//  CoreDataDAO.swift
//  MOSProject
//
//  Created by Darko on 2017/11/29.
//  Copyright © 2017年 Darko. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataDAO: NSObject {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "SensorCoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("persistenContainer error: ", error.localizedDescription)
            }
        })
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("data save error: ", nserror.localizedDescription)
            }
        }
    }
    
    
    
}
