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
    var sugarValue:Double = 0.0
    var fatValue:Double = 0.0
    var cholesterolValue:Double = 0.0
    var saltValue:Double = 0.0
    var carbohydratesValue:Double = 0.0
    var kilocalorieValue:Double = 0.0
    var nameValue:String = ""
    var viewProduct:Product?
    var viewConsumedProduct:ConsumedProduct?
    
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
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Disable the save button when the view will appear
        if nameValue.isEmpty{
            saveButton.isEnabled = false
        }
        // Check if the user wants to view a product or consumed product
        checkDisplayMode()
    }
    
    //MARK: IBActions
    @IBAction func imageClicked(_ sender: UITapGestureRecognizer) {
        // Create an ImagePickerController
        let imagePickerController = UIImagePickerController()
        // Sets the ImagePickerController delegate to the current ViewController
        imagePickerController.delegate = self
        // Creates an actionSheet that contains 3 options
        let actionSheet = UIAlertController(title: "Choose an option", message: "Take a picure or select one", preferredStyle: .actionSheet)
        // Add the use camera action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { (action: UIAlertAction) in
            // Check if the current device has a camera source
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                // Get the device camera
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                // Display the camera view
                self.present(imagePickerController, animated: true, completion: nil)
            }else {
                // If the device has no camera display message and open library instead
                let alert = UIAlertController(title: "No Camera Was Found", message: "Please use your library instead", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (UIAlertAction) in
                    // Get the photoLibrary
                    imagePickerController.sourceType = .photoLibrary
                    // Display the photoLibrary view
                    self.present(imagePickerController, animated: true, completion: nil)
                })
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
            }
        }))
        // Add the use library action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Choose From Library", style: .default, handler: { (UIAlertAction) in
            // Get the photoLibrary
            imagePickerController.sourceType = .photoLibrary
            // Display the photoLibrary view
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        // Add the cancel action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Dismisses the UIAlertController view
        present(actionSheet,animated: true, completion: nil)
    }
    
    @IBAction func saveProduct(_ sender: UIBarButtonItem) {
        // Creates and save the new product
        createProduct()
        // Save context changes
        PersistenceService.saveContext()
        // Reset the form
        resetForm()
    }
    
    func createProduct(){
        // Create a new product with the values form values
        let product = Product(context: PersistenceService.context)
        product.name = nameValue
        product.kilocalories = kilocalorieValue
        product.carbohydrates = carbohydratesValue
        product.cholesterol = cholesterolValue
        product.fat = fatValue
        product.salt = saltValue
        product.sugar = sugarValue
    }
    
    @IBAction func clearForm(_ sender: UIBarButtonItem) {
        // Resets the form
        resetForm()
    }
    
    //MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case sugarTextfield:
            // Validate the user input
            if ValidationService.decimalValidator(value: sugarTextfield.text!){
                // Convert the validated value from string to double and store it inside the property
                sugarValue = ConverterService.convertStringToDouble(string: sugarTextfield.text!)
                // Display the converted value inside the textField with 2 decimals
                sugarTextfield.text = ConverterService.convertDoubleToString(double: sugarValue)
                
            }else {
                // If validation was failed set the property and textField with a default value
                sugarValue = 0.0
                sugarTextfield.text = String("0,00")
            }
        case fatTextfield:
            if ValidationService.decimalValidator(value: fatTextfield.text!){
                fatValue = ConverterService.convertStringToDouble(string: fatTextfield.text!)
                fatTextfield.text = ConverterService.convertDoubleToString(double: fatValue)
            }else {
                fatValue = 0.0
                fatTextfield.text = String("0,00")
            }
        case cholesterolTextfield:
            if ValidationService.decimalValidator(value: cholesterolTextfield.text!){
                cholesterolValue = ConverterService.convertStringToDouble(string: cholesterolTextfield.text!)
                cholesterolTextfield.text = ConverterService.convertDoubleToString(double: cholesterolValue)
            }else {
                cholesterolValue = 0.0
                cholesterolTextfield.text = String("0,00")
            }
        case saltTextfield:
            if ValidationService.decimalValidator(value: saltTextfield.text!){
                saltValue = ConverterService.convertStringToDouble(string: saltTextfield.text!)
                saltTextfield.text = ConverterService.convertDoubleToString(double: saltValue)
            }else {
                saltValue = 0.0
                saltTextfield.text = String("0,00")
            }
        case carbohydratesTextfield:
            if ValidationService.decimalValidator(value: carbohydratesTextfield.text!){
                carbohydratesValue = ConverterService.convertStringToDouble(string: carbohydratesTextfield.text!)
                carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: carbohydratesValue)
            }else {
                carbohydratesValue = 0.0
                carbohydratesTextfield.text = String("0,00")
            }
        case kilocalorieTextfield:
            if ValidationService.decimalValidator(value: kilocalorieTextfield.text!){
                kilocalorieValue = ConverterService.convertStringToDouble(string: kilocalorieTextfield.text!)
                kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: kilocalorieValue)
            }else {
                kilocalorieValue = 0.0
                kilocalorieTextfield.text = String("0,00")
            }
        default:
            // Validate the user input
            if ValidationService.alphabeticalValidator(value: nameTextfield.text ?? ""){
                // Set the property with the value
                nameValue = nameTextfield.text!
                // Dismisses the keyboard
                nameTextfield.resignFirstResponder()
                // Enable the save button
                saveButton.isEnabled = true
            }else {
                // Show UIAlert message when name validation failed
                let alert = UIAlertController(title: "Choose a name", message: "Product must have a name and must be greater than 1 character", preferredStyle: .alert)
                // Create an action with a OK button and dismisses the alert screen
                let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
                }
                // Add the action to the UIAlertController
                alert.addAction(action)
                // Display the UIAlert message
                present(alert, animated: true, completion: nil)
                // Disable the save button
                saveButton.isEnabled = false
                // Sets the nameTextField value to default
                nameTextfield.text = ""
                // Reopen the keyboard
                nameTextfield.becomeFirstResponder()
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
            // Make the next textfield first responder
                cholesterolTextfield.becomeFirstResponder()
        case cholesterolTextfield:
            // Make the next textfield first responder
                saltTextfield.becomeFirstResponder()
        case saltTextfield:
            // Make the next textfield first responder
                carbohydratesTextfield.becomeFirstResponder()
        case carbohydratesTextfield:
            // Make the next textfield first responder
                kilocalorieTextfield.becomeFirstResponder()
        case kilocalorieTextfield:
            // Make the next textfield first responder
                nameTextfield.becomeFirstResponder()
        default:
        // Dismisses the keyboard
            nameTextfield.resignFirstResponder()

        }
        return true
    }

    //MARK: UIImagePickerController Delegates
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take the original image value from the info when the image picker did finish
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            // Store the orginal image inside the imageView
            imageView.image = image as? UIImage
            // Dismisses the image picker viewController
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Helper functions
    private func checkDisplayMode() {
        // If the viewProduct is not nill prepare the view to display the product details
        if viewProduct != nil {
            displayTheViewProduct()
            // If the viewConsumedProduct is not nill prepare the view to display the viewConsumedProduct details
        } else if viewConsumedProduct != nil {
            displayTheViewConsumedProduct()
        }
    }
    
    private func disableTextfields() {
        sugarTextfield.isEnabled = false
        fatTextfield.isEnabled = false
        cholesterolTextfield.isEnabled = false
        saltTextfield.isEnabled = false
        carbohydratesTextfield.isEnabled = false
        kilocalorieTextfield.isEnabled = false
        nameTextfield.isEnabled = false
    }
    
    private func displayTheViewProduct() {
        titleLabel.text = "Nutrient values for 100 gram"
        resetButton.isEnabled = false
        sugarTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.sugar ?? 0.00)
        fatTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.fat ?? 0.00)
        cholesterolTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.cholesterol ?? 0.00)
        saltTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.salt ?? 0.00)
        carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.carbohydrates ?? 0.00)
        kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.kilocalories ?? 0.00)
        nameTextfield.text = viewProduct?.name
        disableTextfields()
    }
    
    private func displayTheViewConsumedProduct() {
        let stringWeight = ConverterService.convertDoubleToString(double:viewConsumedProduct?.weight ?? 0.00)
        titleLabel.text = "Nutrient values for " + stringWeight + " gram"
        sugarTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.protein ?? 0.00)
        fatTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.fat ?? 0.00)
        cholesterolTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.fiber ?? 0.00)
        saltTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.salt ?? 0.00)
        carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.carbohydrates ?? 0.00)
        kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.kilocalories ?? 0.00)
        nameTextfield.text = viewConsumedProduct?.name
        resetButton.isEnabled = false
        disableTextfields()
    }
    
    func resetForm() {
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
    
    // MARK: Segue Prepare
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //}
}
