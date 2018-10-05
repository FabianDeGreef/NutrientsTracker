//
//  DateViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import FirebaseAuth

class DateViewController: UIViewController, UITableViewDelegate {

    //MARK: IBOutlet
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var entryTable: UITableView!
    
    //MARK: Properties
    var date:Date!

    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        date = datePicker.date
        printDate()
        printUser()
    }
    
    //MARK: IBActions
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    @IBAction func addNewEntry(_ sender: UIBarButtonItem) {
        if date != nil {
            printDate()
            performSegue(withIdentifier: "DayEntrySetup", sender: self)
        }
    }

    //MARK: Helper Functions
    private func printDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy"
        let stringDate = dateFormatter.string(from: date)
        print(stringDate)
    }
    
    private func printUser(){
        if Auth.auth().currentUser != nil {
            if let user =  Auth.auth().currentUser?.email{
                print("user \(user) is singed in")
            }
        }else {
            
        }
    }
    
    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
