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
    var barChartColors : [UIColor] = []
    var overUse:Bool = false
    
    //MARK: IBOutlets
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        overUse = false
        setupPieChart()
        setupBarChart()
    }
    
    //MARK: Helper Functions
    func setupPieChart(){
        let kcalValue = currentDayTotal?.kilocaloriesTotal ?? 0.0
        let maxDayValue = 2225.0
        var restDayValue = maxDayValue - kcalValue
        var overUseKcal = 0.0
        var overUseKcalData:PieChartDataEntry?
        var kcalData:PieChartDataEntry?
        var unusedKcalData:PieChartDataEntry?
        
        if restDayValue < 0 {
            overUseKcal = restDayValue*(-1)
            restDayValue = 2225
            if overUseKcal > maxDayValue {
                overUseKcalData = PieChartDataEntry(value: overUseKcal)
                overUseKcalData!.label = "Kcal Overuse"
                
                pieChartData = [overUseKcalData] as! [PieChartDataEntry]
                barChartColors = [UIColor(named: "OverUseCollor")] as! [UIColor]
            }else {
            unusedKcalData = PieChartDataEntry(value: restDayValue)
            unusedKcalData!.label = "Kcal Day Max"

            overUse = true
            overUseKcalData = PieChartDataEntry(value: overUseKcal)
            overUseKcalData!.label = "Kcal Overuse: \(ConverterService.convertDoubleToString(double: overUseKcal))"
                
            pieChartData = [unusedKcalData,overUseKcalData] as! [PieChartDataEntry]
            barChartColors = [UIColor(named: "KcalColor"),UIColor(named: "OverUseCollor")] as! [UIColor]
            }
        }else {
            kcalData = PieChartDataEntry(value: kcalValue)
            kcalData!.label = "Kcal Used"
            
            unusedKcalData = PieChartDataEntry(value: restDayValue)
            unusedKcalData!.label = "Kcal Unused"
            
            pieChartData = [kcalData,unusedKcalData] as! [PieChartDataEntry]
            barChartColors = [UIColor(named: "KcalColor"),UIColor(named: "FiberColor")] as! [UIColor]
        }
        createPieChart()
    }
    
    func createPieChart(){
        let chartDataSet = PieChartDataSet(values: pieChartData, label: nil)
        chartDataSet.colors = barChartColors
        let chart = PieChartData(dataSet: chartDataSet)
        if overUse {
            chart.setDrawValues(false)
        }
        chart.setValueFont(UIFont(name: "Verdana", size: 10)!)
        chart.setValueTextColor(UIColor.black)
        pieChart.holeColor = UIColor.clear
        pieChart.data = chart
        pieChart.animate(xAxisDuration: 1.5, easingOption: .easeInCirc)
    }
    
    func setupBarChart() {
        let proValue = currentDayTotal?.proteinTotal ?? 0.0
        let saltValue = currentDayTotal?.saltTotal ?? 0.0
        let carbValue = currentDayTotal?.carbohydratesTotal ?? 0.0
        let fiberValue = currentDayTotal?.fiberTotal ?? 0.0
        let fatValue = currentDayTotal?.fatTotal ?? 0.0
        
        proData     = BarChartDataEntry(x: 0, y: proValue)
        fatData     = BarChartDataEntry(x: 1, y: fatValue)
        fiberData   = BarChartDataEntry(x: 2, y: fiberValue)
        saltData    = BarChartDataEntry(x: 3, y: saltValue)
        carbData    = BarChartDataEntry(x: 4, y: carbValue)
        
        barChartData = [proData,fatData,fiberData,saltData,carbData] as! [BarChartDataEntry]
        createBarChart()
    }
    
    func createBarChart(){
        let chartDataSet = BarChartDataSet(values: barChartData, label: nil)
        // Create barchart colors
        let colors = [
            UIColor(named: "ProteinColor"),
            UIColor(named: "FatColor"),
            UIColor(named: "FiberColor"),
            UIColor(named: "SaltColor"),
            UIColor(named: "CarbColor")
        ]
        // Set barchart colors
        chartDataSet.colors = colors as! [NSUIColor]
        
        let chart = BarChartData(dataSet: chartDataSet)
        chart.barWidth = 0.95
        chart.setValueFont(UIFont(name: "Verdana", size: 10)!)
        let format = NumberFormatter()
        format.numberStyle = .decimal
        format.maximumFractionDigits = 2
        let formatter = DefaultValueFormatter(formatter: format)
        chart.setValueFormatter(formatter)
        barChart.rightAxis.enabled = false
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: barLabelValues)
        barChart.xAxis.granularity = 1
        barChart.xAxis.labelFont = UIFont(name: "Verdana", size: 15)!
        barChart.leftAxis.labelFont = UIFont(name: "Verdana", size: 15)!
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.highlighter = nil
        barChart.scaleXEnabled = false
        // Create custom barchart labels
        createBarLegendEntries()
        // Set custom barchart labels
        barChart.legend.setCustom(entries: barLegendEntries)
        // Set barchart animation
        barChart.animate(yAxisDuration: 1.5 ,easingOption: .easeInOutQuart)
        // Set barchart data
        barChart.data = chart
    }
    
    func createBarLegendEntries() {
        for value in barLabelValues {
            let valueLegend = LegendEntry()
            valueLegend.label = value
            valueLegend.form = .circle
            valueLegend.formColor = UIColor.init(named: value+"Color")
            barLegendEntries.append(valueLegend)
        }
    }
    
//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}
