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
        databaseRef = Database.database().reference()
        databaseRef?.child("Products").observe(.value, with: { (data) in
            if data.exists(){
                guard let products = data.value as? NSDictionary else {return}
                for product in products {
                    guard let productData = product.value as? NSDictionary else {return}
                    self.exsistingCloudProductsNames.append(productData["ProductName"] as? String ?? "")
                }
            }
            self.exsistingLocalProducts = ProductRepository.fetchLocalProducts()
            self.exsistingLocalProductNames = ProductRepository.fetchLocalProductNames()
            for product in self.exsistingLocalProducts{
                if !self.exsistingCloudProductsNames.contains(product.name!){
                    self.exportToCloudProducts.append(product)
                }
            }
            for productNames in self.exsistingCloudProductsNames{
                if !self.exsistingLocalProductNames.contains(productNames){
                    self.importFromCloudProducts.append(productNames)
                }
            }
            // DEBUG MESSAGE
            print("Products to export: \(self.exportToCloudProducts.count)")
            // DEBUG MESSAGE
            print("Products to import: \(self.importFromCloudProducts.count)")
            // Sends export and import count inside assync operation
            completionHandler([self.exportToCloudProducts.count,self.importFromCloudProducts.count])
        })
    }
    
    func importCloudProducts() {
        databaseRef = Database.database().reference()
        databaseRef?.child("Products").observe(.value, with: { (data) in
            if data.exists(){
                guard let products = data.value as? NSDictionary else {return}
                for product in products {
                    guard let productData = product.value as? NSDictionary else {return}
                    self.productName = productData["ProductName"] as? String ?? ""
                    // DEBUG MESSAGE
                    print("Cloud product name: \(self.productName)")
                    if !self.exsistingLocalProductNames.contains(self.productName){
                        
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
                        self.imageUrlString.append(productData["ImageUrl"] as? String ?? "")
                        self.createNewLocalProduct()
                    }
                }
            }
            var count = 0
            for product in self.importToLocalProducts {
                self.downloadCloudProductImages(product: product, index: count)
                count = count + 1
            }
        })
    }
    
    func createNewLocalProduct(){
        // Create the imported product
        let product = Product(context: PersistenceService.context)
        product.name = productName
        product.kilocalories = kiloCalorieValue
        product.carbohydrates = carbohydrateValue
        product.protein = proteinValue
        product.fat = fatValue
        product.salt = saltValue
        product.fiber = fiberValue
        importToLocalProducts.append(product)
    }
    
    func downloadCloudProductImages(product:Product, index:Int) {
        storageRef = Storage.storage().reference()
        storage = Storage.storage()
        let imageDownload  = storage?.reference(forURL: imageUrlString[index])
        imageDownload?.getData(maxSize: 1 * 4092 * 4092, completion: { (data, error) in
            if data != nil {
                product.image = data!
                PersistenceService.saveContext()
            }else {
                // DEBUG MESSAGE
                print("Error could not load image form cloud")
            }
        })
    }
    
    func exportLocalProductsToCloud(){
        storageRef = Storage.storage().reference()
        var count = exsistingCloudProductsNames.count
        for product in exportToCloudProducts {
            let fileName = "ProductImages/\(product.name!).png"
            let fileUpload = storageRef?.child(fileName)
            fileUpload!.putData(product.image!, metadata: nil) { (metadata, error) in
                if error != nil {
                    return
                }
                fileUpload!.downloadURL { (url, error) in
                    if url != nil {
                        let stringUrl:String = (url?.absoluteString)!
                        // DEBUG MESSAGE
                        print("Image URL: \(stringUrl)")
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
                        count = count + 1
                        let stringValue:String = "Product\(count)"
                        // DEBUG MESSAGE
                        print("Database entry name: \(stringValue)")
                        self.databaseRef?.child("Products").child(stringValue).setValue(data)
                    }
                }
            }
        }
    }
}

