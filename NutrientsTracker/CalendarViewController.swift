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

    //MARK: Properties
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

    //MARK: IBOutlets
    @IBOutlet weak var addDate: UIButton!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the calendar delegate and data source
        calendar.calendarDelegate = self
        calendar.calendarDataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup the calendar
        setupCalendar()
        // Get the existing dayTotal dates
        getExistingDates()
        // DEBUG MESSAGE
        print("Total dates in use: \(dates.count)")
    }
    
    //MARK: IBActions
    @IBAction func useDateAction(_ sender: UIButton) {
        // Create the new DayTotal with the selected date
        let dayTotal = DayTotalRepository.createNewDayTotal(dayTotalDate: selectedDate!)
        // Store the created DayTotal inside the selectedDayTotal variable
        selectedDayTotal = dayTotal
        // Perform Segue to the DaySetupViewController
        performSegue(withIdentifier: "DaySetup", sender: self)
    }
    
    //MARK: Helper Functions
    func getExistingDates(){
        // Clear the dates array
        dates.removeAll()
        // Convert and store the dayTotal dates to an array with string dates
        dates = ConverterService.convertDayTotalArrayToDateStringArray(dayTotals: dayTotals)
    }
    
    func configureCell(cell: JTAppleCell?, cellState: CellState){
        // Check if the customCell is valid
        guard let customCell = cell as? CustomCell else {return}
        // Setup cell color
        handleCellTextColor(cell: customCell, cellState: cellState)
        // Setup cell selection
        handleCellSelection(cell: customCell, cellState: cellState)
        // Setup cell visibility
        handleCellVisibility(cell: customCell, cellState: cellState)
        // Setup cell events
        handleCellEvents(cell: customCell, cellState: cellState)
    }
    
    func handleCellTextColor(cell: CustomCell, cellState: CellState){
        // Configure cell text color when selecting the cell
        cell.dateLabel.textColor = cellState.isSelected ? UIColor.black : UIColor.white
    }
    
    func handleCellVisibility(cell: CustomCell, cellState: CellState){
        // Configure the visible cell dates for the current month
        cell.isHidden = cellState.dateBelongsTo == .thisMonth ? false: true
    }
    
    func handleCellSelection(cell: CustomCell, cellState: CellState){
        // Configure cell selection when a cell is selected display the selection view if not hide the selection view
        cell.selectedView.isHidden = cellState.isSelected ? false: true
    }
    
    func handleCellEvents(cell: CustomCell, cellState: CellState){
        // Configure event when the cell date is found inside the dates array by marking the cell
        cell.redDot.isHidden = !dates.contains(ConverterService.formatDateToString(dateValue: cellState.date))
    }
    
    func checkForAvailableDates() {
        // Check if the dates array contains the selected date
        if dates.contains(ConverterService.formatDateToString(dateValue: selectedDate!)){
            // If a match was found disable the add button
            addDate.isEnabled = false
            // Change the button title color to black
            addDate.setTitleColor(UIColor.black,for: UIControl.State.normal)
            
        }else {
            // If no match was found enable the add button
            addDate.isEnabled = true
            // Change the button title color to white
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
        // Select the current calendar date
        calendar.selectDates([Date()])
    }
    
    func setupCalendarView(from visibleDates: DateSegmentInfo) {
        let datesOnScreen = visibleDates.monthDates.first?.date
        // Format to display only the year
        dateFormatter.dateFormat = "yyyy"
        // Set the year label and update if the calendar year changes
        yearLabel.text = dateFormatter.string(from: datesOnScreen!)
        // Format to display only the month
        dateFormatter.dateFormat = "MMMM"
        // Set the month label and update if the calendar month changes
        monthLabel.text = dateFormatter.string(from: datesOnScreen!)
    }
    
    //MARK: Segue Prepare
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
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CustomCell
        // Set the cell labels
        cell.dateLabel.text = cellState.text
        // Configure the cell
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        configureCell(cell: cell, cellState: cellState)
        // Store the selected cell date inside the selectedDate variable
        selectedDate = date
        // Check if the selected date is available
        checkForAvailableDates()
        // DEBUG MESSAGE
        print("Selected date: \(ConverterService.formatDateToString(dateValue: selectedDate ?? Date() ))")
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        // Setup deselecting a cell
        configureCell(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        // Set the cell date label
        cell.dateLabel.text = cellState.text
        // Configure the cell
        configureCell(cell: cell, cellState: cellState)
        // Return the cell
        return cell
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        // Set a global start date
        let startDate = dateFormatter.date(from: "01 01 2018")
        // Set a global end date
        let endDate = dateFormatter.date(from: "01 01 2030")
        // Setup the calendar begining and ending
        let  parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        // return the parameters
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        // Setup scrolling through the months
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
