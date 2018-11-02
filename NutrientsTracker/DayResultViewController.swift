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
    @IBOutlet weak var overViewButton: UIBarButtonItem!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup the consumedProducts
        setupConsumedProducts()
        // Check the dayTotal consumedProduct count
        checkDayTotalConsumedProductCount()
    }
    
    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table
        // When delete gesture is made call delete style
        if editingStyle == .delete {
            // Select the product with the row index from the table
            let selection = products[indexPath.row]
            //Recalculate the dayTotal by subtracting the removed product values from the current dayTotal
            recalculateDayTotal(product: selection)
            // Delete the selected product
            deleteProduct(productToDelete: selection,index:indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the products array size to calculate the numbers of rows needed
        return products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Setup and return table row height
        return 90
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the Prodcut from every index value inside the products array
        let product = products[indexPath.row]
        // Create a cell that is reusable with the identified cell name
        guard let cell = productTable.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ConsumedProductTableViewCell else { return UITableViewCell() }
        // Set the productName label value with the product name
        cell.productNameLabel.text = product.name
        // Set the productWeightLabel with the product weight value
        cell.productWeightLabel.text = "Weight: \(ConverterService.convertDoubleToString(double: product.weight))g"
        // Set the productKilocalorieLabel with the product kilocalorie value
        cell.productKilocalorieLabel.text = "Kcal: \(ConverterService.convertDoubleToString(double: product.kilocalories))"
        // Check if the product image is valid
        if let img = product.image as Data? {
            // Convert the product image data to an image and display it in the image view
            cell.productImage.image = UIImage(data:img)
        }
        // return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store the selected item from the table inside a variable
        selectedProduct = products[indexPath.row]
        // Perform Segue to the ProductTableViewController
        self.performSegue(withIdentifier: "ViewConsumedProduct", sender: self)
    }
    
    //MARK: Helper Functions
    private func checkDayTotalConsumedProductCount(){
        // Check if the currentDayTotal Consumedproducts count greater than 0
        if (currentDayTotal?.produtcs?.count)! > 0 {
            // If greater enable the dayTotalButton
            overViewButton.isEnabled = true
        }else {
            // If not greater disabele the dayTotalButton
            overViewButton.isEnabled = false
        }
    }
    
    func deleteProduct(productToDelete:ConsumedProduct,index:IndexPath) {
        // Delete the selected product inside the context
        PersistenceService.context.delete(productToDelete)
        // Save context changes
        PersistenceService.saveContext()
        // Delete the selected product from the products array
        self.products.remove(at: index.row)
        // Delete the prouct from the table with a fade animation
        self.productTable.deleteRows(at: [index], with: .fade)
        // Check the dayTotal consumedProduct count
        checkDayTotalConsumedProductCount()
    }
    
    func setupConsumedProducts() {
        // Check if the currentDayTotal has any consumed products
        if currentDayTotal?.produtcs?.count != 0 {
            // Covert the NSSet products to an array with ConsumedProducts
            products = ConverterService.convertNSProductsSetToConsumedProductsArray(products: (currentDayTotal?.produtcs)!)
            // Reload the productTable
            productTable.reloadData()
            //DEBUG MESSAGE
            print("Products found inside current dayTotal: \(currentDayTotal?.produtcs?.count ?? 0)")
        }else{
            //DEBUG MESSAGE
            print("No products found in current dayTotal")
        }
        // Check the consumedProducts total count
        checkAmountConsumedProducts()
    }
    
    func checkAmountConsumedProducts(){
        // Check if the product array count is 0
        if products.count == 0 {
            // if product array count is 0 disable the overViewButton
            overViewButton.isEnabled = false
        }else {
            // if product array count higher than 0 enable the overViewButton
            overViewButton.isEnabled = true
        }
    }
    
    private func recalculateDayTotal(product:ConsumedProduct){
        // Recalculate the dayTotal values by subtracting the deleted product it's values
        currentDayTotal?.carbohydratesTotal = (currentDayTotal?.carbohydratesTotal)! - product.carbohydrates
        currentDayTotal?.fiberTotal = (currentDayTotal?.fiberTotal)! - product.fiber
        currentDayTotal?.fatTotal = (currentDayTotal?.fatTotal)! - product.fat
        currentDayTotal?.proteinTotal = (currentDayTotal?.proteinTotal)! - product.protein
        currentDayTotal?.kilocaloriesTotal = (currentDayTotal?.kilocaloriesTotal)! - product.kilocalories
        currentDayTotal?.saltTotal = (currentDayTotal?.saltTotal)! - product.salt
    }
    
    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Check if the selectedProduct isn't nil and if the segue destination is ProductTableViewController
        if selectedProduct != nil && segue.destination is ProductTableViewController {
            // Pass the selectedProduct to the ProductTableViewController
            let productVc = segue.destination as? ProductTableViewController
            productVc?.viewConsumedProduct = selectedProduct
        }
        // Check if the segue destination is OverViewTableViewController
        if segue.destination is OverViewTableViewController {
            // Pass the currentDayTotal to the OverViewTableViewController
            let dayOverviewtVc = segue.destination as? OverViewTableViewController
            dayOverviewtVc?.currentDayTotal = currentDayTotal
        }
    }
}

//            // Select the prodcut with the row index from the table
//            let selection = products[indexPath.row]
//            // Recalculate the dayTotal by subtracting the removed product nutrient values from the current dayTotal
//            recalculateDayTotal(product: selection)
//            // Delete the selected consumedProduct inside the context
//            PersistenceService.context.delete(selection)
//            // Save context changes
//            PersistenceService.saveContext()
//            // Delete the selected consumedProduct from the products array
//            self.products.remove(at: indexPath.row)
//            // Delete the consumedProducts from the table with a fade animation
//            self.productTable.deleteRows(at: [indexPath], with: .fade)
//            self.checkAmountConsumedProducts()
