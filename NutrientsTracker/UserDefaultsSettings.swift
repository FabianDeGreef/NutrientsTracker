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
        let userDefaults = UserDefaults.standard
        // Check if the app setup runs the first time
        if userDefaults.value(forKey: "FirstTimeSetup") == nil {
            // Set the app first time setup to false
            userDefaults.set(false, forKey: "FirstTimeSetup")
            // Set a default kcal limit value
            userDefaults.set(200, forKey: "KilocalorieLimitValue")
            userDefaults.set("", forKey: "UserEmail")
            userDefaults.set("", forKey: "UserUID")
            userDefaults.set(true, forKey: "ImportStarterProducts")

            // Sign off if a user is signed in
            if AuthenticationService.signOffUser() {
                print("Signing out user")
            }else {
                print("No user to sign out")
            }
        }else {
         print("No user settings to change")
        }
    }
    
    // Set kilocalorie value
    static func setKilocalorieLimitValue(valueLimit:Int) {
        userDefaults.set(valueLimit, forKey: "KilocalorieLimitValue")
    }
    
    // Get kilocalorie value
    static func getKilocalorieLimitValue() -> Int {
        return userDefaults.value(forKey: "KilocalorieLimitValue") as! Int
    }
    
    // Set user email
    static func setUserEmail(userEmail:String) {
        userDefaults.set(userEmail, forKey: "UserEmail")
    }
    
    // Get user email
    static func getUserEmail() -> String {
        return userDefaults.value(forKey: "UserEmail") as! String
    }
    
    // Set user UID
    static func setUserUID(userUID:String) {
        userDefaults.set(userUID, forKey: "UserUID")
    }
    
    // Get user UID
    static func getUserUID() -> String {
        return userDefaults.value(forKey: "UserUID") as! String
    }
    
    // Get user StarterProducts condition
    static func getStarterProductsCondition() -> Bool  {
        return userDefaults.value(forKey: "ImportStarterProducts") as! Bool
    }
    
    // Turn of starterProducts
    static func turnOfStarterProducts() {
        userDefaults.set(false, forKey: "ImportStarterProducts")
    }
}
