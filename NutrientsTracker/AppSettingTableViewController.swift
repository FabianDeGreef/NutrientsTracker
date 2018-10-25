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

class AppSettingTableViewController: UITableViewController {

    //MARK: Properties
    var exsistingProducts:[String] = []
    var exsistingCloudProducts:[String] = []
    var imageUrlString:[String] = []
    var uploadImageUrlString:[String] = []
    var products:[Product] = []
    var oudateProducts:[Product] = []
    var newProducts:[Product] = []

    var count:Int = 0
    var databaseRef:DatabaseReference?
    var databaseHandle:DatabaseHandle?
    var storageRef:StorageReference?
    var storage:Storage?
    
    var productName:String = ""
    var proteinValue:Double = 0.0
    var kiloCalorieValue:Double = 0.0
    var saltValue:Double = 0.0
    var fiberValue:Double = 0.0
    var carbohydrateValue:Double = 0.0
    var fatValue:Double = 0.0
    var productImage:NSData?
    
    //MARK: View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        getCloudProducts()
    }
    
    //MARK: IBActions
    @IBAction func signOutAction(_ sender: UIButton) {
        signOutUser()
    }
    
    @IBAction func importAction(_ sender: UIButton) {
        fetchExistingProdcuts()
        databaseRef = Database.database().reference()
        databaseRef?.child("Products").observe(.value, with: { (data) in
            if data.exists(){
                guard let products = data.value as? NSDictionary else {return}
                for product in products {
                    guard let productData = product.value as? NSDictionary else {return}
                    self.productName = productData["ProductName"] as? String ?? ""
                    print(self.productName)
                    if !self.exsistingProducts.contains(self.productName){
                    self.kiloCalorieValue = ConverterService.convertStringToDouble(string: productData["Kilocalorie"] as? String ?? "0,0")
                    self.carbohydrateValue = ConverterService.convertStringToDouble(string: productData["Carbohydrate"] as? String ?? "0,0")
                    self.proteinValue = ConverterService.convertStringToDouble(string: productData["Protein"] as? String ?? "0,0")
                    self.fatValue = ConverterService.convertStringToDouble(string: productData["Fat"] as? String ?? "0,0")
                    self.saltValue = ConverterService.convertStringToDouble(string: productData["Salt"] as? String ?? "0,0")
                    self.fiberValue = ConverterService.convertStringToDouble(string: productData["Fiber"] as? String ?? "0,0")
                    self.imageUrlString.append(productData["ImageUrl"] as? String ?? "")
                    self.createNewProduct()
                    }
                }
            }
            var count = 0
            for product in self.newProducts {
                self.downloadProductImages(product: product, index: count)
                count = count + 1
            }
        })
    }
    
    func uploadOutDateProduct(){
        count = exsistingCloudProducts.count
        for product in oudateProducts {
            storageRef = Storage.storage().reference()
            let fileName = "ProductImages/\(product.name!).png"
            let fileUpload = storageRef?.child(fileName)
            fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
                if error != nil {
                    return
                }
                fileUpload!.downloadURL { (url, error) in
                    if url != nil {
                        let stringUrl:String = (url?.absoluteString)!
                        print(stringUrl)
                        let data = [
                            "ProductName" : product.name!,
                            "Protein" : ConverterService.convertDoubleToString(double: product.protein) ,
                            "Carbohydrate" : ConverterService.convertDoubleToString(double: product.carbohydrates),
                            "Kilocalorie" : ConverterService.convertDoubleToString(double: product.kilocalories),
                            "Salt" : ConverterService.convertDoubleToString(double: product.salt),
                            "Fat" : ConverterService.convertDoubleToString(double:  product.fat),
                            "Fiber" : ConverterService.convertDoubleToString(double: product.fiber),
                            "ImageUrl" : stringUrl
                            ] as [String: Any]
                        self.count = self.count + 1
                        let stringValue:String = "Product\(self.count)"
                        print(stringValue)
                        self.databaseRef?.child("Products").child(stringValue).setValue(data)
                    }
                }
            }
        }
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        uploadOutDateProduct()
    }
    
    func uploadProductImage(product:Product) {
        storageRef = Storage.storage().reference()
        let fileName = "ProductImages/\(product.name!).png"
        let fileUpload = storageRef?.child(fileName)
        // Upload the file to the path "images/rivers.jpg"
        
        fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
            if error != nil {
                return
            }
            // You can also access to download URL after upload.
            fileUpload!.downloadURL { (url, error) in
                if url != nil {
                    let stringUrl:String = (url?.absoluteString)!
                    print(stringUrl)
                    self.uploadImageUrlString.append(stringUrl)
                }
            }
        }
    }
    
    @IBAction func resetAction(_ sender: UIButton) {
        deleteDateByEntity(entity: "Product")
    }
    
    @IBAction func cleanAppAction(_ sender: UIButton) {
        deleteDateByEntity(entity: "Product")
        deleteDateByEntity(entity: "ConsumedProduct")
        deleteDateByEntity(entity: "DayTotal")
        deleteDateByEntity(entity: "User")
        signOutUser()
    }
    
    // MARK: Helper Functions
    func signOutUser() {
        // Sign out the current user
        if AuthenticationService.signOffUser() {
            // Return back to the LoginViewController by popping the other views
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    func getCloudProducts(){
        databaseRef = Database.database().reference()
        databaseRef?.child("Products").observe(.value, with: { (data) in
            if data.exists(){
                guard let products = data.value as? NSDictionary else {return}
                for product in products {
                    guard let productData = product.value as? NSDictionary else {return}
                    self.exsistingCloudProducts.append (productData["ProductName"] as? String ?? "")
                }
            }
            self.fetchExistingProdcuts()

            for product in self.products{
                if !self.exsistingCloudProducts.contains(product.name!){
                    self.oudateProducts.append(product)
                }
            }
            print(self.oudateProducts.count)

        })

    }
    func createNewProduct(){
        // Create the imported product
        let product = Product(context: PersistenceService.context)
        product.name = productName
        product.kilocalories = kiloCalorieValue
        product.carbohydrates = carbohydrateValue
        product.protein = proteinValue
        product.fat = fatValue
        product.salt = saltValue
        product.fiber = fiberValue
        newProducts.append(product)
    }
    
    func downloadProductImages(product:Product, index:Int) {
        storageRef = Storage.storage().reference()
        storage = Storage.storage()
        let imageDownload  = storage?.reference(forURL: imageUrlString[index])
        imageDownload?.getData(maxSize: 1 * 4092 * 4092, completion: { (data, error) in
            if data != nil {
                product.image = data!
                self.saveContext()
            }else {
                print("Error could not load image form web database")
            }
        })
    }
    
    func fetchExistingProdcuts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try PersistenceService.context.fetch(fetchRequest)
            for product in results {
                guard let productData = product as? Product else {continue}
                exsistingProducts.append(productData.name!)
                products.append(product as! Product)
             }
        }catch {
            print("Error Retrieving Entitys")
        }
    }
    
    func deleteDateByEntity(entity:String){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try PersistenceService.context.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                PersistenceService.context.delete(objectData)
            }
        }catch {
            print("Error Deleting Entitys")
        }
    }
    
    func saveContext(){
        // Save context changes
        PersistenceService.saveContext()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
