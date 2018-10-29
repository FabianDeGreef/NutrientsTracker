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
        var dayTotals:[DayTotal]?
        let currentUser = UserRepository.fetchUserByEmail(email: email)
        dayTotals = ConverterService.convertNSDayTotalsSetToDayTotalArray(dayTotalNSSet: currentUser.dayTotals!)
        return dayTotals!
    }
    
    static func fetchDayTotalsToDelete(email:String) -> NSSet {
        let currentUser = UserRepository.fetchUserByEmail(email: email)
        return currentUser.dayTotals!
    }
    
    static func fetchFixedAmountDayTotalsByUserEmail(email:String,count:Int) -> [DayTotal] {
        var dayTotals:[DayTotal]?
        let currentUser = UserRepository.fetchUserByEmail(email: email)
        dayTotals = ConverterService.convertNSDayTotalsSetToDayTotalArray(dayTotalNSSet: currentUser.dayTotals!)
        let fixedSizeDayTotals = Array((dayTotals?.prefix(count))!)
        return fixedSizeDayTotals
    }
    
    static func updateDayTotal(consumedProduct:ConsumedProduct, currentDayTotal:DayTotal){
        // DEBUG MESSAGE
        print("Carbohydrate total first: " + String(format: "%.2f" ,currentDayTotal.carbohydratesTotal ))
        // Calculate the nutrient values for the dayTotal by adding the nutrient values from the new consumedProduct to the dayTotal
        currentDayTotal.carbohydratesTotal = (currentDayTotal.carbohydratesTotal) + consumedProduct.carbohydrates
        currentDayTotal.fiberTotal = (currentDayTotal.fiberTotal) + consumedProduct.fiber
        currentDayTotal.saltTotal = (currentDayTotal.saltTotal) + consumedProduct.salt
        currentDayTotal.proteinTotal = (currentDayTotal.proteinTotal) + consumedProduct.protein
        currentDayTotal.fatTotal = (currentDayTotal.fatTotal) + consumedProduct.fat
        currentDayTotal.kilocaloriesTotal = (currentDayTotal.kilocaloriesTotal) + consumedProduct.kilocalories
        // DEBUG MESSAGE
        print("Carbohydrate total leter: " + String(format: "%.2f" ,currentDayTotal.carbohydratesTotal))
    }
}
