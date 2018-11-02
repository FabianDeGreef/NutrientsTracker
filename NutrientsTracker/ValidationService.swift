//
//  ValidationService.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 10/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation

class ValidationService {
    
    static func numberValidator(value:String) -> Bool{
        // Check if the string value is decimal
        var isTrue = true
        // Check if the value is empty
        if (!value.isEmpty) {
            // Create a NSCharacterSet with decimalDigits
            let charSet = NSCharacterSet.decimalDigits as NSCharacterSet
            // Loop through the characters and check if they match with the NSCharacterSet
            for char in value.unicodeScalars {
                // If a character matches with the NSCharacterSets continue
                if  charSet.longCharacterIsMember(char.value){
                    // Set the boolean result true
                    isTrue = true
                }else {
                    // If a character doesn't matches with the NSCharacterSet set the boolean to false
                    isTrue = false
                }
            }
        }else {
            // Return false when the value is empty
            return false
        }
        // Return the boolean result
        return isTrue
    }
    
    static func decimalValidator(value:String) -> Bool{
        // Check if the string value is decimal
        var isTrue = true
        // Set the commaCount to zero
        var commaCount = 0
        // Check if the value is empty
        if (!value.isEmpty) {
            // Create a NSCharacterSet with decimalDigits
            let charSet = NSCharacterSet.decimalDigits as NSCharacterSet
            // Loop through the characters and check if they match with the NSCharacterSet
            for char in value.unicodeScalars {
                // If a character matches with the NSCharacterSet or a comma continue
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
            // Return false when the value is empty or smaller than 1 character
            return false
        }
        // Return the boolean result
        return isTrue
    }
    
    static func alphabeticalValidator(value:String) -> Bool {
        // Check if the string value is alphabetical and has more than one letter
        var isTrue = true
        // Check if the value is empty or smaller than 1 character
        if (!value.isEmpty && value.count > 1 && !value.hasPrefix(" ") && !value.hasSuffix(" ")) {
            // Create an NSCharacterSet with letters
            let letters = NSCharacterSet.letters as NSCharacterSet
            // Create an NSCharacterSet with a space
            let space = NSCharacterSet.whitespaces as NSCharacterSet
            // Loop through the characters and check if they match to the one of the NSCharacterSets
            for char in value.unicodeScalars {
                // If a character matches with the NSCharacterSets continue
                if  letters.longCharacterIsMember(char.value) || space.longCharacterIsMember(char.value) {
                }else {
                    // If a character doesn't matches with the NSCharacterSets set the boolean to false
                    isTrue = false
                }
            }
        }else {
            // Return false when the value is empty or smaller than 1 character
            return false
        }
        // Return the boolean result
        return isTrue
    }
    
   static func validateEmail(email:String) -> Bool {
        // Check value is not empty, contains an at sign and has a size larger than 3
        if !(email.isEmpty) && email.contains("@") && email.count > 3 {
            // DEBUG MESSAGE
            print("Email is valid")
            return true
        }else {
            return false
        }
    }
    
    static func validatePassword(password:String) -> Bool {
        // Check value is not empty and has a size larger than 3
        if !password.isEmpty && password.count > 3 {
            // DEBUG MESSAGE
            print("Password is valid")
            return true
        }else {
            return false
        }
    }
}
