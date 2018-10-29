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

    // MARK: Properties
    var dayTotals:[DayTotal] = []
    var barChartData:[BarChartDataEntry] = []
    var dayTotalDates:[String] = []
    var barLegendEntries:[LegendEntry] = []
    var barColours:[UIColor] = ChartColorTemplates.colorful()

    // MARK: IBOutlets
    @IBOutlet weak var barChart: BarChartView!
    
    // MARK: Viewcontroller Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        getLastDayTotals()
    }
    
    func getLastDayTotals() {
        let userEmail:String = AuthenticationService.getSignedInUserEmail()
        dayTotals = DayTotalRepository.fetchFixedAmountDayTotalsByUserEmail(email: userEmail, count: 4)
        setupBarChart()
    }
    
    func setupBarChart() {
        var position = 0
        for dayTotal in dayTotals {
            if dayTotal.kilocaloriesTotal > 0 {
                barChartData.append(BarChartDataEntry(x: Double(position), y: dayTotal.kilocaloriesTotal))
                dayTotalDates.append(ConverterService.formatDateToString(dateValue: dayTotal.date!))
                position = position + 1
            }
        }
        createBarChart()
    }
    
    func createBarChart(){
        let chartDataSet = BarChartDataSet(values: barChartData, label: nil)
        chartDataSet.colors = ChartColorTemplates.colorful()
        
        let chart = BarChartData(dataSet: chartDataSet)
        chart.barWidth = 0.45
        chart.setValueFont(UIFont(name: "Verdana", size: 8)!)
        let format = NumberFormatter()
        format.numberStyle = .decimal
        format.maximumFractionDigits = 2
        let formatter = DefaultValueFormatter(formatter: format)
        chart.setValueFormatter(formatter)
        barChart.rightAxis.enabled = false
        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dayTotalDates)
        barChart.xAxis.granularity = 1
        barChart.xAxis.labelFont = UIFont(name: "Verdana", size: 8)!
        barChart.leftAxis.labelFont = UIFont(name: "Verdana", size: 12)!
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.highlighter = nil
        barChart.scaleXEnabled = false
        barChart.leftAxis.axisMinimum = 0.0
        
        // Get stored user limit value
        let limit = UserDefaultsSettings.getKilocalorieLimitValue()
        // Set the limot value
        let limitLine = ChartLimitLine(limit: Double(limit) , label: "Kcal Limit: \(limit)")
        // Add the limitline to the leftAxis
        barChart.leftAxis.addLimitLine(limitLine)
        
        // Create custom barchart labels
        createBarLegendEntries()
        // Set custom barchart labels
        barChart.legend.setCustom(entries: barLegendEntries)
        // Set barchart animation
        barChart.animate(yAxisDuration: 1.3 ,easingOption: .easeInCubic)
        // Set barchart data
        barChart.data = chart
    }
    
    func createBarLegendEntries() {
        var index = 0
        for value in dayTotalDates {
            let valueLegend = LegendEntry()
            valueLegend.label = value
            valueLegend.form = .circle
            valueLegend.formColor = barColours[index]
            barLegendEntries.append(valueLegend)
            index = index  + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (CGFloat(UIScreen.main.bounds.height) - CGFloat(64))
        //(tableView.bounds.height - tableView.contentInset.top - tableView.contentInset.bottom)
    }

//    // MARK: Prepare Segue
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }
}
