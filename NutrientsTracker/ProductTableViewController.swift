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
    var localProductNames:[String] = []
    var qrStringProduct:String?
    
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
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check the triggered product display mode
        checkDisplayMode()
    }
    
    //MARK: IBActions
    @IBAction func unwindToProductTable(_ sender:UIStoryboardSegue) {
        // Check if the sender source is valid
        guard let QRScannerVc = sender.source as? QRScannerViewController else { return }
        // Store the qrString value inside a variable
        qrStringProduct = QRScannerVc.qrString
        // Check if the qrString value isn't nil
        if qrStringProduct != nil {
            // Import the product by the qrString value
            importProductFormQRCode()
        }else {
            // DEBUG MESSAGE
            print("No QR product data found")
        }
    }
    
    @IBAction func resetAction(_ sender: UIBarButtonItem) {
        // Resets the form
        resetForm()
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
        // End current editing mode and dismisses the keyboard
        view.endEditing(true)
        // Retrieve and store the local product names inside the localProductNames array
        localProductNames = ProductRepository.fetchLocalProductNames()
        // Check if the localProductNames array contains the new product name
        if !localProductNames.contains(nameValue.lowercased()){
            // If not creates the new product
            createProduct()
            // Save context changes
            PersistenceService.saveContext()
            // DEBUG MESSAGE
            print("New local product added")
        } else {
            // DEBUG MESSAGE
            print("No local product added")
        }
        // Reset the form
        resetForm()
    }
    
    //MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case proteinTextfield:
            // Validate the user input
            if ValidationService.decimalValidator(value: proteinTextfield.text!){
                // Convert and store the validated value from string to double and store it inside a variable
                proteinValue = ConverterService.convertStringToDouble(string: proteinTextfield.text!)
                // Display the converted value inside the textField with 2 decimals
                proteinTextfield.text = ConverterService.convertDoubleToString(double: proteinValue)
                
            }else {
                // If validation was failed set the variable and textfield values with a default value
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
                // Store value inside a variable
                nameValue = nameTextfield.text!
                // Dismisses the keyboard
                nameTextfield.resignFirstResponder()
                // Enable the saveButton
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
                // Disable the saveButton
                saveButton.isEnabled = false
                // Clear the nameTextField value
                nameTextfield.text = ""
                // Set the nameTextfield placeholder
                nameTextfield.placeholder = "No valid value"
                // Reassign the keyboard
                nameTextfield.becomeFirstResponder()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Switch between textfields
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
        // When the image picker finishes retrieve the original image value from the infoKey
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            // Display the image inside the imageView
            imageView.image = image as? UIImage
            // Convert image to NSData to store inside the database
            imageData = (image as! UIImage).pngData() as NSData?
            // Dismisses the image picker viewController
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Helper Functions
    func importProductFormQRCode(){
        // Store and seperate the qrStringProduct by the given seperator
        let productDetails = qrStringProduct?.split(separator: "/")
        // Check if the value contains 7 seperated parts
        if productDetails?.count == 7 {
            // Setup all nutrient values with the 7 parts
            nameValue = String(productDetails![0])
            proteinValue = ConverterService.convertStringToDouble(string: String(productDetails![1]))
            fatValue = ConverterService.convertStringToDouble(string: String(productDetails![2]))
            fiberValue = ConverterService.convertStringToDouble(string: String(productDetails![3]))
            saltValue = ConverterService.convertStringToDouble(string: String(productDetails![4]))
            carbohydratesValue = ConverterService.convertStringToDouble(string: String(productDetails![5]))
            kilocalorieValue = ConverterService.convertStringToDouble(string: String(productDetails![6]))
            // Setup all the textfields with there values
            nameTextfield.text = nameValue
            proteinTextfield.text = ConverterService.convertDoubleToString(double: proteinValue)
            fatTextfield.text = ConverterService.convertDoubleToString(double: fatValue)
            fiberTextfield.text = ConverterService.convertDoubleToString(double: fiberValue)
            saltTextfield.text = ConverterService.convertDoubleToString(double: saltValue)
            carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: carbohydratesValue)
            kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: kilocalorieValue)
            // Enable the saveButton
            saveButton.isEnabled = true
        }
    }
    
    func createProduct(){
        // Create a new product with the stored values
        let product = Product(context: PersistenceService.context)
        product.name = nameValue
        product.kilocalories = kilocalorieValue
        product.carbohydrates = carbohydratesValue
        product.protein = proteinValue
        product.fat = fatValue
        product.salt = saltValue
        product.fiber = fiberValue
        // Check if the imageData isn't nil
        if imageData != nil {
            // If not nil convert image to Data value
            product.image = imageData! as Data
        }else {
            // If nil load the defaultImage and convert it to Data value
            if let img = UIImage(named: "DefaultImage") {
                product.image = img.pngData()
            }
        }
    }
    
    private func checkDisplayMode() {
        // Check if the nameValue is empty
        if nameValue.isEmpty{
            // Disable the saveButton
            saveButton.isEnabled = false
        }
        // Check if the viewProduct is nil
        if viewProduct != nil {
            // If not display the viewProduct
            displayTheViewProduct()
            // Disable the scanButton
            scanButton.isEnabled = false
        // Check if the viewConsumedProduct is nil
        } else if viewConsumedProduct != nil {
            // If not display the viewConsumedProduct
            displayTheViewConsumedProduct()
            // Disable the scanButton
            scanButton.isEnabled = false
        }
    }
    
    private func disableTextfields() {
        // Disable all the textfields
        proteinTextfield.isEnabled          = false
        fatTextfield.isEnabled              = false
        fiberTextfield.isEnabled            = false
        saltTextfield.isEnabled             = false
        carbohydratesTextfield.isEnabled    = false
        kilocalorieTextfield.isEnabled      = false
        nameTextfield.isEnabled             = false
    }
    
    private func displayTheViewProduct() {
        // Disable the resetButton
        resetButton.isEnabled = false
        // Display the viewProduct values inside the textfields
        proteinTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.protein ?? 0.00)+"g"
        fatTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.fat ?? 0.00)+"g"
        fiberTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.fiber ?? 0.00)+"g"
        saltTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.salt ?? 0.00)+"g"
        carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.carbohydrates ?? 0.00)+"g"
        kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: viewProduct?.kilocalories ?? 0.00)+"kcal"
        nameTextfield.text = viewProduct?.name
        // Check if the viewProduct has a valid image
        if let img = viewProduct?.image as Data? {
            // Convert the data value to image and display it inside the imageView
            imageView.image = UIImage(data:img)
        }
        // Disable the textfields
        disableTextfields()
    }
    
    private func displayTheViewConsumedProduct() {
        // Disable the resetButton
        resetButton.isEnabled = false
        // Display the viewConsumedProduct values inside the textfields
        proteinTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.protein ?? 0.00)+"g"
        fatTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.fat ?? 0.00)+"g"
        fiberTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.fiber ?? 0.00)+"g"
        saltTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.salt ?? 0.00)+"g"
        carbohydratesTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.carbohydrates ?? 0.00)+"g"
        kilocalorieTextfield.text = ConverterService.convertDoubleToString(double: viewConsumedProduct?.kilocalories ?? 0.00)+"kcal"
        nameTextfield.text = viewConsumedProduct?.name
        // Check if the viewConsumedProduct has a valid image
        if let img = viewConsumedProduct?.image as Data? {
            // Convert the data value to image and display it inside the imageView
            imageView.image = UIImage(data:img)
        }
        // Disable the textfields
        disableTextfields()
    }
    
    func resetForm() {
        // Clear all nutrient variables
        proteinValue = 0.0
        fatValue = 0.0
        fiberValue = 0.0
        carbohydratesValue = 0.0
        saltValue = 0.0
        kilocalorieValue = 0.0
        nameValue = ""
        imageData = nil 
        // Clear all the textfields with empty strings
        proteinTextfield.text = ""
        fatTextfield.text = ""
        fiberTextfield.text = ""
        carbohydratesTextfield.text = ""
        saltTextfield.text = ""
        kilocalorieTextfield.text = ""
        nameTextfield.text = ""
        // Load the default image
        imageView.image = UIImage(named: "DefaultImage")
        // Disable the saveButton
        saveButton.isEnabled = false
    }
}
