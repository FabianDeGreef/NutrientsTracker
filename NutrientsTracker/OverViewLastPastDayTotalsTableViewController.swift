//
//  OverViewLastPastDayTotalsTableViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 26/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import Charts

class OverViewLastPastDayTotalsTableViewController: UITableViewController {

    //MARK: Properties
    var dayTotals:[DayTotal] = []
    var barChartData:[BarChartDataEntry] = []
    var dayTotalDates:[String] = []
    var barLegendEntries:[LegendEntry] = []
    var barColours:[UIColor] = ChartColorTemplates.colorful()

    //MARK: IBOutlets
    @IBOutlet weak var barChart: BarChartView!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        // Get the latest dayTotals
        getLastDayTotals()
    }
    
    //MARK: Helper Functions
    func getLastDayTotals() {
        // Retrieve and store the user email from the userDefaults
        let userEmail = UserDefaultsSettings.getUserEmail()
        // Retrieve the 4 latest dayTotals from the user
        dayTotals = DayTotalRepository.fetchFixedAmountDayTotalsByUserEmail(email: userEmail, count: 4)
        // Setup the barChart
        setupBarChart()
    }
    
    func setupBarChart() {
        // Set an index value to 0
        var index = 0
        // Loop through all the dayTotals
        for dayTotal in dayTotals {
            // Check if the dayTotal kilocalorie total value is greater than 0
            if dayTotal.kilocaloriesTotal > 0 {
                // If it is greater creat and add the a barChartDataEntry to the barChartData array
                barChartData.append(BarChartDataEntry(x: Double(index), y: dayTotal.kilocaloriesTotal))
                // Convert and add the dayTotal date to the dayTotalDates string array
                dayTotalDates.append(ConverterService.formatDateToString(dateValue: dayTotal.date!))
                // Add one to the index total
                index = index + 1
            }
        }
        // Create the barChart
        createBarChart()
    }
    
    func createBarChart(){
        // Setup the chartDataSet by using the barChartData array values
        let chartDataSet = BarChartDataSet(values: barChartData, label: nil)
        // Setup the chartDataSet colors by using the chartColorTemplate colorful
        chartDataSet.colors = ChartColorTemplates.colorful()
        // Store the chart data from the barChartData inside a variable
        let chart = BarChartData(dataSet: chartDataSet)
        // Setup the chart barWidth
        chart.barWidth = 0.45
        // Setup the value font and size
        chart.setValueFont(UIFont(name: "Verdana", size: 8)!)
        // Create a numberFormatter
        let format = NumberFormatter()
        // Set the formatter style to decimal
        format.numberStyle = .decimal
        // Set the maximum digits behind the coma to 2
        format.maximumFractionDigits = 2
        // Creat a DefaultVlueFormatter with the formatter data
        let formatter = DefaultValueFormatter(formatter: format)
        // Format the chart values witht he DefaultValueFormatter
        chart.setValueFormatter(formatter)
        // Diable the rigthAxis
        barChart.rightAxis.enabled = false
        // Insert the barChart labels for the xAxis
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayTotalDates)
        barChart.xAxis.granularity = 1
        // Setup the xAxis label font and size
        barChart.xAxis.labelFont = UIFont(name: "Verdana", size: 8)!
        // Setup the leftAxis label font and size
        barChart.leftAxis.labelFont = UIFont(name: "Verdana", size: 12)!
        // Disable the xAcis drawGridLines
        barChart.xAxis.drawGridLinesEnabled = false
        // Diable the highlighter
        barChart.highlighter = nil
        // Disable the scaleX
        barChart.scaleXEnabled = false
        // Set the leftAxis minium to 0.0
        barChart.leftAxis.axisMinimum = 0.0
        
        // Retrieve the stored user limit value
        let limit = UserDefaultsSettings.getKilocalorieLimitValue()
        // Set the limit value
        let limitLine = ChartLimitLine(limit: Double(limit) , label: "Kcal Limit: \(limit)")
        // Add the limitline to the leftAxis
        barChart.leftAxis.addLimitLine(limitLine)
        
        // Create custom barchart labels
        createBarLegendEntries()
        // Set custom barchart labels
        barChart.legend.setCustom(entries: barLegendEntries)
        // Setup the barChart easeInCubic animation
        barChart.animate(yAxisDuration: 1.3 ,easingOption: .easeInCubic)
        // Store the chart data inside the barChart data
        barChart.data = chart
    }
    
    func createBarLegendEntries() {
        // Create an index value 0
        var index = 0
        // For every value inside the barLabelValue array
        for value in dayTotalDates {
            // Create a new LegendEntry
            let valueLegend = LegendEntry()
            // Set the value label with the value found in the barLabelValues
            valueLegend.label = value
            // Set the legend icon form to circle
            valueLegend.form = .circle
            // Get the formColor inside the barColours by using the index
            valueLegend.formColor = barColours[index]
            // Add the legendEntry to the barLegendEntries array
            barLegendEntries.append(valueLegend)
            // Add 1 to the index total
            index = index  + 1
        }
    }
    
    //MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Setup the staticTable screen height
        return (CGFloat(UIScreen.main.bounds.height) - CGFloat(64))
    }
}
