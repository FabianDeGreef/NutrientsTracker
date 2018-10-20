//
//  ProductTableViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 16/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class ProductTableViewController: UITableViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    //MARK: Properties
    var fiberValue:Double = 0.0
    var fatValue:Double = 0.0
    var proteinValue:Double = 0.0
    var saltValue:Double = 0.0
    var carbohydratesValue:Double = 0.0
    var kilocalorieValue:Double = 0.0
    var nameValue:String = ""
    var viewProduct:Product?
    var viewConsumedProduct:ConsumedProduct?
    var imageData:NSData?
    
    //MARK: IBOutlets
    @IBOutlet weak var resetButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var proteinTextfield: UITextField!
    @IBOutlet weak var fatTextfield: UITextField!
    @IBOutlet weak var fiberTextfield: UITextField!
    @IBOutlet weak var saltTextfield: UITextField!
    @IBOutlet weak var carbohydratesTextfield: UITextField!
    @IBOutlet weak var kilocalorieTextfield: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK: View Functions
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
    @IBAction func resetAction(_ sender: UIBarButtonItem) {
        // Resets the form
        resetForm()
    }
    
    @IBAction func scanAction(_ sender: UIBarButtonItem) {
        
    }
    
    @IBAction func selectImageAction(_ sender: UITapGestureRecognizer) {
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
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        // Creates and save the new product
        createProduct()
        // Save context changes
        PersistenceService.saveContext()
        // Reset the form
        resetForm()
    }
    
    //MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case proteinTextfield:
            // Validate the user input
            if ValidationService.decimalValidator(value: proteinTextfield.text!){
                // Convert the validated value from string to double and store it inside the property
                proteinValue = ConverterService.convertStringToDouble(string: proteinTextfield.text!)
                // Display the converted value inside the textField with 2 decimals
                proteinTextfield.text = ConverterService.convertDoubleToString(double: proteinValue)
                
            }else {
                // If validation was failed set the property and textField with a default value
                proteinValue = 0.0
                proteinTextfield.text = String("0,00")
            }
        case fatTextfield:
            if ValidationService.decimalValidator(value: fatTextfield.text!){
                fatValue = ConverterService.convertStringToDouble(string: fatTextfield.text!)
                fatTextfield.text = ConverterService.convertDoubleToString(double: fatValue)
            }else {
                fatValue = 0.0
                fatTextfield.text = String("0,00")
            }
        case fiberTextfield:
            if ValidationService.decimalValidator(value: fiberTextfield.text!){
                fiberValue = ConverterService.convertStringToDouble(string: fiberTextfield.text!)
                fiberTextfield.text = ConverterService.convertDoubleToString(double: fiberValue)
            }else {
                fiberValue = 0.0
                fiberTextfield.text = String("0,00")
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
                // Set placeholder
                nameTextfield.placeholder = "No valid value"
                // Reopen the keyboard
                nameTextfield.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Use the return keyboard button to jump between textfields
        switch textField {
        case nameTextfield:
            nameTextfield.resignFirstResponder()
        case proteinTextfield:
            // Make the next textfield first responder
            fatTextfield.becomeFirstResponder()
        case fatTextfield:
            // Make the next textfield first responder
            fiberTextfield.becomeFirstResponder()
        case fiberTextfield:
            // Make the next textfield first responder
            saltTextfield.becomeFirstResponder()
        case saltTextfield:
            // Make the next textfield first responder
            carbohydratesTextfield.becomeFirstResponder()
        case carbohydratesTextfield:
            // Make the next textfield first responder
            kilocalorieTextfield.becomeFirstResponder()
        default:
            // Dismisses the keyboard
            kilocalorieTextfield.resignFirstResponder()
            
        }
        return true
    }
    
    //MARK: UIImagePickerController Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // take the original image value from the info when the image picker did finish
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            // Store the orginal image inside the imageView
            imageView.image = image as? UIImage
            // Convert image to NSData to store inside the database
            imageData = (image as! UIImage).pngData() as NSData?
            // Dismisses the image picker viewController
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Helper functions
    func createProduct(){
        // Create a new product with the values form values
        let product = Product(context: PersistenceService.context)
        product.name = nameValue
        product.kilocalories = kilocalorieValue
        product.carbohydrates = carbohydratesValue
        product.protein = proteinValue
        product.fat = fatValue
        product.salt = saltValue
        product.fiber = fiberValue
        if imageData != nil {
            product.image = imageData! as Data
        }
    }
    
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
        proteinTextfield.isEnabled = false
        fatTextfield.isEnabled = false
        fiberTextfield.isEnabled = false
        saltTextfield.isEnabled = false
        carbohydratesTextfield.isEnabled = false
        kilocalorieTextfield.isEnabled = false
        nameTextfield.isEnabled = false
    }
    
    private func displayTheViewProduct() {
//        titleLabel.text = "Nutrient values for 100 gram"
        resetButton.isEnabled = false
        proteinTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.protein ?? 0.00)
        fatTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.fat ?? 0.00)
        fiberTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.fiber ?? 0.00)
        saltTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.salt ?? 0.00)
        carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.carbohydrates ?? 0.00)
        kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.kilocalories ?? 0.00)
        nameTextfield.text = viewProduct?.name
        if let img = viewProduct?.image as Data? {
            imageView.image = UIImage(data:img)
        }
        disableTextfields()
    }
    
    private func displayTheViewConsumedProduct() {
//        let stringWeight = ConverterService.convertDoubleToString(double:viewConsumedProduct?.weight ?? 0.00)
//        titleLabel.text = "Nutrient values for " + stringWeight + " gram"
        resetButton.isEnabled = false
        proteinTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.protein ?? 0.00)
        fatTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.fat ?? 0.00)
        fiberTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.fiber ?? 0.00)
        saltTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.salt ?? 0.00)
        carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.carbohydrates ?? 0.00)
        kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.kilocalories ?? 0.00)
        nameTextfield.text = viewConsumedProduct?.name
        if let img = viewConsumedProduct?.image as Data? {
            imageView.image = UIImage(data:img)
        }
        disableTextfields()
    }
    
    func resetForm() {
        // Clear the variable
        proteinValue = 0.0
        fatValue = 0.0
        fiberValue = 0.0
        carbohydratesValue = 0.0
        saltValue = 0.0
        kilocalorieValue = 0.0
        nameValue = ""
        // Clear button to clear all the textfields with empty strings
        proteinTextfield.text = ""
        fatTextfield.text = ""
        fiberTextfield.text = ""
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
