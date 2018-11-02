//
//  ProductRepository.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 27/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import Foundation
import CoreData

class ProductRepository {
    
    static func fetchLocalProducts() -> [Product] {
        // Create an empty product array to store the products form the local database
        var localProducts:[Product] = []
        // Create a fetchRequest to find all the local products
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        do {
            // Access the data and store the products inside the array
            localProducts = try (PersistenceService.context.fetch(fetchRequest)) as! [Product]
            // Sort the products alphabetically in ascending order
            localProducts.sort { (productOne, productTwo) -> Bool in
                return productOne.name?.compare(productTwo.name!) == ComparisonResult.orderedAscending
            }
            // DEBUG MESSAGE
            print("Fetching local products succes")
        }catch {
            // DEBUG MESSAGE
            print("Error fetching local products")
        }
        // Return localProducts array
        return localProducts
    }
    
    static func fetchLocalProductNames() -> [String] {
        // Create an empty product array to store the product names from the local database
        var localProductNames:[String] = []
        // Create a fetchRequest to find all the local product names
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        do {
            let products = try PersistenceService.context.fetch(fetchRequest)
            for productData in products {
                // Check if productData contains valid values
                guard let product = productData as? Product else {continue}
                // Store the product names inside the localProductNames array
                localProductNames.append(product.name!.lowercased())
            }
        }catch {
            // DEBUG MESSAGE
            print("Error retrieving entitys")
        }
        // Return the localProductNames array
        return localProductNames
    }
    
    static func createConsumedProduct(selectedProduct:Product, weight:Double) -> ConsumedProduct{
        // Create a new consumedProduct using the stored values
        let consumedProduct = ConsumedProduct(context: PersistenceService.context)
        // Every product value is calculated based on 100g to creat a consumedProduct divide by 100 and multiply it by it's given weight
        consumedProduct.carbohydrates = ((selectedProduct.carbohydrates) / 100) * weight
        consumedProduct.salt = ((selectedProduct.salt) / 100) * weight
        consumedProduct.fat = ((selectedProduct.fat) / 100) * weight
        consumedProduct.fiber = ((selectedProduct.fiber) / 100) * weight
        consumedProduct.kilocalories = ((selectedProduct.kilocalories) / 100) * weight
        consumedProduct.protein = ((selectedProduct.protein) / 100) * weight
        consumedProduct.name = selectedProduct.name
        consumedProduct.image = selectedProduct.image
        consumedProduct.weight = weight
        // Return the consumedProduct
        return consumedProduct
    }
}
