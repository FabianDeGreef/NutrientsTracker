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
    var date:Date!
    var userEmail:String = ""
    var currentUser:User?
    var users:[User] = []
    var dayTotals:[DayTotal] = []
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        date = datePicker.date
        checkSingedInUser()
        checkDatabaseForUser()
        checkForExistingUserDayTotals()
        checkForExistingDates()
    }
    
    //MARK: IBActions
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        date = sender.date
        checkForExistingDates()
    }
    
    @IBAction func addNewEntry(_ sender: UIBarButtonItem) {
        if date != nil {
            let dayTotal = DayTotal(context: PersistenceService.context)
            dayTotal.date = date
            currentUser?.addToDayTotals(dayTotal)
            PersistenceService.saveContext()
            performSegue(withIdentifier: "DayEntrySetup", sender: self)
        }
    }
    
    @IBAction func signOffUser(_ sender: UIBarButtonItem) {
        if AuthenticationService.signOffUser() {
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK: Helper Functions
    private func checkForExistingDates() {
        if dayTotals.count == 0 {
            addButton.isEnabled = true
        }else {
            for value in dayTotals{
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                if dateFormatter.string(from: value.date!) == dateFormatter.string(from: date)  {
                    addButton.isEnabled = false
                    return
                }else {
                    addButton.isEnabled = true
                }
            }
        }
    }
    
    private func checkForExistingUserDayTotals() {
        if currentUser?.dayTotals?.count != 0 {
            let nsSetData:NSSet = (currentUser?.dayTotals)!
            dayTotals = nsSetData.allObjects as! [DayTotal]
            dayTotals.sort { (dayTotalOne, dayTotal2) -> Bool in
                return dayTotalOne.date?.compare(dayTotal2.date!) == ComparisonResult.orderedAscending
            }
            entryTable.reloadData()
        }else{
            print("no dates found")
        }
    }
    
    private func printDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let stringDate = dateFormatter.string(from: date)
        print(stringDate)
    }
    
    private func checkSingedInUser(){
        if Auth.auth().currentUser != nil {
            if let user =  Auth.auth().currentUser?.email{
                self.userEmail = user
                print("user \(userEmail) is singed in")
            }
        }else {
            print("No users are singed in")
        }
    }
    
    private func checkDatabaseForUser() {
        // Create the fetchRequest to find the user that matches with the email
        let userFetch = NSFetchRequest<User>(entityName: "User")
        // Initialize a predicate to use with the fetchRequest (Fetch user email must be equal with logged in email)
        userFetch.predicate = NSPredicate(format:"email == %@", userEmail)
        do {
            // Access the store to retrieve the matching user
            if let userData = try (PersistenceService.context.fetch(userFetch).first){
                currentUser = userData
                //currentUser?.dayTotals?.adding(DayTotal(context: PersistenceService.context))
                print(currentUser?.email ?? "")
                print(currentUser?.dayTotals?.count ?? "")
            }else {
                // First time setup when a new user is registerd the email will be added to the datbase
                print("Adding new user")
                // Save user to database
                // Create User object
                let newUser = User(context: PersistenceService.context)
                // Add the stored email to the user object
                newUser.email = userEmail
                // save the changes made inside the context
                PersistenceService.saveContext()
            }
        }catch{
            print("Could not fetch. \(error)")
        }
    }
    
    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table (Delete)
        // When delete gesture is made call style delete
        if editingStyle == .delete {
            // Select the product on the current selected index inside the table
            let selection = dayTotals[indexPath.row]
            // Delete the selected product inside the context
            PersistenceService.context.delete(selection)
            // Save all the changes inside the context
            PersistenceService.saveContext()
            // Delete the selected product form the current found products array
            self.dayTotals.remove(at: indexPath.row)
            // Delete the product from the UITableView with the fade animation
            self.entryTable.deleteRows(at: [indexPath], with: .fade)
            // Check if the removed date can be accesed again
            self.checkForExistingDates()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the total size from the products array to calculate the numbers of rows needed
        return dayTotals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Thake the product from every index value inside the prodcuts array
        let dayTotal = dayTotals[indexPath.row]
        // Create a cell that is reusable for every index
        let cell = entryTable.dequeueReusableCell(withIdentifier: "DateCell", for: indexPath)
        // Give the cell textlabel a value
        //cell.textLabel!.text = product.value(forKeyPath: "name") as? String
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let stringDate = dateFormatter.string(from: dayTotal.date!)
        cell.textLabel!.text = stringDate
        // return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a user select an index form the table the UIAlertView opens with the 4 options and gets access to the selected value at the moment
    }
    
    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
