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
    @IBOutlet weak var entryTable: UITableView!
    @IBOutlet weak var pastDaysOverview: UIBarButtonItem!
    
    //MARK: Properties
    var emailFromUser:String = ""
    var currentUser:User?
    var dayTotals:[DayTotal] = []
    var selectedDayTotal:DayTotal?
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTable.rowHeight = 45;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if there is a signed in user
        checkSingedInUser()
        // Check if the signed in user was found inside the database
        checkDatabaseForUser()
        // Check if the signed in user has DayTotal objects
        checkForExistingUserDayTotals()
    }
    
    //MARK: IBActions
    @IBAction func unwindToDateSelection(_ sender:UIStoryboardSegue) {}
    
    //MARK: Helper Functions
    func deleteDayTotal(dayTotalToDelete:DayTotal,index:IndexPath) {
        // Delete the selected product inside the context
        PersistenceService.context.delete(dayTotalToDelete)
        // Save context changes
        PersistenceService.saveContext()
        // Delete the selected product from the products array
        self.dayTotals.remove(at: index.row)
        // Delete the prouct from the table with a fade animation
        self.entryTable.deleteRows(at: [index], with: .fade)
        checkForExistingUserDayTotals()
    }
    
    private func checkForExistingUserDayTotals() {
        // Check if the current user has DayTotals
        if currentUser != nil {
            // Covert the NSSet DayTotals to an array with DayTotals
            dayTotals = ConverterService.convertNSDayTotalsSetToDayTotalArray(dayTotalNSSet:(currentUser?.dayTotals)!)
            // Reload the date table
            entryTable.reloadData()
        }
        if dayTotals.count > 0 {
            // DEBUG MESSAGE
            print("Day totals found: \(dayTotals.count)")
            for dayTotal in dayTotals {
                if dayTotal.produtcs?.count ?? 0 > 0 {
                    pastDaysOverview.isEnabled = true
                    return
                }
            }
        }else{
            // DEBUG MESSAGE
            print("No day totals found for current user")
            pastDaysOverview.isEnabled = false
        }
    }
    
    private func checkSingedInUser(){
        // Check if there is already a signed in user
        if AuthenticationService.checkSignedInUser() {
            let userMail = AuthenticationService.getSignedInUserEmail()
            if userMail != "" {
                // When a signed in user is found store the user email inside a variable
                emailFromUser = userMail
                // DEBUG MESSAGE
                // print("User \(emailFromUser) is singed in")
            }
        }else {
            // DEBUG MESSAGE
            // print("No users are singed in now ")
        }
    }
    
    private func checkDatabaseForUser() {
        // Create a fetchRequest to find a matching user with the signed in email
        currentUser = UserRepository.fetchUserByEmail(email: emailFromUser)
    }
    
    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table
        // When delete gesture is made call delete style
        if editingStyle == .delete {
            // Select the dayTotal with the row index from the table
            let selection = dayTotals[indexPath.row]
            deleteDayTotal(dayTotalToDelete: selection, index: indexPath)
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
        guard let cell = entryTable.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath) as? DateTableViewCell else { return UITableViewCell() }
        // Add the date string value to the cell label
        cell.dateLabel.text = ConverterService.formatDateToString(dateValue: dayTotal.date!)
        cell.dayTotalCountLabel.text = "\(dayTotal.produtcs?.count ?? 0)"
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
        // If the segue destination is the ProductViewController
        if currentUser != nil && segue.destination is CalendarViewController{
            // Pass the selectedProduct to the ProductViewController
            let calendarVc = segue.destination as? CalendarViewController
            calendarVc?.currentUser = currentUser
            calendarVc?.dayTotals = dayTotals
        }
    }
}

//    private func convertNSDayTotalsSetToDayTotalArray(){
//        // Store the CurrentUser DayTotals inside a NSSet variable
//        let nsSet:NSSet = (currentUser?.dayTotals)!
//        // Convert the NSSet objects to a DayTotal array
//        dayTotals = nsSet.allObjects as! [DayTotal]
//        // Sort the array by date descending
//        dayTotals.sort { (dayTotalOne, dayTotalTwo) -> Bool in
//            return dayTotalOne.date?.compare(dayTotalTwo.date!) == ComparisonResult.orderedDescending
//        }
//        // Reload the table
//        entryTable.reloadData()
//    }

//    private func checkSingedInUser(){
//        // Check if there is already a signed in user
//        if Auth.auth().currentUser != nil {
//            if let user =  Auth.auth().currentUser?.email{
//                // When a signed in user is found store the user email inside a variable
//                self.emailFromUser = user
//                print("User \(emailFromUser) is singed in")
//            }
//        }else {
//            print("No users are singed in now ")
//        }
//    }

//            // Delete the selected dayTotal inside the context
//            PersistenceService.context.delete(selection)
//            // Save context changes
//            PersistenceService.saveContext()
//            // Delete the selected dayTotal from the dayTotals array
//            self.dayTotals.remove(at: indexPath.row)
//            // Delete the dayTotal from the table with a fade animation
//            self.entryTable.deleteRows(at: [indexPath], with: .fade)

//    private func checkDatabaseForUser() {
//        // Create a fetchRequest to find a matching user with the signed in email
//        let userFetch = NSFetchRequest<User>(entityName: "User")
//        // Initialize a predicate email must match with user email
//        userFetch.predicate = NSPredicate(format:"email == %@", emailFromUser)
//        do {
//            // Access the database and retrieve the matching user
//            if let matchingUser = try (PersistenceService.context.fetch(userFetch).first){
//                currentUser = matchingUser
//                // DEBUG MESSAGE
//                print("User found with email: \(currentUser?.email ?? "")")
//                print("User has \(currentUser?.dayTotals?.count ?? 0) daytotals")
//            }else {
//                // When no match was found add the new user to the database
//                let newUser = User(context: PersistenceService.context)
//                // Add the signed in email to the new user object
//                newUser.email = emailFromUser
//                // Save context changes
//                PersistenceService.saveContext()
//                // Store the new user value inside the currentUser property
//                currentUser = newUser
//                // DEBUG MESSAGE
//                print("Added new user with email \(emailFromUser)")
//            }
//        }catch{
//            print("Could not fetch \(error)")
//        }
//    }
