//
//  AuthenticationService.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 06/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthenticationService{
    
    static func signOffUser() -> Bool {
        // Sign out the user
        do {
            try Auth.auth().signOut()
            // Return true if the user is signed out
            return true
        }catch{
            // DEBUG MESSAGE
            print("Sign Out Error")
            // Return false if the user isn't signed out
            return false
        }
    }
    
    static func checkSignedInUser() -> Bool{
        // Check if the user is signed in
        if Auth.auth().currentUser != nil {
            // Return true if the user is signed in
            return true
        }else {
            // Return false if the user isn't signed in
            return false
        }
    }
    
    static func getSignedInUserEmail() -> String {
        // Get the signed in user email
        if let userEmail = Auth.auth().currentUser?.email{
            // Return the user email
            return userEmail
        }else {
            // Return empty string when no email was found
            return ""
        }
    }
}
