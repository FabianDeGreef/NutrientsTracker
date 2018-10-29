//
//  DaySetupViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import CoreData

class DaySetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //MARK: Properties
    var selectedProduct:Product?
    var viewProduct:Product?
    var currentDayTotal:DayTotal?
    var products:[Product] = []
    var productsSearchList:[Product] = []
    var searching:Bool = false
    var weight:Double = 0.0

    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reset the form and varibales to default when the view will appear
        resetForm()
        // Setup the local products fetched from the database
        setupLocalProducts()
        // DEBUG MESSAGE
        print("Consumed products in Daysetup: \(currentDayTotal?.produtcs?.count ?? 0)")
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!    
    @IBOutlet weak var dayTotalButton: UIBarButtonItem!
    @IBOutlet weak var addProductButton: UIBarButtonItem!
    
    //MARK: IBActions
    @IBAction func unwindToDaySetup(_ sender:UIStoryboardSegue) {
        guard let weightVc = sender.source as? WeightViewController else { return }
        weight = weightVc.weight
        if weight > 0.0 {
            addButton.isEnabled = true
            addButton.setTitleColor(UIColor.white,for: UIControl.State.normal)
            weightLabel.text = "Weight: \(ConverterService.convertDoubleToString(double: weight))g"
        }
    }
    
    @IBAction func addToDayTotal(_ sender: UIButton) {
        // Check if the selected product and the weight are not nil
        if weight > 0 {
            if selectedProduct != nil {
                // Create a new ConsumedProduct and calculate the DayTotal result
                createConsumedProduct()
                // Save context changes
                PersistenceService.saveContext()
                // Reset UI and variables to default after completion
                resetForm()
                // Show an alert view when the ConsumedProduct is added to the DayTotal
                showAlert(title: "Consumed product added", message: "The consumed product was added to your dayTotal")
                addProductButton.isEnabled = true
                dayTotalButton.isEnabled = true
                productTable.allowsSelection = true
            }
        }else {
            // DEBUG MESSAGE
            print("Weight can't be zero")
            // Show an alert view when the weight value isn't valid
            showAlert(title: "Weight zero", message: "Please enter a new weight value")
        }
    }
    
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        // Display the ProductViewController using the AddProduct segue identifier
        performSegue(withIdentifier: "AddProduct", sender: self)
    }
    
    //MARK: Helper Functions
    func showAlert(title: String, message: String){
        // Create the UIAlertController with the incoming parameters
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Create the UIAlertAction to display an OK button and dismisses the alert after it is pressed
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
        }
        // Adding the UIAlertAction to the UIAlertController
        alert.addAction(action)
        // Displaying the Alert
        present(alert, animated: true, completion: nil)
    }
    
    func deleteProduct(productToDelete:Product,index:IndexPath) {
        // Delete the selected product inside the context
        PersistenceService.context.delete(productToDelete)
        // Save context changes
        PersistenceService.saveContext()
        // Delete the selected product from the products array
        self.products.remove(at: index.row)
        // Delete the prouct from the table with a fade animation
        self.productTable.deleteRows(at: [index], with: .fade)
        // Update the current product count label
        productCountLabel.text = "Products: \(products.count)"
    }
    
    private func resetForm() {
        weightLabel.text = "Weight: 0.00g"
        searchField.text = ""
        weight = 0.0
        productsSearchList.removeAll()
        productTable.reloadData()
        addButton.isEnabled = false
        addButton.setTitleColor(UIColor.black,for: UIControl.State.normal)
        selectedProduct = nil
        viewProduct = nil
        searching = false
    }
    
    func createConsumedProduct() {
        // DEBUG MESSAGE
        print("Choosen weight: \(weight)")
        if let product = selectedProduct {
            let newConsumedProduct = ProductRepository.createConsumedProduct(selectedProduct: product, weight: weight)
            currentDayTotal?.addToProdutcs(newConsumedProduct)
            if let dayTotal = currentDayTotal {
                DayTotalRepository.updateDayTotal(consumedProduct: newConsumedProduct, currentDayTotal: dayTotal)
            }
        }
    }
    
    func setupLocalProducts(){
        // Clear product array
        products.removeAll()
        // Store the fetched local products inside the products array
        products = ProductRepository.fetchLocalProducts()
        // Display the total amount products
        productCountLabel.text = "Products: \(products.count)"
        if products.count == 0 {
            // Show an alert view when there are no local products found
            showAlert(title: "No product found", message: "No local products stored")
        } else {
            // Reload the table when there are changes
            productTable.reloadData()
        }
    }
    
    func showSelectionMenu(){
        // Creates an actionSheet that contains 4 options
        let actionSheet = UIAlertController(title: "Choose an option", message: "Select, View or Remove product", preferredStyle: .actionSheet)
        // Add the select action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Select Product", style: .default, handler: { (action: UIAlertAction) in
            // The product is selected and stored inside the selectedProduct variable do nothing more
            self.addProductButton.isEnabled = false
            self.dayTotalButton.isEnabled = false
            self.productTable.allowsSelection = false
            self.performSegue(withIdentifier: "AddWeight", sender: self)

        }))
        // Add the detail view action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "View Product", style: .default, handler: { (UIAlertAction) in
            // Display the ProductViewController using the ViewProduct segue identifier
            // When option view is choosen store the selectedProduct value inside the viewProduct
            self.viewProduct = self.selectedProduct
            self.performSegue(withIdentifier: "ViewProduct", sender: self)

        }))
        // Add the remove action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Remove Product", style: .default, handler: { (UIAlertAction) in
            // Select the prodcut with the row index from the table
            if let index = self.productTable.indexPathForSelectedRow {
                // Delete the selected product
                self.deleteProduct(productToDelete: self.selectedProduct!, index: index)
            }
        }))
        // Add the cancel action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Dismisses the UIAlertController
        present(actionSheet,animated: true, completion: nil)
    }
    
    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table
        // When delete gesture is made call delete style
        if editingStyle == .delete {
            // Select the prodcut with the row index from the table
            let selection = products[indexPath.row]
            // Delete the selected product
            deleteProduct(productToDelete: selection,index:indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the Products array size to calculate the numbers of rows needed
        if searching {
            return productsSearchList.count
        }else {
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Take the Prodcut from every index value inside the Products array
        var product: Product
        if searching {
            product = productsSearchList[indexPath.row]
        }else {
            product = products[indexPath.row]
        }
        // Create a cell that is reusable with the identified cell name
        guard let cell = productTable.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
        // Sets the cell textLabel value with the product name
        cell.productNameLabel.text = product.name!
        cell.carbohydratesLabel.text = ConverterService.convertDoubleToString(double: product.carbohydrates)
        cell.fatLabel.text = ConverterService.convertDoubleToString(double: product.fat)
        cell.saltLabel.text = ConverterService.convertDoubleToString(double: product.salt)
        cell.kilocalorieLabel.text = ConverterService.convertDoubleToString(double: product.kilocalories)
        cell.fiberLabel.text = ConverterService.convertDoubleToString(double: product.fiber)
        cell.proteinLabel.text = ConverterService.convertDoubleToString(double: product.protein)
        if let img = product.image as Data? {
            cell.productImage.image = UIImage(data:img)
        }else {
            // DEBUG MESSAGE
            print("No product image was found")
        }
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store the selected item from the table inside a variable
        if searching {
            selectedProduct = productsSearchList[indexPath.row]
        }else {
            selectedProduct = products[indexPath.row]
        }
        // Show the UIAlert selection menu
        showSelectionMenu()
    }
    
    //MARK: UISearchBar Delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        productsSearchList = products.filter({($0.name?.prefix(searchText.count))! == searchText })
        searching = true
        productTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchField.text = ""
        searchField.resignFirstResponder()
        productTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchField.resignFirstResponder()
    }
    
    // MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue destination is the ProductViewController
        if viewProduct != nil && segue.destination is ProductTableViewController{
            // Pass the selectedProduct to the ProductTableViewController
            let productVc = segue.destination as? ProductTableViewController
            productVc?.viewProduct = viewProduct
        }
        
        // If the segue destination is the DayResultViewController
        if currentDayTotal != nil && segue.destination is DayResultViewController {
            // Pass the currentDayTotal to the DayResultViewController
            let dayResultVc = segue.destination as? DayResultViewController
            dayResultVc?.currentDayTotal = currentDayTotal
        }
    }
}

