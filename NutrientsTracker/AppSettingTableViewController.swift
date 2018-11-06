//
//  AppSettingTableViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 23/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import CoreData
import FirebaseDatabase
import Firebase

class AppSettingTableViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: Properties
    var cloudProductRepo = CloudProductRepository()
    var kcalValue:Int = 0

    //MARK: IBOutlets
    @IBOutlet weak var importTotalLabel: UILabel!
    @IBOutlet weak var importButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var exportTotalLabel: UILabel!
    @IBOutlet weak var kcalLimitTextfield: UITextField!
    @IBOutlet weak var currentUserLabel: UILabel!

    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Display the current user
        currentUserLabel.text = "Current User: " + UserDefaultsSettings.getUserEmail()
        // Check for local and online product changes
        checkForCloudAndLocalProductsChanges()
        // Access the stored kilocalorie limit value from the UserDefaults
        kcalValue = UserDefaultsSettings.getKilocalorieLimitValue()
        // Set the kilocalorie limit label text with the found value
        kcalLimitTextfield.text = String(UserDefaultsSettings.getKilocalorieLimitValue())
    }
    
    //MARK: IBActions
    @IBAction func signOutAction(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Sign out the user
        signOutUser()
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Upload local products to the cloud
        cloudProductRepo.exportLocalProductsToCloud()
        showAlertAction(title: "Exporting products", message: "local products exported to cloud database")
    }
    
    @IBAction func importAction(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Import online cloud products to the local database
        cloudProductRepo.importCloudProducts()
        showAlertAction(title: "Importing products", message: "Cloud products imported to local database")
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Delete all the local products
        PersistenceService.deleteDataByEntity(entity: "Product")
        saveContext()
        showAlertAction(title: "Removing local products", message: "The local products are removed")
    }
    
    @IBAction func cleanAppAction(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Delete all the products, consumedProducts, users and dayTotals
        //showAlertAction(title: "Removing all settings", message: "All app data wil be deleted")
        PersistenceService.deleteDataByEntity(entity: "Product")
        PersistenceService.deleteDataByEntity(entity: "ConsumedProduct")
        PersistenceService.deleteDataByEntity(entity: "DayTotal")
        PersistenceService.deleteDataByEntity(entity: "User")
        // Save the context changes
        saveContext()
        // Re enable the firstTimeSetup
        UserDefaultsSettings.reEnableFirstTimeSetup()
        // Sign out the user
        signOutUser()
    }
    
    @IBAction func cleanUserDayTotals(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Deletes current user dayTotals
        let dayTotals = DayTotalRepository.fetchDayTotalsToDelete(email: UserDefaultsSettings.getUserEmail())
        for dayTotal in dayTotals {
            PersistenceService.context.delete(dayTotal as! NSManagedObject)
        }
        saveContext()
        showAlertAction(title: "Removing day totals", message: "All current user day totals wil be deleted")
    }
    
    @IBAction func saveKcalLimit(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Dismisses the keyboard
        kcalLimitTextfield.resignFirstResponder()
        // Sets the kilicalorie limit user value
        UserDefaultsSettings.setKilocalorieLimitValue(valueLimit: kcalValue)
        showAlertAction(title: "Saving kcal limit", message: "The new kcal limit wil be saved")
    }
    
    @IBAction func deleteConsumedProducts(_ sender: UIButton) {
        //Start animation
        buttonAnimation(button: sender)
        // Delete user consumedProducts
        let dayTotals = DayTotalRepository.fetchDayTotalsByUserEmail(email: UserDefaultsSettings.getUserEmail())
        for dayTotal in dayTotals {
            dayTotal.fatTotal = 0
            dayTotal.fiberTotal = 0
            dayTotal.kilocaloriesTotal = 0
            dayTotal.proteinTotal = 0
            dayTotal.saltTotal = 0
            dayTotal.carbohydratesTotal = 0
            if let products = dayTotal.produtcs {
                for product in products {
                    PersistenceService.context.delete(product as! NSManagedObject)
                }
            }
        }
        // Save context changes
        saveContext()
        showAlertAction(title: "Removing consumed produtcs", message: "User consumed products wil be deleted")
    }
    
    //MARK: Helper Functions
    func buttonAnimation(button:UIButton) {
        // Start button animation
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: { button.transform = CGAffineTransform.identity }, completion: nil )
    }
    func checkForCloudAndLocalProductsChanges() {
        cloudProductRepo.fetchCloudProducts{
            // Check for cloud and local product count changes
            importExportTotal in
            // Set the import and export label with the values
            self.importTotalLabel.text = "\(importExportTotal[1])"
            self.exportTotalLabel.text = "\(importExportTotal[0])"
            // Disable or enable import button when products changes are found or not
            if (importExportTotal[1]) == 0 {
                self.importButton.isEnabled = false
            }else {
                self.importButton.isEnabled = true
            }
            // Disable or enable export button when products changes are found or not
            if (importExportTotal[0]) == 0 {
                self.exportButton.isEnabled = false
            }else {
                self.exportButton.isEnabled = true
            }
        }
    }
    
    func signOutUser() {
        // Sign out the current user
        if AuthenticationService.signOffUser() {
            // Return to the LoginViewController
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // Creates custom AlertAction to alert the user
    func showAlertAction(title: String, message: String){
        // Create the UIAlertController with the incoming parameters
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Create the UIAlertAction to display an OK button and dismisses the alert after it is pressed
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
            self.navigationController?.popViewController(animated: true)
        }
        // Adding the UIAlertAction to the UIAlertController
        alert.addAction(action)
        // Displaying the Alert
        present(alert, animated: true, completion: nil)
    }
    
    func saveContext(){
        // Save context changes
        PersistenceService.saveContext()
    }
    
    // MARK: UITextfield Delegates
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Check which textfield was end editing
        switch textField {
        case kcalLimitTextfield:
            // Validate the user input
            if ValidationService.numberValidator(value: kcalLimitTextfield.text!){
                // Convert the validated value from string to a number and store it inside the property
                kcalValue = Int(kcalLimitTextfield.text!)!
            }else {
                // If validation was failed set the property and textField with a default value
                kcalValue = 0
                kcalLimitTextfield.text = String("0")
            }
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Switch between textfields when using the return button
        switch textField {
        case kcalLimitTextfield:
            // Dismisses the keyboard
            kcalLimitTextfield.resignFirstResponder()
        default: break
        }
        return true
    }
}
    
    //    //MARK: Properties
    //    var exsistingProducts:[String] = []
    //    var exsistingCloudProducts:[String] = []
    //    var imageUrlString:[String] = []
    //    var uploadImageUrlString:[String] = []
    //    var products:[Product] = []
    //    var oudateProducts:[Product] = []
    //    var newProducts:[Product] = []
    //
    //    var count:Int = 0
    //    var databaseRef:DatabaseReference?
    //    var databaseHandle:DatabaseHandle?
    //    var storageRef:StorageReference?
    //    var storage:Storage?
    //
    //    var productName:String = ""
    //    var proteinValue:Double = 0.0
    //    var kiloCalorieValue:Double = 0.0
    //    var saltValue:Double = 0.0
    //    var fiberValue:Double = 0.0
    //    var carbohydrateValue:Double = 0.0
    //    var fatValue:Double = 0.0
    //    var productImage:NSData?
    
