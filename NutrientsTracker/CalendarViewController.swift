//
//  CalendarViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 13/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController, UICollectionViewDelegate {

    // MARK: Properties
    var currentUser:User?
    var selectedDayTotal:DayTotal?
    var dayTotals:[DayTotal] = []
    var dates:[String] = []
    var currentDate:Date?
    var selectedDate:Date?

    let dateFormatter: DateFormatter =  {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yy"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        return dateFormatter
    }()

    // MARK: IBOutlet
    @IBOutlet weak var addDate: UIButton!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    
    // MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.calendarDelegate = self
        calendar.calendarDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup the calendar and current date
        setupCalendar()
        // Convert the dayTotal dates to a string array dates
        convertDatesToStringArray()
        // DEBUG MESSAGE
        print("Total dates in use: \(dates.count)")
    }
    
    // MARK: IBAction
    @IBAction func useDateAction(_ sender: UIButton) {
        if selectedDate != nil {
            // Create new DayTotal object
            let dayTotal = DayTotal(context: PersistenceService.context)
            // Sets the new DayTotal date value with the property value
            dayTotal.date = selectedDate
            if currentUser != nil {
                // Add the DayTotal object tot the currentUser
                currentUser!.addToDayTotals(dayTotal)
                // Save context changes
                PersistenceService.saveContext()
                // Store the new DayTotal object inside the selectedDayTotal property
                selectedDayTotal = dayTotal
                dayTotals.append(dayTotal)
                // Display the DayTotalSetupViewController using the DayTotalSetup segue identifier
                performSegue(withIdentifier: "DaySetup", sender: self)
            }
        }
    }
    
    // MARK: Helper Functions
    func convertDatesToStringArray(){
        // Clear the array every time
        dates.removeAll()
        // If dayTotals is not empty
        if dayTotals.count > 0 {
            // Loop through the dayTotals
            for day in self.dayTotals {
                // Insert and convert the date objects to string values
                dates.append(ConverterService.formatDateToString(dateValue: day.date!))
            }
        }
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState){
        guard let customCell = cell as? CustomCell else {return}
        handleCellTextColor(cell: customCell, cellState: cellState)
        handleCellSelection(cell: customCell, cellState: cellState)
        handleCellVisibility(cell: customCell, cellState: cellState)
        handleCellEvents(cell: customCell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: CustomCell, cellState: CellState){
        cell.dateLabel.textColor = cellState.isSelected ? UIColor.black : UIColor.white
    }
    
    func handleCellVisibility(cell: CustomCell, cellState: CellState){
        cell.isHidden = cellState.dateBelongsTo == .thisMonth ? false: true
    }
    
    func handleCellSelection(cell: CustomCell, cellState: CellState){
        cell.selectedView.isHidden = cellState.isSelected ? false: true
    }
    
    func handleCellEvents(cell: CustomCell, cellState: CellState){
        cell.redDot.isHidden = !dates.contains(ConverterService.formatDateToString(dateValue: cellState.date))
    }
    
    func checkForAvailableDates() {
        // Check if the array contains the selected date
        if dates.contains(ConverterService.formatDateToString(dateValue: selectedDate!)){
            // If a match was found disable the add button
            addDate.isEnabled = false
            addDate.setTitleColor(UIColor.black,for: UIControl.State.normal)
            
        }else {
            // if no match was found enable the add button
            addDate.isEnabled = true
            addDate.setTitleColor(UIColor.white,for: UIControl.State.normal)
        }
    }
    
    func setupCalendar(){
        // Setup the current visible dates
        calendar.visibleDates{ (visibleDates ) in
            self.setupCalendarView(from: visibleDates)
        }
        // Store the current date inside a variable
        currentDate = Date()
        // Let the calendar scroll to the current date with no animation
        calendar.scrollToDate(currentDate!, animateScroll: false)
        // Select the current day inside the callendar
        calendar.selectDates([Date()])
    }
    
    func setupCalendarView(from visibleDates: DateSegmentInfo) {
        // Set the month and year label by the visible dates
        let datesOnScreen = visibleDates.monthDates.first?.date
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: datesOnScreen!)
        
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: datesOnScreen!)
    }
    
    // MARK: Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the currentDayTotal to the DaySetupViewController
        if segue.destination is DaySetupViewController {
            let daySetupVc = segue.destination as? DaySetupViewController
            daySetupVc?.currentDayTotal = selectedDayTotal
        }
    }
}
extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CustomCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        selectedDate = date
        checkForAvailableDates()
        // DEBUG MESSAGE
        print("Selected date: \(ConverterService.formatDateToString(dateValue: selectedDate ?? Date() ))")
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    // Cell display
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
        return cell
    }
    
    // Cell datasource
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let startDate = dateFormatter.date(from: "01 01 2018")
        let endDate = dateFormatter.date(from: "01 01 2020")
        let  parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
    
    // Scrolling through months
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView(from: visibleDates)
    }
}
