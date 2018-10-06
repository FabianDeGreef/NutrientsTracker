//
//  ProductViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 02/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    //MARK: Properties
    //var context:NSManagedObjectContext?
    var sugarValue:Double = 0.0
    var fatValue:Double = 0.0
    var cholesterolValue:Double = 0.0
    var saltValue:Double = 0.0
    var carbohydratesValue:Double = 0.0
    var kilocalorieValue:Double = 0.0
    var nameValue:String = ""
    
    //MARK: IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sugarTextfield: UITextField!
    @IBOutlet weak var fatTextfield: UITextField!
    @IBOutlet weak var cholesterolTextfield: UITextField!
    @IBOutlet weak var saltTextfield: UITextField!
    @IBOutlet weak var carbohydratesTextfield: UITextField!
    @IBOutlet weak var kilocalorieTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Sets the context value when the viewcontroller will display
        //accessContext()
        if nameValue.count < 1 {
            saveButton.isEnabled = false
        }
    }
    
    //MARK: IBActions
    @IBAction func imageClicked(_ sender: UITapGestureRecognizer) {
        // Create an ImagePickerController
        let imagePickerController = UIImagePickerController()
        // Make the current ViewController delegate over ImagePickerController actions
        imagePickerController.delegate = self
        // Create an UIAlertController actionSheet with 3 user options
        let actionSheet = UIAlertController(title: "Choose an option", message: "Thake a picure or select one", preferredStyle: .actionSheet)
        // Add the first actionSheet (Use Camera)
        actionSheet.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { (action: UIAlertAction) in
            // Check if the device has a camera source
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                // Get the device camera
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                // Display the camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else {
                // If no camera was found on the device an new UIAlertController will be displayed with the message and the photo library wil be choosen
                let alert = UIAlertController(title: "No Camera Was Found", message: "Please use your library instead", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                    // Get the photoLibrary
                    imagePickerController.sourceType = .photoLibrary
                    // Display the photoLibrary
                    self.present(imagePickerController, animated: true, completion: nil)
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }))
        // Add the second actionSheet (Library)
        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            // Get the photoLibrary
            imagePickerController.sourceType = .photoLibrary
            // Display the photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        // Add the third actionSheet (cancel)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Dismiss the UIAlertController view
        present(actionSheet,animated: true, completion: nil)
    }
    
    @IBAction func saveProduct(_ sender: UIBarButtonItem) {
        // Save product to database
        //let product = Product(context: context!)
        let product = Product(context: PersistenceService.context)
        product.name = nameValue
        product.kilocalories = kilocalorieValue
        product.carbohydrates = carbohydratesValue
        product.cholesterol = cholesterolValue
        product.fat = fatValue
        product.salt = saltValue
        product.sugar = sugarValue
        resetView()
        PersistenceService.saveContext()
        //saveContext()
    }
    
    @IBAction func cancelChanges(_ sender: UIBarButtonItem) {
        // Return to the other view by pop this view form the view stack
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearForm(_ sender: UIBarButtonItem) {
        resetView()
    }
    
    //MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case sugarTextfield:
            // Checks the textfield text value inside the checkForDecimalInput method to validate the text contains only numbers and or coma. This switch case checks every textfield inside this ViewController
            if checkForDecimalInput(value: sugarTextfield.text!){
                // Set the propertie value with the validated one form the textfield and convert it to a double with a comma
                sugarValue = decimal(string: sugarTextfield.text!)
                print(sugarValue)
            }else {
                sugarValue = 0.0
                sugarTextfield.text = String("0,0")
            }
        case fatTextfield:
            if checkForDecimalInput(value: fatTextfield.text!){
                fatValue = decimal(string: fatTextfield.text!)
                print(fatValue)
            }else {
                fatValue = 0.0
                fatTextfield.text = String("0,0")
            }
        case cholesterolTextfield:
            if checkForDecimalInput(value: cholesterolTextfield.text!){
                cholesterolValue = decimal(string: cholesterolTextfield.text!)
                print(cholesterolValue)
            }else {
                cholesterolValue = 0.0
                cholesterolTextfield.text = String("0,0")
            }
        case saltTextfield:
            if checkForDecimalInput(value: saltTextfield.text!){
                saltValue = decimal(string: saltTextfield.text!)
                print(saltValue)
            }else {
                saltValue = 0.0
                saltTextfield.text = String("0,0")
            }
        case carbohydratesTextfield:
            if checkForDecimalInput(value: carbohydratesTextfield.text!){
                carbohydratesValue = decimal(string: carbohydratesTextfield.text!)
                print(carbohydratesValue)
            }else {
                carbohydratesValue = 0.0
                carbohydratesTextfield.text = String("0,0")
            }
        case kilocalorieTextfield:
            if checkForDecimalInput(value: kilocalorieTextfield.text!){
                kilocalorieValue = decimal(string: kilocalorieTextfield.text!)
                print(kilocalorieValue)
            }else {
                kilocalorieValue = 0.0
                kilocalorieTextfield.text = String("0,0")
            }
        default:
            // Checks the name value from the nametextfield with an other validator functions so it contains only alpabetical input
            if checkForAlphabeticalInput(value: nameTextfield.text ?? ""){
                // Set the propertie value with the validated one form the textfield
                nameValue = nameTextfield.text!
                // Dissmis the keyboard be resinging the first responder now because the name textfield was the last one
                nameTextfield.resignFirstResponder()
                saveButton.isEnabled = true
            }else {
                // Show UIAlert message when name textfield is empty
                let alert = UIAlertController(title: "Choose a name", message: "Product must have a name and must be greater than 1 character", preferredStyle: .alert)
                // Create an action with a Ok button that after pressing dismisses the alert screen
                let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                }
                // Add the action with the ok button to the UIAlertContoller
                alert.addAction(action)
                // Show the UIAlert Message to the user that the product name must have a value
                present(alert, animated: true, completion: nil)
                saveButton.isEnabled = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Use the return keyboard button to jump between textfields
        switch textField {
        case sugarTextfield:
        // Make the next textfield first responder
                fatTextfield.becomeFirstResponder()
        case fatTextfield:
                cholesterolTextfield.becomeFirstResponder()
        case cholesterolTextfield:
                saltTextfield.becomeFirstResponder()
        case saltTextfield:
                carbohydratesTextfield.becomeFirstResponder()
        case carbohydratesTextfield:
                kilocalorieTextfield.becomeFirstResponder()
        case kilocalorieTextfield:
                nameTextfield.becomeFirstResponder()
        default:
        // Dissmis the keyboard be resinging the first responder now because the name textfield was the last one
                nameTextfield.resignFirstResponder()
        }
        return true
    }

    //MARK: UIImagePickerController Delegates
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the value form the infokey and thake the Orginal image
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            // Place the value from the orginal image inside the ImageView to display the image
            imageView.image = image as? UIImage
            // Dismisses the image picker controller screen
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Helper functions
    func resetView() {
        // Clear the variable
        sugarValue = 0.0
        fatValue = 0.0
        cholesterolValue = 0.0
        carbohydratesValue = 0.0
        saltValue = 0.0
        kilocalorieValue = 0.0
        nameValue = ""
        // Clear button to clear all the textfields with empty strings
        sugarTextfield.text = ""
        fatTextfield.text = ""
        cholesterolTextfield.text = ""
        carbohydratesTextfield.text = ""
        saltTextfield.text = ""
        kilocalorieTextfield.text = ""
        nameTextfield.text = ""
        // Set default image
        imageView.image = UIImage(named: "DefaultImage2")
        // Disable the save button
        saveButton.isEnabled = false
    }
    
    func decimal(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.generatesDecimalNumbers = true
        formatter.decimalSeparator = ","
        return formatter.number(from: string) as? Double ?? 0
    }
    
    private func checkForDecimalInput(value:String) -> Bool{
        // Check the incomming string if it is a decimal value and return true or false
        if !value.isEmpty && value.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil{
            return true
        }else {
            return false
        }
    }
    
    private func checkForAlphabeticalInput(value:String) -> Bool {
        // Check the incomming string if it is an alphabetical value and return true or false
        if !value.isEmpty && value.count > 1 {
            let letters = NSCharacterSet.letters
            let range = value.rangeOfCharacter(from: letters)
            if  range != nil {
               return true
            }else {
                return false
            }
        }else {
            return false
        }
    }
    
    // MARK: Segue Prepare
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
