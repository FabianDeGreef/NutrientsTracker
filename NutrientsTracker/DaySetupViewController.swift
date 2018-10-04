//
//  DaySetupViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class DaySetupViewController: UIViewController{

    //MARK: Properties
    var productName:String?
    var weight:Decimal?
    
    //MARK: IBOutlets
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextfield: UITextField!
    
    //MARK:  IBActions
    @IBAction func searchProduct(_ sender: UIButton) {
        if !(nameTextField.text?.isEmpty)!{
            productName = nameTextField.text
        }
    }
    @IBAction func addToDayTotal(_ sender: UIButton) {
        if !(weightTextfield.text?.isEmpty)!{
            weight = Decimal(string: weightTextfield.text!)
            performSegue(withIdentifier: "DayEntrySetup", sender: self)
        }
    }
    
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddProduct", sender: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
