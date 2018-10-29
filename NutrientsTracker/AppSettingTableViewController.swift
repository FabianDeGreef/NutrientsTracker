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
    
    //MARK: IBOutlets
    @IBOutlet weak var importTotalLabel: UILabel!
    @IBOutlet weak var exportTotalLabel: UILabel!
    @IBOutlet weak var kcalLimitTextfield: UITextField!
    
    //MARK: Properties
    var cloudProductRepo = CloudProductRepository()
    var kcalValue:Int = 0
    
    //MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForCloudAndLocalProductsChanges()
        checkUserSettings()
    }
    
    func checkUserSettings() {
        let userDefaults = UserDefaults.standard
        let value = userDefaults.integer(forKey: "kcalValue")
        kcalValue = value
        kcalLimitTextfield.text = String(value)
    }
    
    //MARK: IBActions
    @IBAction func signOutAction(_ sender: UIButton) {
        signOutUser()
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        cloudProductRepo.exportLocalProductsToCloud()
        showAlertAction(title: "Exporting products", message: "local products exported to cloud database")
    }
    
    @IBAction func importAction(_ sender: UIButton) {
        cloudProductRepo.importCloudProducts()
        showAlertAction(title: "Importing products", message: "Cloud products imported to local database")
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        PersistenceService.deleteDataByEntity(entity: "Product")
        saveContext()
        showAlertAction(title: "Removing local products", message: "The local products are removed")
    }
    
    @IBAction func cleanAppAction(_ sender: UIButton) {
        showAlertAction(title: "Removing all settings", message: "All app data wil be deleted")
        PersistenceService.deleteDataByEntity(entity: "Product")
        PersistenceService.deleteDataByEntity(entity: "ConsumedProduct")
        PersistenceService.deleteDataByEntity(entity: "DayTotal")
        PersistenceService.deleteDataByEntity(entity: "User")
        saveContext()
        signOutUser()
    }
    
    @IBAction func cleanUserDayTotals(_ sender: UIButton) {
        let userEmail = AuthenticationService.getSignedInUserEmail()
        let dayTotals = DayTotalRepository.fetchDayTotalsToDelete(email: userEmail)
        for dayTotal in dayTotals {
            PersistenceService.context.delete(dayTotal as! NSManagedObject)
        }
        saveContext()
        showAlertAction(title: "Removing day totals", message: "All current user day totals wil be deleted")
    }
    
    @IBAction func saveKcalLimit(_ sender: UIButton) {
        kcalLimitTextfield.resignFirstResponder()
        // Accessing user defaults
        let userDefaults = UserDefaults.standard
        // Setting user value
        userDefaults.set(kcalValue, forKey: "kcalValue")
        showAlertAction(title: "Saving kcal limit", message: "The new kcal limit wil be saved")
    }
    
    @IBAction func deleteConsumedProducts(_ sender: UIButton) {
        PersistenceService.deleteDataByEntity(entity: "ConsumedProduct")
        saveContext()
        showAlertAction(title: "Removing consumed produtcs", message: "All consumed products wil be deleted")
    }
    
    // MARK: Helper Functions
    func checkForCloudAndLocalProductsChanges() {
        cloudProductRepo.fetchCloudProducts{
            importExportTotal in
            self.importTotalLabel.text = "\(importExportTotal[1])"
            self.exportTotalLabel.text = "\(importExportTotal[0])"
        }
    }
    
    func signOutUser() {
        // Sign out the current user
        if AuthenticationService.signOffUser() {
            // Return back to the LoginViewController by popping the other views
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
        // Use the return keyboard button to jump between textfields

        switch textField {
        case kcalLimitTextfield:
            // Dismisses the keyboard
            kcalLimitTextfield.resignFirstResponder()
        default: break
        }
        return true
    }

    
    //    // MARK: - Navigation
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //    }
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

