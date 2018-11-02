//
//  UserDefaultsSettings.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 29/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation

class UserDefaultsSettings {
    
   static let userDefaults = UserDefaults()

    // Initialize UserDefaultsSettings
    init() {
        // Access and store the userDefaults standard
        let userDefaults = UserDefaults.standard
        // Check if the app runs for the first time
        if userDefaults.value(forKey: "FirstTimeSetup") == nil {
            // Set the app first time setup to false
            userDefaults.set(false, forKey: "FirstTimeSetup")
            // Set a default kilocalorie limit value
            userDefaults.set(200, forKey: "KilocalorieLimitValue")
            // Set the default userEmail to empty
            userDefaults.set("", forKey: "UserEmail")
            // Set the default userUID to empty
            userDefaults.set("", forKey: "UserUID")
            // Set the ImportStarterProducts to true
            userDefaults.set(true, forKey: "ImportStarterProducts")
            // Sign off user if signed in
            if AuthenticationService.signOffUser() {
                print("Signing out user")
            }else {
                print("No user to sign out")
            }
        }else {
         print("No user settings to change")
        }
    }
    
    static func reEnableFirstTimeSetup() {
        // Set FirstTimeSetup value nil
        userDefaults.set(nil, forKey: "FirstTimeSetup")
    }
    
    static func GetFirstTimeSetupState() -> UserDefaults {
        // Return FirstTimeSetupState
        return userDefaults.value(forKey: "FirstTimeSetup") as! UserDefaults
    }
    
    static func setKilocalorieLimitValue(valueLimit:Int) {
        // Set kilocalorie value
        userDefaults.set(valueLimit, forKey: "KilocalorieLimitValue")
    }
    
    static func getKilocalorieLimitValue() -> Int {
        // Return kilocalorie value
        return userDefaults.value(forKey: "KilocalorieLimitValue") as! Int
    }
    
    static func setUserEmail(userEmail:String) {
        // Set user email
        userDefaults.set(userEmail, forKey: "UserEmail")
    }
    
    static func getUserEmail() -> String {
        // Return user email
        return userDefaults.value(forKey: "UserEmail") as! String
    }
    
    static func setUserUID(userUID:String) {
        // Set user UID
        userDefaults.set(userUID, forKey: "UserUID")
    }
    
    static func getUserUID() -> String {
        // Return user UID
        return userDefaults.value(forKey: "UserUID") as! String
    }
    
    static func getStarterProductsCondition() -> Bool  {
        // Return user StarterProducts condition
        return userDefaults.value(forKey: "ImportStarterProducts") as! Bool
    }
    
    static func turnOfStarterProducts() {
        // Turn of starterProducts
        userDefaults.set(false, forKey: "ImportStarterProducts")
    }
}