//    func createConsumedProduct() {
//        print(weight)
//        // Create and calculate a new consumedProduct with the weight value
//        let consumedProduct = ConsumedProduct(context: PersistenceService.context)
//        consumedProduct.carbohydrates = ((selectedProduct?.carbohydrates)! / 100) * weight
//        consumedProduct.salt = ((selectedProduct?.salt)! / 100) * weight
//        consumedProduct.fat = ((selectedProduct?.fat)! / 100) * weight
//        consumedProduct.fiber = ((selectedProduct?.fiber)! / 100) * weight
//        consumedProduct.kilocalories = ((selectedProduct?.kilocalories)! / 100) * weight
//        consumedProduct.protein = ((selectedProduct?.protein)! / 100) * weight
//        consumedProduct.name = selectedProduct?.name
//        consumedProduct.image = selectedProduct?.image
//        consumedProduct.weight = weight
//        // Adds the new consumedProduct to the CurrentDayTotal consumedProducts set
//        currentDayTotal?.addToProdutcs(consumedProduct)
//        // Calculate the dayTotal results
//        updateDayTotalWithConsumedProduct(consumedProduct: consumedProduct)
//    }
//
//    func updateDayTotalWithConsumedProduct(consumedProduct: ConsumedProduct){
//        // DEBUG MESSAGE
//        print("Carbohydrate total first: " + String(format: "%.2f" ,currentDayTotal?.carbohydratesTotal ?? "0.0"))
//        // Calculate the nutrient values for the dayTotal by adding the nutrient values from the new consumedProduct to the dayTotal
//        currentDayTotal?.carbohydratesTotal = (currentDayTotal?.carbohydratesTotal)! + consumedProduct.carbohydrates
//        currentDayTotal?.fiberTotal = (currentDayTotal?.fiberTotal)! + consumedProduct.fiber
//        currentDayTotal?.saltTotal = (currentDayTotal?.saltTotal)! + consumedProduct.salt
//        currentDayTotal?.proteinTotal = (currentDayTotal?.proteinTotal)! + consumedProduct.protein
//        currentDayTotal?.fatTotal = (currentDayTotal?.fatTotal)! + consumedProduct.fat
//        currentDayTotal?.kilocaloriesTotal = (currentDayTotal?.kilocaloriesTotal)! + consumedProduct.kilocalories
//        // DEBUG MESSAGE
//        print("Carbohydrate total leter: " + String(format: "%.2f" ,currentDayTotal?.carbohydratesTotal ?? "0.0"))
//    }

