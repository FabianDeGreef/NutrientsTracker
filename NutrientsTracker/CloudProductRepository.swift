//
//  CloudProductRepository.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 27/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation
import CoreData
import FirebaseDatabase
import Firebase

class CloudProductRepository {
    
    var exsistingCloudProductsNames:[String] = []
    var exsistingLocalProductNames:[String] = []
    var importFromCloudProducts:[String] = []

    var exsistingLocalProducts:[Product] = []
    
    var exportToCloudProducts:[Product] = []
    var importToLocalProducts:[Product] = []
    var databaseRef:DatabaseReference?
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
    var imageUrlString:[String] = []
    
    func fetchCloudProducts(completionHandler: @escaping (_ importExportTotal: [Int]) -> ()){
        // Create database reference
        databaseRef = Database.database().reference()
        // Get database path and create an observer for one single event
        databaseRef?.child("\(UserDefaultsSettings.getUserUID())").child("Products").observeSingleEvent(of: DataEventType.value, with: { (data) in
            // Check if the data exists
            if data.exists(){
                // Retrieve and store the data as a NSDictionary
                guard let products = data.value as? NSDictionary else {return}
                // Loop through the NSDictionary
                for product in products {
                    // For every value inside the NSDictionary create a new NSDictionary
                    guard let productData = product.value as? NSDictionary else {return}
                    // Check if the array contains one of the ProductName values inside every NSDictionary
                    self.exsistingCloudProductsNames.append((productData["ProductName"] as? String ?? "").lowercased())
                }
            }
            // Retrieve and store the local products
            self.exsistingLocalProducts = ProductRepository.fetchLocalProducts()
            // Retrieve and store the local product names
            self.exsistingLocalProductNames = ProductRepository.fetchLocalProductNames()
            // Loop through the exsistingLocalProducts array
            for product in self.exsistingLocalProducts{
                // Check if the exsistingCloudProductsNames array contains the product name from the exsistingLocalProducts array
                if !self.exsistingCloudProductsNames.contains(product.name!.lowercased()){
                    // If not add the product to the exportToCloudProducts array
                    self.exportToCloudProducts.append(product)
                }
            }
            // Loop through the exsistingCloudProductsNames array
            for productName in self.exsistingCloudProductsNames{
                // Check if the exsistingLocalProductNames array contains the product name from the exsistingCloudProductsNames array
                if !self.exsistingLocalProductNames.contains(productName.lowercased()){
                    // If not add the productName to the importFromCloudProducts array
                    self.importFromCloudProducts.append(productName.lowercased())
                }
            }
            // DEBUG MESSAGE
            print("Products to export: \(self.exportToCloudProducts.count)")
            // DEBUG MESSAGE
            print("Products to import: \(self.importFromCloudProducts.count)")
            // Use the completionHandler to escape the assync operation and return the export and import count to the AppSetingsTableViewController
            completionHandler([self.exportToCloudProducts.count,self.importFromCloudProducts.count])
        })
    }
    
    func importCloudProducts() {
        // Create database reference
        databaseRef = Database.database().reference()
        // Get database path and create an observer for one single event
        databaseRef?.child("\(UserDefaultsSettings.getUserUID())").child("Products").observeSingleEvent(of: DataEventType.value, with: { (data) in
            // Check if the data exists
            if data.exists(){
                // Retrieve and store the data as a NSDictionary
                guard let products = data.value as? NSDictionary else {return}
                // Loop through the NSDictionary
                for product in products {
                    // For every value inside the NSDictionary create a new NSDictionary
                    guard let productData = product.value as? NSDictionary else {return}
                    // Store the productName from the data inside the productName variable
                    self.productName = productData["ProductName"] as? String ?? ""
                    // Check if the exsistingLocalProductNames array contains the productName
                    if !self.exsistingLocalProductNames.contains(self.productName.lowercased()){
                        // DEBUG MESSAGE
                        print("Cloud product to import: \(self.productName)")
                        // If not store all values inside there variable
                        self.kiloCalorieValue
                            = ConverterService.convertStringToDouble(string: productData["Kilocalorie"] as? String ?? "0,0")
                        self.carbohydrateValue
                            = ConverterService.convertStringToDouble(string: productData["Carbohydrate"] as? String ?? "0,0")
                        self.proteinValue
                            = ConverterService.convertStringToDouble(string: productData["Protein"] as? String ?? "0,0")
                        self.fatValue
                            = ConverterService.convertStringToDouble(string: productData["Fat"] as? String ?? "0,0")
                        self.saltValue
                            = ConverterService.convertStringToDouble(string: productData["Salt"] as? String ?? "0,0")
                        self.fiberValue
                            = ConverterService.convertStringToDouble(string: productData["Fiber"] as? String ?? "0,0")
                        // Add the imageUrl to the imageUrlString array
                        self.imageUrlString.append(productData["ImageUrl"] as? String ?? "")
                        // When all values are stored create a new local product with the values from the variable
                        self.createNewLocalProduct()
                    }
                }
            }
            // Create a counter with zero as starting value
            var count = 0
            // Loop through the importToLocalProducts array
            for product in self.importToLocalProducts {
                // Create a downloadCloudProductImages task with the product and counter value
                self.downloadCloudProductImages(product: product, index: count)
                // Add one to the counter value
                count = count + 1
            }
        })
    }
    
