//
//  WeightViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 19/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class WeightViewController: UIViewController, UITextFieldDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var weightTextfield: UITextField!
    @IBOutlet weak var weightButton: UIButton!
    
    // MARK: Properties
    var weight: Double = 0.0
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weightButton.setTitleColor(UIColor.black,for: UIControl.State.normal)
    }
    
    @IBAction func unwindToDaySetup(_sender: Any){
        weightTextfield.resignFirstResponder()
        if weight > 0.0 {
            performSegue(withIdentifier: "ReturnDaySetup", sender: self)
        }
    }
    
    // MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ValidationService.decimalValidator(value: weightTextfield.text!){
            // Convert the validated value from string to double and store it inside the property
            weight = ConverterService.convertStringToDouble(string: weightTextfield.text!)
            // Display the converted value inside the textField with 2 decimals
            weightTextfield.text = ConverterService.convertDoubleToString(double: weight)
            // If validation was succesfull enable the add weight button
            weightButton.isEnabled = true
            weightButton.setTitleColor(UIColor.white,for: UIControl.State.normal)

        }else {
            // If validation was failed set the property and textField with a default value
            weight = 0.0
            // Clear the textfield
            weightTextfield.text = ""
            // Set the textfield placeholder
            weightTextfield.placeholder = "Enter valid weight"
            weightButton.setTitleColor(UIColor.black,for: UIControl.State.normal)

        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        weightTextfield.resignFirstResponder()
        return true
    }
    
    // MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let daySetupVc = segue.destination as! DaySetupViewController
        daySetupVc.weight = weight
    }
}
