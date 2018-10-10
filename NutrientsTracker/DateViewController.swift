//
//  DateViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreData

class DateViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: IBOutlet
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    //MARK: Properties
    var dateFromPicker:Date!
    var emailFromUser:String = ""
    var currentUser:User?
    var users:[User] = []
    var dayTotals:[DayTotal] = []
    var selectedDayTotal:DayTotal?
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the table delegate to the current ViewController
        entryTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Take the datePicker value and store it inside the dateFromPicker variable
        dateFromPicker = datePicker.date
        // Check if there is a signed in user
        checkSingedInUser()
        // Check if the signed in user was found inside the database
        checkDatabaseForUser()
        // Check if the signed in user has DayTotal objects
        checkForExistingUserDayTotals()
        // Check which dates are available to create a DayTotal
        checkForAvailableDates()
    }
    
    //MARK: IBActions
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        dateFromPicker = sender.date
        // Check if the picked date isn't used by an existing DayTotal
        checkForAvailableDates()
    }
    
    @IBAction func addNewEntry(_ sender: UIBarButtonItem) {
        // Create new DayTotal object
        let dayTotal = DayTotal(context: PersistenceService.context)
        // Sets the new DayTotal date value with the property value
        dayTotal.date = dateFromPicker
        if currentUser != nil {
            // Add the DayTotal object tot the currentUser
            currentUser!.addToDayTotals(dayTotal)
            // Save context changes
            PersistenceService.saveContext()
            // Store the new DayTotal object inside the selectedDayTotal property
            selectedDayTotal = dayTotal
            // Display the DayTotalSetupViewController using the DayTotalSetup segue identifier
            performSegue(withIdentifier: "DayTotalSetup", sender: self)
        }
    }
    
    @IBAction func signOffUser(_ sender: UIBarButtonItem) {
        // Sign out the current user
        if AuthenticationService.signOffUser() {
            // Return back to the LoginViewController by popping the other views
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK: Helper Functions
    // When the datePicker change event triggers check if the changed date has been already used by the DayTotals
    private func checkForAvailableDates() {
        // Loop through the DayTotals array to check which date isn't used
        for dayTotal in dayTotals{
            // Convert every DayTotal date to the string value
            let stringDate = formatDateToString(dateValue: dayTotal.date!)
            // Check if the string values are equal witht the string value from the dateFromPicker
            if stringDate == formatDateToString(dateValue: dateFromPicker){
                // If a match was found disable the add button
                addButton.isEnabled = false
                return
            }else {
                // if no match was found enable the add button
                addButton.isEnabled = true
            }
        }
    }
    
    private func checkForExistingUserDayTotals() {
        // Check if the current user has DayTotals
        if currentUser != nil && currentUser?.dayTotals?.count != 0 {
            // Covert the NSSet DayTotals to an array with DayTotals
            convertNSDayTotalsSetToDayTotalArray()
        }else{
            print("No dayTotals found in current user")
        }
    }
    
    private func convertNSDayTotalsSetToDayTotalArray(){
        // Store the CurrentUser DayTotals inside a NSSet variable
        let nsSet:NSSet = (currentUser?.dayTotals)!
        // Convert the NSSet objects to a DayTotal array
        dayTotals = nsSet.allObjects as! [DayTotal]
        // Sort the array by date descending
        dayTotals.sort { (dayTotalOne, dayTotal2) -> Bool in
            return dayTotalOne.date?.compare(dayTotal2.date!) == ComparisonResult.orderedDescending
        }
        // Reload the table
        entryTable.reloadData()

    }
    
    private func checkSingedInUser(){
        // Check if there is already a signed in user
        if Auth.auth().currentUser != nil {
            if let user =  Auth.auth().currentUser?.email{
                // When a signed in user is found store the user email inside a variable
                self.emailFromUser = user
                print("User \(emailFromUser) is singed in")
            }
        }else {
            print("No users are singed in now ")
        }
    }
    
    func formatDateToString(dateValue:Date) -> String{
        // Create a datefromatter
        let dateFormatter = DateFormatter()
        // Setting the dateformat
        dateFormatter.dateFormat = "MM/dd/yy"
        dateFormatter.dateStyle = .short
        // Convert the DayTotal dates to a string value using the datefromatter
        let stringDate = dateFormatter.string(from: dateValue)
        return stringDate
    }
    
    private func checkDatabaseForUser() {
        // Create a fetchRequest to find a matching user with the signed in email
        let userFetch = NSFetchRequest<User>(entityName: "User")
        // Initialize a predicate email must match with user email
        userFetch.predicate = NSPredicate(format:"email == %@", emailFromUser)
        do {
            // Access the database and retrieve the matching user
            if let matchingUser = try (PersistenceService.context.fetch(userFetch).first){
                currentUser = matchingUser
                // DEBUG MESSAGE
                print("User found with email: \(currentUser?.email ?? "")")
                print("User has \(currentUser?.dayTotals?.count ?? 0) daytotals")
            }else {
                // When no match was found add the new user to the database
                let newUser = User(context: PersistenceService.context)
                // Add the signed in email to the new user object
                newUser.email = emailFromUser
                // Save context changes
                PersistenceService.saveContext()
                // Store the new user value inside the currentUser property
                currentUser = newUser
                // DEBUG MESSAGE
                print("Added new user with email \(emailFromUser)")
            }
        }catch{
            print("Could not fetch \(error)")
        }
    }
    
    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table
        // When delete gesture is made call delete style
        if editingStyle == .delete {
            // Select the dayTotal with the row index from the table
            let selection = dayTotals[indexPath.row]
            // Delete the selected dayTotal inside the context
            PersistenceService.context.delete(selection)
            // Save context changes
            PersistenceService.saveContext()
            // Delete the selected dayTotal from the dayTotals array
            self.dayTotals.remove(at: indexPath.row)
            // Delete the dayTotal from the table with a fade animation
            self.entryTable.deleteRows(at: [indexPath], with: .fade)
            // Recalculate the available dates to choose from
            self.checkForAvailableDates()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the DayTotals array size to calculate the numbers of rows needed
        return dayTotals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Take the DayTotal from every index value inside the DayTotals array
        let dayTotal = dayTotals[indexPath.row]
        // Create a cell that is reusable with the identified cell name
        let cell = entryTable.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath)
        // Add the date string value to the cell label
        cell.textLabel!.text = formatDateToString(dateValue: dayTotal.date!)
        cell.detailTextLabel?.text = "Consumed prodcuts: \(dayTotal.produtcs?.count ?? 0)"
        // returning the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  set the selectedDayTotal variable to the selected value form the table
        selectedDayTotal = dayTotals[indexPath.row]
        performSegue(withIdentifier: "DayTotalSetup", sender: self)
    }
    
    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the currentDayTotal to the DaySetupViewController
        if segue.destination is DaySetupViewController {
            let daySetupVc = segue.destination as? DaySetupViewController
            daySetupVc?.currentDayTotal = selectedDayTotal
        }
    }
}