    func importStarterProducts() {
        // Create database reference
        databaseRef = Database.database().reference()
        // Get database path and create an observer for one single event
        databaseRef?.child("Products").observeSingleEvent(of: DataEventType.value, with: { (data) in
            // Check if the data exists
            if data.exists(){
                // Retrieve and store the data as a NSDictionary
                guard let products = data.value as? NSDictionary else {return}
                // Loop through the NSDictionary
                for product in products {
                    // For every value inside the NSDictionary create a new NSDictionary
                    guard let productData = product.value as? NSDictionary else {return}
                    // Store all values inside there variable
                    self.productName
                        = productData["ProductName"] as? String ?? ""
                    self.kiloCalorieValue
                        = ConverterService.convertStringToDouble(string: productData["Kilocalorie"] as? String ?? "0,0")
                    self.carbohydrateValue
                        = ConverterService.convertStringToDouble(string: productData["Carbohydrate"] as? String ?? "0,0")
                    self.proteinValue
                        = ConverterService.convertStringToDouble(string: productData["Protein"] as? String ?? "0,0")
                    self.fatValue
                        = ConverterService.convertStringToDouble(string: productData["Fat"] as? String ?? "0,0")
                    self.saltValue
                        = ConverterService.convertStringToDouble(string: productData["Salt"] as? String ?? "0,0")
                    self.fiberValue
                        = ConverterService.convertStringToDouble(string: productData["Fiber"] as? String ?? "0,0")
                    // Add the imageUrl to the imageUrlString array
                    self.imageUrlString.append(productData["ImageUrl"] as? String ?? "")
                    // When all values are stored create a new local product with the values from the variable
                    self.createNewLocalProduct()
                }
            }
            // Create a counter with zero as starting value
            var count = 0
            // Loop through the importToLocalProducts array
            for product in self.importToLocalProducts {
                // Create a downloadCloudProductImages task with the product and counter value
                self.downloadCloudProductImages(product: product, index: count)
                // Add one to the counter value
                count = count + 1
            }
        })
    }
    
    func exportLocalProductsToCloud(){
        // Create database reference
        storageRef = Storage.storage().reference().child("\(UserDefaultsSettings.getUserUID())")
        // Store the exsistingCloudProductsNames array count size
        var count = exsistingCloudProductsNames.count
        // Loop through the exportToCloudProducts array
        for product in exportToCloudProducts {
            // For every product create a file path by the folder name and the productName
            let fileName = "ProductImages/\(product.name!).png"
            // Create a storage upload reference with the file path
            let fileUpload = storageRef?.child(fileName)
            // Upload the product image data
            fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
                if error != nil {
                    return
                }
                // Retrieve the upload downloadURL rerference
                fileUpload!.downloadURL { (url, error) in
                    if url != nil {
                        // If the downloadURL is valid convert it to a string value
                        let stringUrl:String = (url?.absoluteString)!
                        // DEBUG MESSAGE
                        print("Image URL: \(stringUrl)")
                        // Create an array with all the product values inclusief the stringURL with the image address stored
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
                        // Add one to the counter value
                        count = count + 1
                        // Create the product database entry name with the productname and the counter value
                        let stringValue:String = "Product\(count)"
                        // DEBUG MESSAGE
                        print("Database entry name: \(stringValue)")
                        // Create the new reference for the product to upload by the product database entry name
                        self.databaseRef?.child("\(UserDefaultsSettings.getUserUID())").child("Products").child(stringValue).setValue(data)
                    }
                }
            }
        }
    }
    
    func createNewLocalProduct(){
        // Create a new product using the stored values
        let product = Product(context: PersistenceService.context)
        product.name = productName
        product.kilocalories = kiloCalorieValue
        product.carbohydrates = carbohydrateValue
        product.protein = proteinValue
        product.fat = fatValue
        product.salt = saltValue
        product.fiber = fiberValue
        // Add the new prouct to the importToLocalProducts array
        importToLocalProducts.append(product)
    }
    
    func downloadCloudProductImages(product:Product, index:Int) {
        // Create database reference
        storageRef = Storage.storage().reference()
        // Initialize the storage object
        storage = Storage.storage()
        // Create a download task pointing to the stringURL
        let imageDownload  = storage?.reference(forURL: imageUrlString[index])
        // Setup max download size and download the images from the URL
        imageDownload?.getData(maxSize: 1 * 5012 * 5012, completion: { (data, error) in
            if data != nil {
                // If the data is valid add the image data to the product
                product.image = data!
                // Save the context changes
                PersistenceService.saveContext()
            }else {
                // DEBUG MESSAGE
                print("Error could not load image form cloud")
            }
        })
    }
}

