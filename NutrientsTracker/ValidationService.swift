//
//  ValidationService.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 10/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation

class ValidationService {
    
    static func decimalValidator(value:String) -> Bool{
        // Check the string value if it is alphabetical and has more as one letter
        var isTrue = true
        var commaCount = 0
        // Check if the value is empty
        if (!value.isEmpty) {
            // Create a NSCharacterSet with decimalDigits
            let charSet = NSCharacterSet.decimalDigits as NSCharacterSet
            // Iterate through the characters and check if they match to the NSCharacterSet
            for char in value.unicodeScalars {
                // Checks if characters matches with the character set or is a comma
                if  charSet.longCharacterIsMember(char.value) || char == "," {
                    // When the character is a comma
                    if char == "," {
                        // Add 1 to the commaCount
                        commaCount += 1
                    }
                }else {
                    // If a character doesn't matches with the NSCharacterSet set the boolean to false
                    isTrue = false
                }
            }
            // Checks if more than 1 comma was found and sets the boolean to false
            if commaCount > 1 {
                isTrue = false
            }
        }else {
            // Return false if the value is empty or smaller than 1 character
            return false
        }
        // Return the result
        return isTrue
    }
    
    static func alphabeticalValidator(value:String) -> Bool {
        // Check the string value if it is alphabetical and has more as one letter
        var isTrue = true
        // Check if the value is empty or smaller than 1 character
        if (!value.isEmpty && value.count > 1) {
            // Create a NSCharacterSet with letters
            let letters = NSCharacterSet.letters as NSCharacterSet
            // Iterate through the characters and check if they match to the NSCharacterSet
            for char in value.unicodeScalars {
                // If a character matches with the NSCharacterSet do nothing
                if  letters.longCharacterIsMember(char.value) {
                }else {
                    // If a character doesn't matches with the NSCharacterSet set the boolean to false
                    isTrue = false
                }
            }
        }else {
            // Return false if empty or smaller than 1 letter
            return false
        }
        return isTrue
    }
    
   static func validateEmail(email:String) -> Bool {
        if !(email.isEmpty) && email.contains("@") && email.count > 3 {
            print("Email is valid")
            return true
        }else {
            return false
        }
    }
    
    static func validatePassword(password:String) -> Bool {
        if !password.isEmpty && password.count > 3 {
            print("Password is valid")
            return true
        }else {
            return false
        }
    }
}
