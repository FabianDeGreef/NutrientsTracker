//
//  WeightViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 19/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class WeightViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    var weight: Double = 0.0

    //MARK: IBOutlets
    @IBOutlet weak var weightTextfield: UITextField!
    @IBOutlet weak var weightButton: UIButton!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Switch to the weight textfield and open the keyboard
        weightTextfield.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Set the weightButton tile text color from white to black when the view will appear
        weightButton.setTitleColor(UIColor.black,for: UIControl.State.normal)
    }
    
    @IBAction func unwindToDaySetup(_sender: Any){
        // Dismisses the keyboard
        weightTextfield.resignFirstResponder()
        // Check if the weight is higher than 0.0
        if weight > 0.0 {
            // Start button animation
            startWeightButtonAnimation()
            // Wait 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                // Perform Segue to the DaySetupViewController
                self.performSegue(withIdentifier: "ReturnDaySetup", sender: self)
            }
        }else {
            // DEBUG MESSAGE
            print("Weight was invalid")
        }
    }
    
    //MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Validate the weight value
        if ValidationService.decimalValidator(value: weightTextfield.text!){
            // Convert the validated value from string to double and store it inside a varibale
            weight = ConverterService.convertStringToDouble(string: weightTextfield.text!)
            // Display the converted value inside the textField with 2 decimals
            weightTextfield.text = ConverterService.convertDoubleToString(double: weight)
            // If validation was succesfull enable the weightButton
            weightButton.isEnabled = true
            // Set the weightButton title text color from black to white
            weightButton.setTitleColor(UIColor.white,for: UIControl.State.normal)
            // Change button background color
            weightButton.backgroundColor = UIColor.init(named: "FiberColor")
            // Start button animation
            pulseButtonAnimation()
        }else {
            // If validation was failed set the variable and textField with a default value
            weight = 0.0
            // Clear the textfield
            weightTextfield.text = ""
            // Set the textfield placeholder
            weightTextfield.placeholder = "Enter valid weight"
            // Set the weightButton title text color to black
            weightButton.setTitleColor(UIColor.black,for: UIControl.State.normal)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Dismisses the keyboard when return was pressed
        weightTextfield.resignFirstResponder()
        return true
    }
    
    //MARK: Helper Functions
    func startWeightButtonAnimation() {
        // Start button animation
        weightButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: { self.weightButton.transform = CGAffineTransform.identity }, completion: nil )
    }
    
    func pulseButtonAnimation() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        // Set the pulse speed
        pulse.duration = 0.3
        // Set the pulse starting value
        pulse.fromValue = 0.95
        // Set the pulse ending value
        pulse.toValue = 1.0
        // Set the pulse autoreverse to true
        pulse.autoreverses = true
        // Set animation repeats
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.9
        pulse.damping = 1.0
        // Add animation to the button
        weightButton.layer.add(pulse, forKey: nil)
    }
        
    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Pass the weight to the DaySetupViewController
        let daySetupVc = segue.destination as! DaySetupViewController
        daySetupVc.weight = weight
    }
}