//    func fetchCloudProducts(completionHandler: @escaping (_ importExportTotal: [Int]) -> ()){
//        databaseRef = Database.database().reference()
//        databaseRef?.child("Products").observe(.value, with: { (data) in
//            if data.exists(){
//                guard let products = data.value as? NSDictionary else {return}
//                for product in products {
//                    guard let productData = product.value as? NSDictionary else {return}
//                    self.exsistingCloudProductsNames.append(productData["ProductName"] as? String ?? "")
//                }
//            }
//            self.exsistingLocalProducts = ProductRepository.fetchLocalProducts()
//            self.exsistingLocalProductNames = ProductRepository.fetchLocalProductNames()
//            for product in self.exsistingLocalProducts{
//                if !self.exsistingCloudProductsNames.contains(product.name!){
//                    self.exportToCloudProducts.append(product)
//                }
//            }
//            for productNames in self.exsistingCloudProductsNames{
//                if !self.exsistingLocalProductNames.contains(productNames){
//                    self.importFromCloudProducts.append(productNames)
//                }
//            }
//            // DEBUG MESSAGE
//            print("Products to export: \(self.exportToCloudProducts.count)")
//            // DEBUG MESSAGE
//            print("Products to import: \(self.importFromCloudProducts.count)")
//            // Sends export and import count inside assync operation
//            completionHandler([self.exportToCloudProducts.count,self.importFromCloudProducts.count])
//        })
//    }

//    func exportLocalProductsToCloud(){
//        storageRef = Storage.storage().reference()
//        var count = exsistingCloudProductsNames.count
//        for product in exportToCloudProducts {
//            let fileName = "ProductImages/\(product.name!).png"
//            let fileUpload = storageRef?.child(fileName)
//            fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
//                if error != nil {
//                    return
//                }
//                fileUpload!.downloadURL { (url, error) in
//                    if url != nil {
//                        let stringUrl:String = (url?.absoluteString)!
//                        // DEBUG MESSAGE
//                        print("Image URL: \(stringUrl)")
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
//                        count = count + 1
//                        let stringValue:String = "Product\(count)"
//                        // DEBUG MESSAGE
//                        print("Database entry name: \(stringValue)")
//                        self.databaseRef?.child("Products").child(stringValue).setValue(data)
//                    }
//                }
//            }
//        }
//    }

//    func importCloudProducts() {
//        databaseRef = Database.database().reference()
//        databaseRef?.child("Products").observe(.value, with: { (data) in
//            if data.exists(){
//                guard let products = data.value as? NSDictionary else {return}
//                for product in products {
//                    guard let productData = product.value as? NSDictionary else {return}
//                    self.productName = productData["ProductName"] as? String ?? ""
//                    // DEBUG MESSAGE
//                    print("Cloud product name: \(self.productName)")
//                    if !self.exsistingLocalProductNames.contains(self.productName){
//
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
//                        self.createNewLocalProduct()
//                    }
//                }
//            }
//            var count = 0
//            for product in self.importToLocalProducts {
//                self.downloadCloudProductImages(product: product, index: count)
//                count = count + 1
//            }
//        })
//    }

//    func downloadCloudProductImages(product:Product, index:Int) {
//        storageRef = Storage.storage().reference()
//        storage = Storage.storage()
//        let imageDownload  = storage?.reference(forURL: imageUrlString[index])
//        imageDownload?.getData(maxSize: 1 * 4092 * 4092, completion: { (data, error) in
//            if data != nil {
//                product.image = data!
//                PersistenceService.saveContext()
//            }else {
//                // DEBUG MESSAGE
//                print("Error could not load image form cloud")
//            }
//        })
//    }
