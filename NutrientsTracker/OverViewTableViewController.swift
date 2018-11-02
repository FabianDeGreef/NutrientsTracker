//
//  OverViewTableViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 24/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import Charts

class OverViewTableViewController: UITableViewController {
    
    //MARK: Properties
    var currentDayTotal:DayTotal?
    var proData:BarChartDataEntry?
    var saltData:BarChartDataEntry?
    var carbData:BarChartDataEntry?
    var fatData:BarChartDataEntry?
    var fiberData:BarChartDataEntry?
    var barChartData = [BarChartDataEntry]()
    var pieChartData = [PieChartDataEntry]()
    var barLegendEntries:[LegendEntry] = []
    var barLabelValues = ["Protein","Fat","Fiber","Salt","Carb"]
    var pieChartColors : [UIColor] = []
    var overUse:Bool = false
    
    //MARK: IBOutlets
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the overUse boolean to false when the view loads
        overUse = false
        // Setup the pieChart
        setupPieChart()
        // Setup the barChart
        setupBarChart()
    }
    
    //MARK: UITableView Delegates
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Setup the staticTable screen height
        return (CGFloat(UIScreen.main.bounds.height) - CGFloat(32))/2
    }
    
    //MARK: Helper Functions
    func setupPieChart(){
        // Store the currentDayTotal kilocalorieTotal value inside a variable
        let kcalValue = currentDayTotal?.kilocaloriesTotal ?? 0.0
        // Set the maximum kilocalorie day value
        let maxDayValue = 2225.0
        // Subtract the maxDayValue and kcalValue and store the restValue
        var restDayValue = maxDayValue - kcalValue
        // Set overUseKcal to 0
        var overUseKcal = 0.0
        // Create the pieChartDataEntrys for each value
        var overUseKcalData:PieChartDataEntry?
        var kcalData:PieChartDataEntry?
        var unusedKcalData:PieChartDataEntry?
        
        // Check if the restDayValue is smaller than 0
        if restDayValue < 0 {
            // Turn and store the restDayValue positive and inside the overUseKcal
            overUseKcal = restDayValue*(-1)
            // Set the restDayValue as the maximum  kilocalirie day value
            restDayValue = 2225
            // Check if the overUseKcal is greater than the maxDayValue
            if overUseKcal > maxDayValue {
                // If it is greather setup the overUseKcalData
                overUseKcalData = PieChartDataEntry(value: overUseKcal)
                // Set the label text
                overUseKcalData!.label = "Kcal Overuse"
                // Store the overUseKcalData inside the pieChartData array
                pieChartData = [overUseKcalData] as! [PieChartDataEntry]
                // Store the overUseCollor inside the barChartColors array
                pieChartColors = [UIColor(named: "OverUseCollor")] as! [UIColor]
            }else {
                // If it is not greater setup the unusedKcalData
                unusedKcalData = PieChartDataEntry(value: restDayValue)
                // Set the label text
                unusedKcalData!.label = "Kcal Day Max"
                // Turn overUse to true
                overUse = true
                // Setup the overUsedKcalData
                overUseKcalData = PieChartDataEntry(value: overUseKcal)
                // Set the label text with it's value
                overUseKcalData!.label = "Kcal Overuse: \(ConverterService.convertDoubleToString(double: overUseKcal))"
                // Store the 2 values inside the pieChartData array
                pieChartData = [unusedKcalData,overUseKcalData] as! [PieChartDataEntry]
                // Store the KcalColor and OverUseCollor inside the barChartColors array
                pieChartColors = [UIColor(named: "KcalColor"),UIColor(named: "OverUseCollor")] as! [UIColor]
            }
        }else {
            // If the restDayValue is greater than 0 setup the kcalData
            kcalData = PieChartDataEntry(value: kcalValue)
            // Set the label text
            kcalData!.label = "Kcal Used"
            // Setup the unusedKcalData
            unusedKcalData = PieChartDataEntry(value: restDayValue)
            // Set the label text
            unusedKcalData!.label = "Kcal Unused"
            // Store the 2 values inside the pieChartData array
            pieChartData = [kcalData,unusedKcalData] as! [PieChartDataEntry]
            // Store the KcalColor and FiberColor inside the barChartColors array
            pieChartColors = [UIColor(named: "KcalColor"),UIColor(named: "FiberColor")] as! [UIColor]
        }
        // Creat the pieChart based on the setup
        createPieChart()
    }
    
    func createPieChart(){
        // Setup the chartDataSet by using the pieChartData array values
        let chartDataSet = PieChartDataSet(values: pieChartData, label: nil)
        // Setup the chartDataSet colors by using the barChartColors array values
        chartDataSet.colors = pieChartColors
        // Store the chart data from the pieChartData inside a variable
        let chart = PieChartData(dataSet: chartDataSet)
        // Check if overuse is enabled
        if overUse {
            // if overUse is enabled turn off the setDrawValues
            chart.setDrawValues(false)
        }
        // Set the chart value font and size
        chart.setValueFont(UIFont(name: "Verdana", size: 10)!)
        // Set the chart value font color
        chart.setValueTextColor(UIColor.black)
        // Set the chart holeColor to blanc
        pieChart.holeColor = UIColor.clear
        // Setup animation when the pieChart will be displayed with a easeInCircle animation
        pieChart.animate(xAxisDuration: 1.5, easingOption: .easeInCirc)
        // Store the chart data inside the pieChart data
        pieChart.data = chart
    }
    
    func setupBarChart() {
        // Store the nutrient total values in there variables
        let proValue = currentDayTotal?.proteinTotal ?? 0.0
        let saltValue = currentDayTotal?.saltTotal ?? 0.0
        let carbValue = currentDayTotal?.carbohydratesTotal ?? 0.0
        let fiberValue = currentDayTotal?.fiberTotal ?? 0.0
        let fatValue = currentDayTotal?.fatTotal ?? 0.0
        
        // Store and setup the barChartData entrys with there nutrient values
        proData     = BarChartDataEntry(x: 0, y: proValue)
        fatData     = BarChartDataEntry(x: 1, y: fatValue)
        fiberData   = BarChartDataEntry(x: 2, y: fiberValue)
        saltData    = BarChartDataEntry(x: 3, y: saltValue)
        carbData    = BarChartDataEntry(x: 4, y: carbValue)
        
        // Store the barChartData entrys inside the barChartData array
        barChartData = [proData,fatData,fiberData,saltData,carbData] as! [BarChartDataEntry]
        // Creat the barChart based on the setup
        createBarChart()
    }
    
    func createBarChart(){
        // Setup the chartDataSet by using the barChartData array values
        let chartDataSet = BarChartDataSet(values: barChartData, label: nil)
        // Create barChart colors array
        let colors = [
            UIColor(named: "ProteinColor"),
            UIColor(named: "FatColor"),
            UIColor(named: "FiberColor"),
            UIColor(named: "SaltColor"),
            UIColor(named: "CarbColor")
        ]
        // Setup the chartDataSet colors by using the colors array values
        chartDataSet.colors = colors as! [NSUIColor]
        // Store the chart data from the barChartData inside a variable
        let chart = BarChartData(dataSet: chartDataSet)
        // Setup the chart barWidth
        chart.barWidth = 0.95
        // Setup the chart value font and size
        chart.setValueFont(UIFont(name: "Verdana", size: 10)!)
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
        // Diable the rightAxis inside the barChart
        barChart.rightAxis.enabled = false
        // Insert the barChart labels for the xAxis
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: barLabelValues)
        barChart.xAxis.granularity = 1
        // Setup the xAxis label font and size
        barChart.xAxis.labelFont = UIFont(name: "Verdana", size: 15)!
        // Setup the leftAxis label font and size
        barChart.leftAxis.labelFont = UIFont(name: "Verdana", size: 15)!
        // Disable the drawGridLines
        barChart.xAxis.drawGridLinesEnabled = false
        // Diable the highlighter
        barChart.highlighter = nil
        // Disable the scaleX
        barChart.scaleXEnabled = false
        // Create custom barchart legendEntries
        createBarLegendEntries()
        // Setup custom barchart labels with the values inside the barLegendEntries
        barChart.legend.setCustom(entries: barLegendEntries)
        // Setup the barChart easeInOutQuart animation
        barChart.animate(yAxisDuration: 1.5 ,easingOption: .easeInOutQuart)
        // Store the chart data inside the barChart data
        barChart.data = chart

    }
    
    func createBarLegendEntries() {
        // For every value inside the barLabelValue array
        for value in barLabelValues {
            // Create a new LegendEntry
            let valueLegend = LegendEntry()
            // Set the value label with the value found in the barLabelValues
            valueLegend.label = value
            // Set the legend icon form to circle
            valueLegend.form = .circle
            // Set the icon form color to one of the stored collors by name inide the assets folder
            valueLegend.formColor = UIColor.init(named: value+"Color")
            // Add the LegendEntry to the barLegendEntries array
            barLegendEntries.append(valueLegend)
        }
    }
}
