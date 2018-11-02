//
//  PersistenceService.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 06/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import CoreData

class PersistenceService {
    
    // Initialize the PersistenceService
    private init(){}
    
    static var context: NSManagedObjectContext {
        // Return the persistentContainer.viewContext
        return persistentContainer.viewContext
    }
    
    // Core data stack
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NutrientsTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        // Return core data container
        return container
    }()
    
    // Core data saving function
    static func saveContext () {
        // Create context object
        let context = persistentContainer.viewContext
        // When the context has changes
        if context.hasChanges {
            // Save if the context has changes
            do {
                // Try to save
                try context.save()
            } catch {
                // Catch errors during context save operation
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // Core data delete by entity name function
    static func deleteDataByEntity(entity:String){
        // Create new fetchRequest by entity name
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        // Turn off returnObjectsAsFaults
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try PersistenceService.context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                // Delete object inside the context stack
                PersistenceService.context.delete(objectData)
            }
        }catch {
            // DEBUG MESSAGE
            print("Error deleting one or more entitys")
        }
    }
}