//    func importProduct() {
//        fetchExistingProdcuts()
//        databaseRef = Database.database().reference()
//        databaseRef?.child("Products").observe(.value, with: { (data) in
//            if data.exists(){
//                guard let products = data.value as? NSDictionary else {return}
//                for product in products {
//                    guard let productData = product.value as? NSDictionary else {return}
//                    self.productName = productData["ProductName"] as? String ?? ""
//                    print(self.productName)
//                    if !self.exsistingProducts.contains(self.productName){
//                        self.kiloCalorieValue
//                            = ConverterService.convertStringToDouble(string: productData["Kilocalorie"] as? String ?? "0,0")
//                        self.carbohydrateValue
//                            = ConverterService.convertStringToDouble(string: productData["Carbohydrate"] as? String ?? "0,0")
//                        self.proteinValue
//                            = ConverterService.convertStringToDouble(string: productData["Protein"] as? String ?? "0,0")
//                        self.fatValue
//                            = ConverterService.convertStringToDouble(string: productData["Fat"] as? String ?? "0,0")
//                        self.saltValue
//                            = ConverterService.convertStringToDouble(string: productData["Salt"] as? String ?? "0,0")
//                        self.fiberValue
//                            = ConverterService.convertStringToDouble(string: productData["Fiber"] as? String ?? "0,0")
//                        self.imageUrlString.append(productData["ImageUrl"] as? String ?? "")
//                        self.createNewProduct()
//                    }
//                }
//            }
//            var count = 0
//            for product in self.newProducts {
//                self.downloadProductImages(product: product, index: count)
//                count = count + 1
//            }
//        })
//    }
    
