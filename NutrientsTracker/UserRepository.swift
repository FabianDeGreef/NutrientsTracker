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
        // Create an optional user variable
        var currentUser:User?
        // Create a user fetchRequest
        let userFetch = NSFetchRequest<User>(entityName: "User")
        // Initialize the predicate email to find the matching user with the email value
        userFetch.predicate = NSPredicate(format:"email == %@", email)
        do {
            // Access the database and retrieve the user with the matching email value
            if let userMatch = try (PersistenceService.context.fetch(userFetch).first){
                // Store the found value inside the optional user variable
                currentUser = userMatch
                // DEBUG MESSAGE
                print("User found with email: \(currentUser!.email ?? "")")
            }else {
                // When no match was found create a new user with the given email value
                currentUser = createUserByEmail(email: email)
            }
        }catch{
            // DEBUG MESSAGE
            print("Could not fetch the user with given email \(error)")
        }
        // Return the matching or new user
        return currentUser!
    }
    
    private static func createUserByEmail(email:String) -> User {
        // Create new user by email
        let newUser = User(context: PersistenceService.context)
        // Add the email to the new user object
        newUser.email = email
        // Save the new user
        PersistenceService.saveContext()
        // DEBUG MESSAGE
        print("Added new user with email \(newUser.email ?? "No Email")")
        // Return the new user
        return newUser
    }
}
