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
    let barLabelValues = ["Protein","Fat","Fiber","Salt","Carb"]

    //MARK: IBOutlets
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var pieChart: PieChartView!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPieChart()
        setupBarChart()
    }
    
    func setupPieChart(){
        let kcalValue = currentDayTotal?.kilocaloriesTotal ?? 0.0
        let maxDayValue = 2225.0
        let restDayValue = maxDayValue - kcalValue
        
        let kcalData = PieChartDataEntry(value: kcalValue)
        kcalData.label = "Kcal Used"
        let unusedKcalData = PieChartDataEntry(value: restDayValue)
        unusedKcalData.label = "Kcal Unused"
        pieChartData = [kcalData,unusedKcalData]
        createPieChart()
    }
    
    func createPieChart(){
        let chartDataSet = PieChartDataSet(values: pieChartData, label: nil)
        let colors = [
            UIColor(named: "KcalColor"),
            UIColor(named: "FiberColor")
        ]
        chartDataSet.colors = colors as! [NSUIColor]
        let chart = PieChartData(dataSet: chartDataSet)
        chart.setValueFont(UIFont(name: "Verdana", size: 10)!)
        chart.setValueTextColor(UIColor.black)
        pieChart.holeColor = UIColor.clear
        pieChart.data = chart
        pieChart.animate(xAxisDuration: 1.5, easingOption: .easeInCirc)
    }
    
    //MARK: Helper Functions
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

//        let proLegend = LegendEntry()
//        proLegend.label = "Protein"
//        proLegend.form = .circle
//        proLegend.formColor = UIColor.init(named: "ProteinColor")
//
//        let fatLegend = LegendEntry()
//        fatLegend.label = "Fat"
//        fatLegend.form = .circle
//        fatLegend.formColor = UIColor.init(named: "FatColor")
//
//        let fiberLegend = LegendEntry()
//        fiberLegend.label = "Fiber"
//        fiberLegend.form = .circle
//        fiberLegend.formColor = UIColor.init(named: "FiberColor")
//
//        let saltLegend = LegendEntry()
//        saltLegend.label = "Salt"
//        saltLegend.form = .circle
//        saltLegend.formColor = UIColor.init(named: "SaltColor")
//
//        let carboLegend = LegendEntry()
//        carboLegend.label = "Carbo"
//        carboLegend.form = .circle
//        carboLegend.formColor = UIColor.init(named: "CarbColor")
//
//        barChart.legend.setCustom(entries: [proLegend,fatLegend,fiberLegend,saltLegend,carboLegend])