//    func uploadOutDateProduct(){
//        count = exsistingCloudProducts.count
//        for product in oudateProducts {
//            storageRef = Storage.storage().reference()
//            let fileName = "ProductImages/\(product.name!).png"
//            let fileUpload = storageRef?.child(fileName)
//            fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
//                if error != nil {
//                    return
//                }
//                fileUpload!.downloadURL { (url, error) in
//                    if url != nil {
//                        let stringUrl:String = (url?.absoluteString)!
//                        print(stringUrl)
//                        let data = [
//                            "ProductName" : product.name!,
//                            "Protein" : ConverterService.convertDoubleToString(double: product.protein) ,
//                            "Carbohydrate" : ConverterService.convertDoubleToString(double: product.carbohydrates),
//                            "Kilocalorie" : ConverterService.convertDoubleToString(double: product.kilocalories),
//                            "Salt" : ConverterService.convertDoubleToString(double: product.salt),
//                            "Fat" : ConverterService.convertDoubleToString(double:  product.fat),
//                            "Fiber" : ConverterService.convertDoubleToString(double: product.fiber),
//                            "ImageUrl" : stringUrl
//                            ] as [String: Any]
//                        self.count = self.count + 1
//                        let stringValue:String = "Product\(self.count)"
//                        print(stringValue)
//                        self.databaseRef?.child("Products").child(stringValue).setValue(data)
//                    }
//                }
//            }
//        }
//    }

//    func uploadProductImage(product:Product) {
//        storageRef = Storage.storage().reference()
//        let fileName = "ProductImages/\(product.name!).png"
//        let fileUpload = storageRef?.child(fileName)
//        // Upload the file to the path "images/rivers.jpg"
//
//        fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
//            if error != nil {
//                return
//            }
//            // You can also access to download URL after upload.
//            fileUpload!.downloadURL { (url, error) in
//                if url != nil {
//                    let stringUrl:String = (url?.absoluteString)!
//                    print(stringUrl)
//                    self.uploadImageUrlString.append(stringUrl)
//                }
//            }
//        }
//    }

//    func getCloudProducts(){
//        databaseRef = Database.database().reference()
//        databaseRef?.child("Products").observe(.value, with: { (data) in
//            if data.exists(){
//                guard let products = data.value as? NSDictionary else {return}
//                for product in products {
//                    guard let productData = product.value as? NSDictionary else {return}
//                    self.exsistingCloudProducts.append (productData["ProductName"] as? String ?? "")
//                }
//            }
//            self.fetchExistingProdcuts()
//
//            for product in self.products{
//                if !self.exsistingCloudProducts.contains(product.name!){
//                    self.oudateProducts.append(product)
//                }
//            }
//            print(self.oudateProducts.count)
//        })
//    }
    
//    func createNewProduct(){
//        // Create the imported product
//        let product = Product(context: PersistenceService.context)
//        product.name = productName
//        product.kilocalories = kiloCalorieValue
//        product.carbohydrates = carbohydrateValue
//        product.protein = proteinValue
//        product.fat = fatValue
//        product.salt = saltValue
//        product.fiber = fiberValue
//        newProducts.append(product)
//    }
    
//    func downloadProductImages(product:Product, index:Int) {
//        storageRef = Storage.storage().reference()
//        storage = Storage.storage()
//        let imageDownload  = storage?.reference(forURL: imageUrlString[index])
//        imageDownload?.getData(maxSize: 1 * 4092 * 4092, completion: { (data, error) in
//            if data != nil {
//                product.image = data!
//                self.saveContext()
//            }else {
//                print("Error could not load image form web database")
//            }
//        })
//    }
    
//    func fetchExistingProdcuts() {
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
//        fetchRequest.returnsObjectsAsFaults = false
//        do {
//            let results = try PersistenceService.context.fetch(fetchRequest)
//            for product in results {
//                guard let productData = product as? Product else {continue}
//                exsistingProducts.append(productData.name!)
//                products.append(product as! Product)
//             }
//        }catch {
//            print("Error retrieving entitys")
//        }
//    }

//    checkUserSettings()
//    func checkUserSettings() {
//        let userDefaults = UserDefaults.standard
//        let value = userDefaults.integer(forKey: "kcalValue")
//        kcalValue = value
//        kcalLimitTextfield.text = String(value)
//    }

//         // Accessing user defaults
//        let userDefaults = UserDefaults.standard
//        // Setting user value
//        userDefaults.set(kcalValue, forKey: "kcalValue")
