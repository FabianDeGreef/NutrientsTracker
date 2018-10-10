//
//  DayResultViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit

class DayResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    //MARK: Properties
    var userId:String?
    var products:[ConsumedProduct] = []
    var selectedProduct:ConsumedProduct?
    var currentDayTotal:DayTotal?

    //MARK: IBOutlets
    @IBOutlet weak var productTable: UITableView!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the table delegate to the current ViewController
        productTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if the currentDayTotal has any consumed products
        if currentDayTotal?.produtcs?.count != 0 {
            // Covert the NSSet products to an array with products
            convertNSProductSetToProductArray()
            //DEBUG MESSAGE
            print("Products found inside current dayTotal: \(currentDayTotal?.produtcs?.count ?? 0)")
        }else{
            //DEBUG MESSAGE
            print("No products found in current dayTotal")
        }
    }
    
    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table
        // When delete gesture is made call delete style
        if editingStyle == .delete {
            // Select the prodcut with the row index from the table
            let selection = products[indexPath.row]
            // Recalculate the dayTotal by subtracting the removed product nutrient values from the current dayTotal
            recalculateDayTotal(product: selection)
            // Delete the selected consumedProduct inside the context
            PersistenceService.context.delete(selection)
            // Save context changes
            PersistenceService.saveContext()
            // Delete the selected consumedProduct from the products array
            self.products.remove(at: indexPath.row)
            // Delete the consumedProducts from the table with a fade animation
            self.productTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the products array size to calculate the numbers of rows needed
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Take the Prodcut from every index value inside the Products array
        let product = products[indexPath.row]
        // Create a cell that is reusable with the identified cell name
        let cell = productTable.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        // Sets the cell textLabel value with the product name
        cell.textLabel!.text = product.name
        cell.detailTextLabel?.text = "Consumed weight: " + ConverterService.convertDoubleToString(double: product.weight) + "g"

        // return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store the selected item from the table inside a variable
        selectedProduct = products[indexPath.row]
        // Display the ProductViewController using the ViewConsumedProduct segue identifier
        self.performSegue(withIdentifier: "ViewConsumedProduct", sender: self)

    }
    
    //MARK: Helper Functions
    private func recalculateDayTotal(product:ConsumedProduct){
        currentDayTotal?.carbohydratesTotal = (currentDayTotal?.carbohydratesTotal)! - product.carbohydrates
        currentDayTotal?.cholesterolTotal = (currentDayTotal?.cholesterolTotal)! - product.fiber
        currentDayTotal?.fatTotal = (currentDayTotal?.fatTotal)! - product.fat
        currentDayTotal?.sugarTotal = (currentDayTotal?.sugarTotal)! - product.protein
        currentDayTotal?.kilocaloriesTotal = (currentDayTotal?.kilocaloriesTotal)! - product.kilocalories
        currentDayTotal?.saltTotal = (currentDayTotal?.saltTotal)! - product.salt
    }
    private func convertNSProductSetToProductArray(){
        // Store the CurrentUser DayTotals inside a NSSet variable
        let nsSet:NSSet = (currentDayTotal?.produtcs)!
        // Convert the NSSet objects to a DayTotal array
        products = nsSet.allObjects as! [ConsumedProduct]
        // Sort the array by date descending
        products.sort { (productOne, productTwo) -> Bool in
            return productOne.name!.compare(productTwo.name!) == ComparisonResult.orderedAscending
        }
        // Reload the table
        productTable.reloadData()
    }
    
    // MARK: Prepare Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if selectedProduct != nil && segue.destination is ProductViewController {
            let productVc = segue.destination as? ProductViewController
            productVc?.viewConsumedProduct = selectedProduct
        }
    }
}
