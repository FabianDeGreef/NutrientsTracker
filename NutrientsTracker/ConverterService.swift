//
//  ConverterService.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 10/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation

class ConverterService {
    
    static func convertStringToDouble(string: String) -> Double {
        // Creates a numberFormatter
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        // Use comma as the decimalSeperator
        formatter.decimalSeparator = ","
        // Convert the string to double and return the converted value
        return formatter.number(from: string) as? Double ?? 0
    }
    
    static func convertDoubleToString(double: Double) -> String {
        // Convert to float string with 2 decimals behind the comma
        let convertToFloatString = String(format: "%.2f" ,double)
        // Replace the float poing seperator with a comma
        let doubleString = convertToFloatString.replacingOccurrences(of: ".", with: ",")
        // Return the double string
        return doubleString
    }
    
    static func formatDateToString(dateValue:Date) -> String{
        // Create a datefromatter
        let dateFormatter = DateFormatter()
        // Setup the date format
        dateFormatter.dateFormat = "dd MMM yyyy"
        // Convert the date value to a string value
        let stringDate = dateFormatter.string(from: dateValue)
        // Return the string date
        return stringDate
    }
    
    static func convertDayTotalArrayToDateStringArray(dayTotals:[DayTotal]) -> [String]{
        // Create an empty string array
        var stringDateArray:[String] = []
        // Convert every date with the formatDateToString to a string and append it to the array
        for day in dayTotals {
            stringDateArray.append(formatDateToString(dateValue: day.date!))
        }
        // Return the date string array
        return stringDateArray
    }
    
    static func convertNSDayTotalsSetToDayTotalArray(dayTotalNSSet:NSSet)-> [DayTotal]{
        // Convert NSSet object set to a DayTotal array
        var dayTotalArray = dayTotalNSSet.allObjects as! [DayTotal]
        // Sort the dayTotalArray by date in descending order
        dayTotalArray.sort { (dayTotalOne, dayTotalTwo) -> Bool in
            return dayTotalOne.date?.compare(dayTotalTwo.date!) == ComparisonResult.orderedDescending
        }
        // Return the sorted dayTotal array
        return dayTotalArray
    }
    
    static func convertNSProductsSetToConsumedProductsArray(products:NSSet)-> [ConsumedProduct]{
        // Convert NSSet object set to ConsumedProduct array
        var consumedProductArray = products.allObjects as! [ConsumedProduct]
        // Sort the consumedProductArray by name in descending order
        consumedProductArray.sort { (productOne, productTwo) -> Bool in
            return productOne.name!.compare(productTwo.name!) == ComparisonResult.orderedAscending
        }
        // Return the sorted consumedProduct array
        return consumedProductArray
    }
}

//        // Create a datefromatter
//        let dateFormatter = DateFormatter()
//        // Setup the date format
//        dateFormatter.dateFormat = "dd MMM yyyy"
