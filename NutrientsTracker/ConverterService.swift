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
        // Use the comma as the decimalSeperator
        formatter.decimalSeparator = ","
        // Convert the string to double and return the converted value or 0
        return formatter.number(from: string) as? Double ?? 0
    }
    
    static func convertDoubleToString(double: Double) -> String {
        // Convert to float string with 2 decimals behind the comma
        let convertToFloatString = String(format: "%.2f" ,double)
        // Repalce the float point with a comma
        let doubleString = convertToFloatString.replacingOccurrences(of: ".", with: ",")
        // Return the doubleString
        return doubleString
    }
    
    static func formatDateToString(dateValue:Date) -> String{
        // Create a datefromatter
        let dateFormatter = DateFormatter()
        // Setting the dateformat
        dateFormatter.dateFormat = "dd MMM yyyy"
        //dateFormatter.dateStyle = .short
        // Convert the DayTotal dates to a string value using the datefromatter
        let stringDate = dateFormatter.string(from: dateValue)
        return stringDate
    }
}