//    func fetchDataFromContext(){
//        // Before fetching data from the database clear the prodcuts array
//        products.removeAll()
//        // Create a fetchRequest to find the matching products with the search value
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
//        // Initialize a predicate product name must contain the search value
//        //fetchRequest.predicate = NSPredicate(format:"name contains[c] %@", productName)
//        do {
//            // Access the database and retrieve the matching products
//            products = try (PersistenceService.context.fetch(fetchRequest)) as! [Product]
//            productCountLabel.text = "Products: \(products.count)"
//            products.sort { (productOne, productTwo) -> Bool in
//                return productOne.name?.compare(productTwo.name!) == ComparisonResult.orderedAscending
//            }
//            productTable.reloadData()
//
//        }catch {
//            // DEBUG MESSAGE
//            print("Error fetching request")
//        }
//        if products.count == 0 {
//            // Show an alert view when there was no product found with the search value
//            showAlert(title: "No product found", message: "The search result didn't match with a product")
//        }
//    }

//            // Delete the selected dayTotal inside the context
//            PersistenceService.context.delete(selection)
//            // Save context changes
//            PersistenceService.saveContext()
//            // Delete the selected dayTotal from the dayTotals array
//            self.products.remove(at: indexPath.row)
//            // Delete the dayTotal from the table with a fade animation
//            self.productTable.deleteRows(at: [indexPath], with: .fade)
//            // Set the weight property to default
//            weight = 0.0
//            productCountLabel.text = "Products: \(products.count)"


//            // Delete the selected product inside the context
//            PersistenceService.context.delete(self.selectedProduct!)
//            // Save context changes
//            PersistenceService.saveContext()
//            // Get the index from the selected table row
//            if let index = self.productTable.indexPathForSelectedRow {
//                // Delete the product from the array with the row index
//                self.products.remove(at: index.row)
//            }
//            // Reload the viewTable so the removed product won't be displayed anymore
//            self.productTable.reloadData()
//            // set the selectedProduct variable  to nil
//            self.selectedProduct = nil
//            // Set the weight property to default
//            self.weight = 0.0
//            self.productCountLabel.text = "Products: \(self.products.count)"
