//
//  UserRepository.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 26/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation
import CoreData

class UserRepository {
   
    static func fetchUserByEmail(email:String) -> User {
        var currentUser:User?
        // Create a fetchRequest to find a matching user with the signed in email
        let userFetch = NSFetchRequest<User>(entityName: "User")
        // Initialize a predicate email must match with user email
        userFetch.predicate = NSPredicate(format:"email == %@", email)
        do {
            // Access the database and retrieve the matching user
            if let userMatch = try (PersistenceService.context.fetch(userFetch).first){
                currentUser = userMatch
                // DEBUG MESSAGE
                print("User found with email: \(currentUser!.email ?? "")")
            }else {
                currentUser = createUserByEmail(email: email)
            }
        }catch{
            // DEBUG MESSAGE
            print("Could not fetch the user with given email \(error)")
        }
        return currentUser!
    }
    
    private static func createUserByEmail(email:String) -> User {
        // When no match was found add the new user to the database
        let newUser = User(context: PersistenceService.context)
        // Add the signed in email to the new user object
        newUser.email = email
        saveContext()
        // DEBUG MESSAGE
        print("Added new user with email \(newUser.email ?? "No Email")")
        return newUser
    }
    
    private static func saveContext() {
        // Save context changes
        PersistenceService.saveContext()
    }
}
