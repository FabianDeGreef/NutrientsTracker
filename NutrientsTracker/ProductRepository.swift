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
        // Create an empty product array to store the fetched products form the local database
        var localProducts:[Product] = []
        // Create a fetchRequest to find all the local products
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        do {
            // Access the database and store the local products inside the array
            localProducts = try (PersistenceService.context.fetch(fetchRequest)) as! [Product]
            // Sort every local product alphabeticali inside the array and order ascending
            localProducts.sort { (productOne, productTwo) -> Bool in
                return productOne.name?.compare(productTwo.name!) == ComparisonResult.orderedAscending
            }
            // DEBUG MESSAGE
            print("Fetching local products succes")
        }catch {
            // DEBUG MESSAGE
            print("Error fetching local products")
        }
        // Return the orderd and sorted array with local products
        return localProducts
    }
    
    static func fetchLocalProductNames() -> [String] {
        // Create an empty product array to store the fetched products form the local database
        var localProductNames:[String] = []
        // Create a fetchRequest to find all the local product names
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Product")
        do {
            let products = try PersistenceService.context.fetch(fetchRequest)
            for productData in products {
                guard let product = productData as? Product else {continue}
                localProductNames.append(product.name!.lowercased())
            }
        }catch {
            // DEBUG MESSAGE
            print("Error retrieving entitys")
        }
        return localProductNames
    }
    
    static func createConsumedProduct(selectedProduct:Product, weight:Double) -> ConsumedProduct{
        let consumedProduct = ConsumedProduct(context: PersistenceService.context)
        consumedProduct.carbohydrates = ((selectedProduct.carbohydrates) / 100) * weight
        consumedProduct.salt = ((selectedProduct.salt) / 100) * weight
        consumedProduct.fat = ((selectedProduct.fat) / 100) * weight
        consumedProduct.fiber = ((selectedProduct.fiber) / 100) * weight
        consumedProduct.kilocalories = ((selectedProduct.kilocalories) / 100) * weight
        consumedProduct.protein = ((selectedProduct.protein) / 100) * weight
        consumedProduct.name = selectedProduct.name
        consumedProduct.image = selectedProduct.image
        consumedProduct.weight = weight
        return consumedProduct
    }
}
