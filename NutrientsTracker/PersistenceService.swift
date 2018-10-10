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
    private init(){
        
    }
    
    // Accesable static context variable to return the presisentContainer
    static var context: NSManagedObjectContext {
        // Return the persistentContainer.viewContext
        return persistentContainer.viewContext
    }
    
    //MARK: Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NutrientsTracker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    //MARK: Core Data Saving support
    static func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            // Save when context has changes
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
