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
    var context:NSManagedObjectContext?
    var sugarValue:String?
    var fatValue:String?
    var cholesterolValue:String?
    var saltValue:String?
    var carbohydratesValue:String?
    var kilocalorieValue:String?
    var nameValue:String?
    
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
        accessContext()
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
        createProduct()
        // Change the cancel buttons name to return because the save was succesfull
        cancelButton.title = "Return"
    }
    
    @IBAction func cancelChanges(_ sender: UIBarButtonItem) {
        // Return to the other view by pop this view form the view stack
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearForm(_ sender: UIBarButtonItem) {
        // Clear button to clear all the textfields with empty strings
        sugarTextfield.text = ""
        fatTextfield.text = ""
        cholesterolTextfield.text = ""
        carbohydratesTextfield.text = ""
        saltTextfield.text = ""
        kilocalorieTextfield.text = ""
        nameTextfield.text = ""
    }
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Use the return keyboard button to jump between textfields
        switch textField {
        case sugarTextfield:
            // Checks the textfield text value inside the checkForDecimalInput method to validate the text contains only numbers and or coma. This switch case checks every textfield inside this ViewController
            if checkForDecimalInput(value: sugarTextfield.text!){
                // Set the propertie value with the validated one form the textfield
                sugarValue = sugarTextfield.text
                // Make the next textfield first responder
                fatTextfield.becomeFirstResponder()
            }
        case fatTextfield:
            if checkForDecimalInput(value: fatTextfield.text!){
                fatValue = fatTextfield.text
                cholesterolTextfield.becomeFirstResponder()
            }
        case cholesterolTextfield:
            if checkForDecimalInput(value: cholesterolTextfield.text!){
                cholesterolValue = cholesterolTextfield.text
                saltTextfield.becomeFirstResponder()
            }
        case saltTextfield:
            if checkForDecimalInput(value: saltTextfield.text!){
                saltValue = saltTextfield.text
                carbohydratesTextfield.becomeFirstResponder()
            }
        case carbohydratesTextfield:
            if checkForDecimalInput(value: carbohydratesTextfield.text!){
                carbohydratesValue = carbohydratesTextfield.text
                kilocalorieTextfield.becomeFirstResponder()
            }
        case kilocalorieTextfield:
            if checkForDecimalInput(value: kilocalorieTextfield.text!){
                kilocalorieValue = kilocalorieTextfield.text
                nameTextfield.becomeFirstResponder()
            }
        default:
            // Checks the name value from the nametextfield with an other validator functions so it contains only alpabetical input
            if checkForAlphabeticalInput(value: nameTextfield.text!){
                // Set the propertie value with the validated one form the textfield
                nameValue = nameTextfield.text
                // Dissmis the keyboard be resinging the first responder now because the name textfield was the last one
                nameTextfield.resignFirstResponder()
            }
        }
        return true
    }
    
    //MARK: Core Date Functions
    func createProduct(){
        // Create an entity constant from the type product
        let entity = NSEntityDescription.entity(forEntityName: "Product", in: context!)!
        // Create a product object to insert the values inside the context
        let product = NSManagedObject(entity: entity, insertInto: context)
        // Check the properties with the values from the textfields are not nill
        if (nameValue != nil) {
            // Sets the key for the value that wil be inserted in the product object that now will be created inside the context
            product.setValue(nameValue, forKey: "name")
        }
        if (kilocalorieValue != nil) {
            product.setValue(kilocalorieValue, forKey: "kilocalories")
        }
        if (carbohydratesValue != nil) {
            product.setValue(carbohydratesValue, forKey: "carbohydrates")
        }
        if (saltValue != nil) {
            product.setValue(saltValue, forKey: "salt")
        }
        if (cholesterolValue != nil) {
            product.setValue(cholesterolValue, forKey: "cholesterol")
        }
        if (fatValue != nil) {
            product.setValue(fatValue, forKey: "fat")
        }
        if (sugarValue != nil) {
            product.setValue(sugarValue, forKey: "sugar")
        }
        // Call the saveContext function to save the inserted object in the context
        saveContext()
    }
    
    func saveContext(){
        do {
            // Save all the changes made to the context
            try context!.save()
        }catch let error as NSError {
            print("Could not save \(error)")
        }
    }
    
    func accessContext(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        context = appDelegate.persistentContainer.viewContext
    }

    //MARK: UIImagePickerController Delegates
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Get the value form the infokey and thake the Orginal image
        if let image = info[UIImagePickerController.InfoKey.originalImage] {
            // Place the value from the orginal image inside the ImageView to display the image
            imageView.image = image as? UIImage
            // Dismisses the image picker controller screen
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: Helper functions
    private func checkForDecimalInput(value:String) -> Bool{
        // Check the incomming string if it is a decimal value and return true or false
        if !value.isEmpty && value.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil {
            return true
        }else {
            return false
        }
    }
    
    private func checkForAlphabeticalInput(value:String) -> Bool {
        // Check the incomming string if it is an alphabetical value and return true or false
        if !value.isEmpty && value.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) != nil {
            return true
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
