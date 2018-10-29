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
    
    // Sign out the current user and return true or false
    static func signOffUser() -> Bool {
        do {
            try Auth.auth().signOut()
            return true
        }catch{
            // DEBUG MESSAGE
            print("Sign Out Error")
            return false
        }
    }
    
    // Check if user is singed in and return true or false
    static func checkSignedInUser() -> Bool{
        if Auth.auth().currentUser != nil {
            return true
        }else {
            return false
        }
    }
    
    // Get signed in user email
    static func getSignedInUserEmail() -> String {
        if let userEmail = Auth.auth().currentUser?.email{
            return userEmail
        }else {
            return ""
        }
    }
}

//    static func checkUserState() -> Bool {
//        var validState:Bool?
//        Auth.auth().addStateDidChangeListener { auth, user in
//            if user != nil {
//                validState = true
//                print("A user is signed in")
//            } else {
//                validState = false
//                print("No user is signed in")
//            }
//        }
//        return validState!
//    }
