//
//  DayTotalRepository.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 26/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation
import CoreData

class DayTotalRepository {
    
    static func fetchDayTotalsByUserEmail(email:String) -> [DayTotal] {
        // Create an empty dayTotal array
        var dayTotals:[DayTotal] = []
        // Fetch and store the user by it's email
        let currentUser = UserRepository.fetchUserByEmail(email: email)
        // Convert and store the NSDayTotal Set to a dayTotal array
        dayTotals = ConverterService.convertNSDayTotalsSetToDayTotalArray(dayTotalNSSet: currentUser.dayTotals!)
        // Return the dayTotal array
        return dayTotals
    }
    
    static func fetchFixedAmountDayTotalsByUserEmail(email:String,count:Int) -> [DayTotal] {
        // Create an empty dayTotal array
        var dayTotals:[DayTotal] = []
        // Fetch and store the user by it's email
        let currentUser = UserRepository.fetchUserByEmail(email: email)
        // Convert and store the NSDayTotal Set to a dayTotal array
        dayTotals = ConverterService.convertNSDayTotalsSetToDayTotalArray(dayTotalNSSet: currentUser.dayTotals!)
        // Store the latest dayTotals for the fixed amount inside a new variable
        let fixedSizeDayTotals = Array((dayTotals.prefix(count)))
        // Return dayTotal array
        return fixedSizeDayTotals
    }
    
    static func fetchDayTotalsToDelete(email:String) -> NSSet {
        // Fetch and store the user by it's email
        let currentUser = UserRepository.fetchUserByEmail(email: email)
        // Return the user it's dayTotals
        return currentUser.dayTotals!
    }
    
    static func createNewDayTotal(dayTotalDate:Date) -> DayTotal {
        // Create new dayTotal
        let newDayTotal = DayTotal(context: PersistenceService.context)
        // Sets the date value for the new dayTotal
        newDayTotal.date = dayTotalDate
        // Acces the user email from the userdefaults
        let userEmail = UserDefaultsSettings.getUserEmail()
        // Get matching local user with the email
        let user = UserRepository.fetchUserByEmail(email: userEmail)
        // Add the new dayTotal to the user
        user.addToDayTotals(newDayTotal)
        // Save context changes
        PersistenceService.saveContext()
        // Return the new dayTotal
        return newDayTotal
    }
    
    static func updateDayTotal(consumedProduct:ConsumedProduct, currentDayTotal:DayTotal){
        // Calculate the dayTotal nutrient values by adding all the values from the new consumedProduct to it
        currentDayTotal.carbohydratesTotal  = (currentDayTotal.carbohydratesTotal) + consumedProduct.carbohydrates
        currentDayTotal.fiberTotal          = (currentDayTotal.fiberTotal) + consumedProduct.fiber
        currentDayTotal.saltTotal           = (currentDayTotal.saltTotal) + consumedProduct.salt
        currentDayTotal.proteinTotal        = (currentDayTotal.proteinTotal) + consumedProduct.protein
        currentDayTotal.fatTotal            = (currentDayTotal.fatTotal) + consumedProduct.fat
        currentDayTotal.kilocaloriesTotal   = (currentDayTotal.kilocaloriesTotal) + consumedProduct.kilocalories
    }
}
