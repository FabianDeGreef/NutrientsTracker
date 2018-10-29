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

    // MARK: IBOutlets
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
        // Convert the dayTotal dates to string array dates
        getExistingDates()
        // DEBUG MESSAGE
        print("Total dates in use: \(dates.count)")
    }
    
    // MARK: IBActions
    @IBAction func useDateAction(_ sender: UIButton) {
        // Create the new DayTotal with the selected date
        let dayTotal = DayTotalRepository.createNewDayTotal(dayTotalDate: selectedDate!)
        // Store the created DayTotal inside the selectedDayTotal variable
        selectedDayTotal = dayTotal
        // Perform Segue to the DaySetupViewController
        performSegue(withIdentifier: "DaySetup", sender: self)
    }
    
    // MARK: Helper Functions
    func getExistingDates(){
        // Clear the dates array
        dates.removeAll()
        // Get the string date values from the DayTotal array
        dates = ConverterService.convertDayTotalArrayToDateStringArray(dayTotals: dayTotals)
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
        // Check if the date array contains the selected date
        if dates.contains(ConverterService.formatDateToString(dateValue: selectedDate!)){
            // If a match was found disable the add button
            addDate.isEnabled = false
            addDate.setTitleColor(UIColor.black,for: UIControl.State.normal)
            
        }else {
            // If no match was found enable the add button
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
        // Display the correct calendar page based on the currentDate
        calendar.scrollToDate(currentDate!, animateScroll: false)
        // Select the current day
        calendar.selectDates([Date()])
    }
    
    func setupCalendarView(from visibleDates: DateSegmentInfo) {
        // Set the month label when the correct calendar page is displayed
        let datesOnScreen = visibleDates.monthDates.first?.date
        dateFormatter.dateFormat = "yyyy"
        yearLabel.text = dateFormatter.string(from: datesOnScreen!)
        // Set the year label when the correct calendar page is displayed
        dateFormatter.dateFormat = "MMMM"
        monthLabel.text = dateFormatter.string(from: datesOnScreen!)
    }
    
    // MARK: Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue destination is the DaySetupViewController
        if segue.destination is DaySetupViewController {
            let daySetupVc = segue.destination as? DaySetupViewController
            // Set the currentDayTotal with the selectedDayTotal value
            daySetupVc?.currentDayTotal = selectedDayTotal
        }
    }
}
extension CalendarViewController: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    // Setup cell displaying
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CustomCell
        cell.dateLabel.text = cellState.text
        configureCell(cell: cell, cellState: cellState)
    }
    
    // Setup selecting cell
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        // Store the selected cell date inside the selectedDate variable
        selectedDate = date
        // Check if the selected date is available
        checkForAvailableDates()
        // DEBUG MESSAGE
        print("Selected date: \(ConverterService.formatDateToString(dateValue: selectedDate ?? Date() ))")
    }
    
    // Setup deselecting cell
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
    }
    
    // Setup cell display
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        // Set the cell date label
        cell.dateLabel.text = cellState.text
        // Configure the cell
        configureCell(cell: cell, cellState: cellState)
        // Return the cell
        return cell
    }
    
    // Setup cell datasource
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Sets a global start date
        let startDate = dateFormatter.date(from: "01 01 2018")
        // Sets a global end date
        let endDate = dateFormatter.date(from: "01 01 2020")
        // Setup the calendar begin and ending
        let  parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        // returns the parameters
        return parameters
    }
    
    // Setup scrolling through the months
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupCalendarView(from: visibleDates)
    }
}

//        // Create new DayTotal object
//        let dayTotal = DayTotal(context: PersistenceService.context)
//        // Sets the new DayTotal date value with the property value
//        dayTotal.date = selectedDate
//        if currentUser != nil {
//            // Add the DayTotal object tot the currentUser
//            currentUser!.addToDayTotals(dayTotal)
//            // Save context changes
//            PersistenceService.saveContext()
//            // Store the new DayTotal object inside the selectedDayTotal property
//            selectedDayTotal = dayTotal
//            dayTotals.append(dayTotal)
//            // Display the DayTotalSetupViewController using the DayTotalSetup segue identifier
//            performSegue(withIdentifier: "DaySetup", sender: self)
//        }

//        // Clear the array every time
//        dates.removeAll()
//        // If dayTotals is not empty
//        if dayTotals.count > 0 {
//            // Loop through the dayTotals
//            for day in dayTotals {
//                // Insert and convert the date objects to string values
//                dates.append(ConverterService.formatDateToString(dateValue: day.date!))
//            }
//        }
