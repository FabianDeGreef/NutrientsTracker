//
//  DaySetupViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import CoreData
import ARKit

class DaySetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    //MARK: Properties
    var selectedProduct:Product?
    var viewProduct:Product?
    var currentDayTotal:DayTotal?
    var products:[Product] = []
    var productsSearchList:[Product] = []
    var searching:Bool = false
    var weight:Double = 0.0

    //MARK: IBOutlets
    @IBOutlet weak var productTable: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
    @IBOutlet weak var dayTotalButton: UIBarButtonItem!
    @IBOutlet weak var addProductButton: UIBarButtonItem!
    @IBOutlet weak var ArButton: UIBarButtonItem!

    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if ARConfiguration.isSupported {
            ArButton.isEnabled = true
        }else {
            ArButton.isEnabled = false
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reset to default when the view will appear
        resetForm()
        // Setup the local products
        setupLocalProducts()
        // DEBUG MESSAGE
        print("Consumed products in Daysetup: \(currentDayTotal?.produtcs?.count ?? 0)")
        // Check the dayTotal product count
        checkDayTotalProductCount()
        // Start the product table animation
        animateProductTable()
    }
    
    //MARK: IBActions
    @IBAction func unwindToDaySetup(_ sender:UIStoryboardSegue) {
        guard let weightVc = sender.source as? WeightViewController else { return }
        weight = weightVc.weight
        // If returning weight is greater than 0.0
        if weight > 0.0 {
            // Enable the addButton
            addButton.isEnabled = true
            // Set the addButton title color from black to white
            addButton.setTitleColor(UIColor.white,for: UIControl.State.normal)
            // Change button background color
            addButton.backgroundColor = UIColor.init(named: "FiberColor")
            // Display the weight inside the weightLabel
            weightLabel.text = "Weight: \(ConverterService.convertDoubleToString(double: weight))g"
            pulseAddButtonAnimation()
        }
    }
    
    @IBAction func addToDayTotal(_ sender: UIButton) {
        // Check if the weight is greather than 0.0
        if weight > 0.0 {
            // Check if the selectedProduct isn't nil
            if selectedProduct != nil {
                // Create a new ConsumedProduct and calculate the dayTotal result
                createConsumedProduct()
                // Save context changes
                PersistenceService.saveContext()
                // Reset UI and variables to default
                resetForm()
                // Show an alert view when the ConsumedProduct is added to the DayTotal
                showAlert(title: "Consumed product added", message: "The consumed product was added to your dayTotal")
                // Enable the addButton
                addProductButton.isEnabled = true
                // Enable tabel selection
                productTable.allowsSelection = true
                // Check the dayTotal product count
                checkDayTotalProductCount()
                // Start button animation
                startAddButtonAnimation(button: sender)
                // Change button background color
                addButton.backgroundColor = UIColor.init(named: "KcalColor")
            }
        }else {
            // DEBUG MESSAGE
            print("Weight can't be zero")
            // Show an alert view when the weight value isn't valid
            showAlert(title: "Weight zero", message: "Please enter a new weight value")
        }
    }
    
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        // Perform Segue to the ProductTableViewController
        performSegue(withIdentifier: "AddProduct", sender: self)
    }
    
    //MARK: Helper Functions
    func pulseAddButtonAnimation(){
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        // Set the pulse speed
        pulse.duration = 0.3
        // Set the pulse starting value
        pulse.fromValue = 0.95
        // Set the pulse ending value
        pulse.toValue = 1.0
        // Set the pulse autoreverse to true
        pulse.autoreverses = true
        // Set animation repeats
        pulse.repeatCount = 2
        pulse.initialVelocity = 0.9
        pulse.damping = 1.0
        // Add animation to the button
        addButton.layer.add(pulse, forKey: nil)
    }
    
    func startAddButtonAnimation(button:UIButton) {
        // Start button animation
        button.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        UIView.animate(withDuration: 2.0,
                       delay: 0,
                       usingSpringWithDamping: CGFloat(0.20),
                       initialSpringVelocity: CGFloat(6.0),
                       options: UIView.AnimationOptions.allowUserInteraction,
                       animations: { button.transform = CGAffineTransform.identity }, completion: nil )
    }
    
    func animateProductTable() {
        // Store the table cells
        let cells = productTable.visibleCells
        // Store the table height
        let tableViewHeight = productTable.bounds.size.height
        // Loop through the cells
        for cell in cells {
            // Transform the cell y position
            cell.transform = CGAffineTransform(translationX: 0 , y: tableViewHeight)
        }
        // Create a counter
        var counter = 0
        // Loop through the cells
        for cell in cells {
            // Animate for 1.75 seconds every cell with the curveEaseInOut animation
            UIView.animate(withDuration: 1.75, delay: Double(counter)*0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                // Transform the cell to it's normal position
                cell.transform = CGAffineTransform.identity
            },completion: nil)
            // add one to the counter total
            counter += 1
        }
    }
    
    private func checkDayTotalProductCount(){
        // Check the currentDayTotal products count greater than 0
        if (currentDayTotal?.produtcs?.count)! > 0 {
            // If greater enable the dayTotalButton
            dayTotalButton.isEnabled = true
        }else {
            // If not greater disabele the dayTotalButton
            dayTotalButton.isEnabled = false
        }
    }
    
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
        // Reset the labels and values to there default
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
            // Create a consumedProduct from the selected product
            let newConsumedProduct = ProductRepository.createConsumedProduct(selectedProduct: product, weight: weight)
            // Add the consumedProduct to the current dayTotal
            currentDayTotal?.addToProdutcs(newConsumedProduct)
            // Update the dayTotal values
            if let dayTotal = currentDayTotal {
                DayTotalRepository.updateDayTotal(consumedProduct: newConsumedProduct, currentDayTotal: dayTotal)
            }
        }
    }
    
    func setupLocalProducts(){
        // Clear product array
        products.removeAll()
        // Store the local products inside the products array
        products = ProductRepository.fetchLocalProducts()
        // Display the total count products
        productCountLabel.text = "Products: \(products.count)"
        // Check if the products array is empty
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
            // Disable the addProductButton
            self.addProductButton.isEnabled = false
            // Disable the DayTotalButton
            self.dayTotalButton.isEnabled = false
            // Disable table selection
            self.productTable.allowsSelection = false
            // Perform Segue to the WeightViewController
            self.performSegue(withIdentifier: "AddWeight", sender: self)

        }))
        // Add the detail view action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "View Product", style: .default, handler: { (UIAlertAction) in
            // When view is choosen store the selectedProduct value inside the viewProduct variable
            self.viewProduct = self.selectedProduct
            // Perform Segue to the ProductTableViewController
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
        // Set actionSheet source view
        actionSheet.popoverPresentationController?.sourceView = self.view
        // Set actionSheet popover view
        actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        // Position the actionSheet centered on the screen
        actionSheet.popoverPresentationController?.sourceRect =
            CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        // Present the actionSheet
        self.present(actionSheet, animated: true, completion: nil)
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
            // Return the searchlist array size when searching with the searchbar
            return productsSearchList.count
        }else {
            // Return the products array size when viewing the table normal
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Get the Prodcut from every index value inside the Products array
        var product: Product
        if searching {
            // When searching with the searchbar use the searchlist array
            product = productsSearchList[indexPath.row]
        }else {
            // When not searching with the searchbar use the products array
            product = products[indexPath.row]
        }
        // Create a cell that is reusable with the identified cell name
        guard let cell = productTable.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductTableViewCell else { return UITableViewCell() }
        // Display the product name inside the productName label
        cell.productNameLabel.text = product.name!
        // Display the nutrient values inside there label
        cell.carbohydratesLabel.text = ConverterService.convertDoubleToString(double: product.carbohydrates)
        cell.fatLabel.text = ConverterService.convertDoubleToString(double: product.fat)
        cell.saltLabel.text = ConverterService.convertDoubleToString(double: product.salt)
        cell.kilocalorieLabel.text = ConverterService.convertDoubleToString(double: product.kilocalories)
        cell.fiberLabel.text = ConverterService.convertDoubleToString(double: product.fiber)
        cell.proteinLabel.text = ConverterService.convertDoubleToString(double: product.protein)
        // Display the product image
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
        // Setup and return table row height
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if searching
        if searching {
            // Store the value found matching the index from the productsSearchList array inside the selectedProduct
            selectedProduct = productsSearchList[indexPath.row]
        }else {
            // Store the value found matching the index from the products array inside the selectedProduct
            selectedProduct = products[indexPath.row]
        }
        // Show the UIAlert selection menu
        showSelectionMenu()
    }
    
    //MARK: UISearchBar Delegates
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // Update and filter the productsSearchList by typing inside the searchbar
        productsSearchList = products.filter({($0.name?.prefix(searchText.count))! == searchText })
        // When using the searchbar set searching to true
        searching = true
        // Reload the product table for every searchbar change to display the products
        productTable.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // When pressing the cancel button indie the searchbar
        // Set searching to false
        searching = false
        // Empty the searchbar textfield value
        searchField.text = ""
        // Dismisses the keyboard
        searchField.resignFirstResponder()
        // Reload the product table
        productTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // When the searchbar search button is pressed dismisses the keyboard
        searchField.resignFirstResponder()
    }
    
    //MARK: Segue Prepare
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
