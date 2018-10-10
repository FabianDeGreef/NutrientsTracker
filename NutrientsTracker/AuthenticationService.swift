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
            print("Signout error")
            return false
        }
    }
    // Check if user is singed in and return true or false
    static func checkSingedInUser() -> Bool{
        if Auth.auth().currentUser != nil {
                return true
        }else {
            return false
        }
    }
}
