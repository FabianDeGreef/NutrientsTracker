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
        do {
            try Auth.auth().signOut()
            return true
        }catch{
            print("Signout error")
            return false
        }
    }
    
    static func checkSingedInUser() -> Bool{
        if Auth.auth().currentUser != nil {
                return true
        }else {
            return false
        }
    }
}
