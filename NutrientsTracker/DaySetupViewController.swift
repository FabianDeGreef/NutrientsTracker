//
//  DaySetupViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 04/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import CoreData

class DaySetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK: Properties
    var weight:Double = 0.0
    var selectedProduct:Product?
    var viewProduct:Product?
    var productName:String = ""
    var currentDayTotal:DayTotal?
    var products:[Product] = []
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sets the table delegate to the current ViewController
        productTable.delegate = self
        // Sets the table datasource to the current ViewController
        productTable.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reset the form and varibales to default when the view will appear
        resetForm()
        // DEBUG MESSAGE
        print("Consumed products in Daysetup: \(currentDayTotal?.produtcs?.count ?? 0)")
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextfield: UITextField!
    @IBOutlet weak var productTable: UITableView!
    
    //MARK:  IBActions
    @IBAction func signOffUser(_ sender: UIBarButtonItem) {
        // Sign out the current user
        if AuthenticationService.signOffUser() {
            // Return back to the LoginViewController by popping the other views
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func searchProduct(_ sender: UIButton) {
        // Dismisses the keyboard
        nameTextField.resignFirstResponder()
        // Check if the textfield is empty
        if !(productName.isEmpty) {
            // Load the stored data form Core Data
            fetchDataFromContext()
            // Reload the product table to view the fetched products
            productTable.reloadData()
        }else {
            // DEBUG MESSAGE
            print("No valid product name")
        }
    }
    
    @IBAction func addToDayTotal(_ sender: UIButton) {
        // Dismisses the keyboard
        weightTextfield.resignFirstResponder()
        // Check if the selected product and the weight are not nil
        if weight > 0 {
            if selectedProduct != nil {
                // Create a new consumedProduct and calculate the dayTotal nutrient result
                createConsumedProduct()
                // Save context changes
                PersistenceService.saveContext()
                // Reset the form and varibales to default after completion
                resetForm()
                // Show an alert view when the consumed product is added to the dayTotal
                showAlert(title: "Added to daytotal", message: "The consumed product was added to the dayTotal")

            }else {
                // DEBUG MESSAGE
                print("No product was selected")
                // Show an alert view when there is no product selected
                showAlert(title: "No product", message: "There was no product selected")
            }
        }else {
            // DEBUG MESSAGE
            print("Weight was zero")
            // Show an alert view when the weight value isn't valid
            showAlert(title: "Weight was zero", message: "Please enter a new weight value")
        }
    }
    
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        // Display the ProductViewController using the AddProduct segue identifier
        performSegue(withIdentifier: "AddProduct", sender: self)
    }
    
    //MARK: Helper Functions
    
    // Creates custom AlertAction to alert the user
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
    
    private func resetForm() {
        nameTextField.text = ""
        weightTextfield.text = ""
        weight = 0.0
        productName = ""
        selectedProduct = nil
        products.removeAll()
        productTable.reloadData()
        viewProduct = nil
    }
    
    func createConsumedProduct() {
        // Create and calculate a new consumedProduct with the weight value
        let consumedProduct = ConsumedProduct(context: PersistenceService.context)
        consumedProduct.carbohydrates = ((selectedProduct?.carbohydrates)! / 100) * weight
        consumedProduct.salt = ((selectedProduct?.salt)! / 100) * weight
        consumedProduct.fat = ((selectedProduct?.fat)! / 100) * weight
        consumedProduct.fiber = ((selectedProduct?.fiber)! / 100) * weight
        consumedProduct.kilocalories = ((selectedProduct?.kilocalories)! / 100) * weight
        consumedProduct.protein = ((selectedProduct?.protein)! / 100) * weight
        consumedProduct.name = selectedProduct?.name
        consumedProduct.image = selectedProduct?.image
        consumedProduct.weight = weight
        // Adds the new consumedProduct to the CurrentDayTotal consumedProducts set
        currentDayTotal?.addToProdutcs(consumedProduct)
        // Calculate the dayTotal results
        updateDayTotalWithConsumedProduct(consumedProduct: consumedProduct)
    }
    
    func updateDayTotalWithConsumedProduct(consumedProduct: ConsumedProduct){
        // DEBUG MESSAGE
        print("Carbohydrate total first: " + String(format: "%.2f" ,currentDayTotal?.carbohydratesTotal ?? "0.0"))
        // Calculate the nutrient values for the dayTotal by adding the nutrient values from the new consumedProduct to the dayTotal
        currentDayTotal?.carbohydratesTotal = (currentDayTotal?.carbohydratesTotal)! + consumedProduct.carbohydrates
        currentDayTotal?.fiberTotal = (currentDayTotal?.fiberTotal)! + consumedProduct.fiber
        currentDayTotal?.saltTotal = (currentDayTotal?.saltTotal)! + consumedProduct.salt
        currentDayTotal?.proteinTotal = (currentDayTotal?.proteinTotal)! + consumedProduct.protein
        currentDayTotal?.fatTotal = (currentDayTotal?.fatTotal)! + consumedProduct.fat
        currentDayTotal?.kilocaloriesTotal = (currentDayTotal?.kilocaloriesTotal)! + consumedProduct.kilocalories
        // DEBUG MESSAGE
        print("Carbohydrate total leter: " + String(format: "%.2f" ,currentDayTotal?.carbohydratesTotal ?? "0.0"))
    }
    
    func fetchDataFromContext(){
        // Before fetching data from the database clear the prodcuts array
        products.removeAll()
        // Create a fetchRequest to find the matching products with the search value
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        // Initialize a predicate product name must contain the search value
        fetchRequest.predicate = NSPredicate(format:"name contains[c] %@", productName)
        do {
            // Access the database and retrieve the matching products
            products = try (PersistenceService.context.fetch(fetchRequest)) as! [Product]
        }catch {
            // DEBUG MESSAGE
            print("Error fetching request")
        }
        if products.count == 0 {
            // Show an alert view when there was no product found with the search value
            showAlert(title: "No product found", message: "The search result didn't match with a product")
        }
    }
    
    func showSelectionMenu(){
        // Creates an actionSheet that contains 4 options
        let actionSheet = UIAlertController(title: "Choose an option", message: "Select, View or Remove product", preferredStyle: .actionSheet)
        // Add the select action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Select", style: .default, handler: { (action: UIAlertAction) in
            // The product is selected and stored inside the selectedProduct variable do nothing more
        }))
        // Add the detail view action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "View", style: .default, handler: { (UIAlertAction) in
            // Display the ProductViewController using the ViewProduct segue identifier
            // When option view is choosen store the selectedProduct value inside the viewProduct
            self.viewProduct = self.selectedProduct
            self.performSegue(withIdentifier: "ViewProduct", sender: self)

        }))
        // Add the remove action to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (UIAlertAction) in
            // Delete the selected product inside the context
            PersistenceService.context.delete(self.selectedProduct!)
            // Save context changes
            PersistenceService.saveContext()
            // Get the index from the selected table row
            if let index = self.productTable.indexPathForSelectedRow {
                // Delete the product from the array with the row index
                self.products.remove(at: index.row)
            }
            // Reload the viewTable so the removed product won't be displayed anymore
            self.productTable.reloadData()
            // set the selectedProduct variable  to nil
            self.selectedProduct = nil
            // Set the weighTextField to default
            self.weightTextfield.text = ""
            // Set the weight property to default
            self.weight = 0.0
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
            // Delete the selected dayTotal inside the context
            PersistenceService.context.delete(selection)
            // Save context changes
            PersistenceService.saveContext()
            // Delete the selected dayTotal from the dayTotals array
            self.products.remove(at: indexPath.row)
            // Delete the dayTotal from the table with a fade animation
            self.productTable.deleteRows(at: [indexPath], with: .fade)
            // Set the weighTextField to default
            weightTextfield.text = ""
            // Set the weight property to default
            weight = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the Products array size to calculate the numbers of rows needed
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Take the Prodcut from every index value inside the Products array
        let product = products[indexPath.row]
        // Create a cell that is reusable with the identified cell name
        let cell = productTable.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        // Sets the cell textLabel value with the product name
        cell.textLabel!.text = product.name
        cell.detailTextLabel?.text = "KCAL: " + ConverterService.convertDoubleToString(double: product.kilocalories)
        // Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Store the selected item from the table inside a variable
        selectedProduct = products[indexPath.row]
        // Show the UIAlert selection menu
        showSelectionMenu()
    }
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            // Dismisses the keyboard after the return button was pressed on the keyboard
            nameTextField.resignFirstResponder()
        default:
            // Dismisses the keyboard after the return button was pressed on the keyboard
            weightTextfield.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case weightTextfield:
            // Validate the user input
            if ValidationService.decimalValidator(value: weightTextfield.text!){
                // Convert the validated value from string to double and store it inside the property
                weight = ConverterService.convertStringToDouble(string: weightTextfield.text!)
                // Display the converted value inside the textField with 2 decimals
                weightTextfield.text = ConverterService.convertDoubleToString(double: weight)
            }else {
                // If validation was failed set the property and textField with a default value
                weight = 0.0
                weightTextfield.text = ""
                weightTextfield.placeholder = "Enter valid weight"
            }
        default:
            // Validate the user input
            if ValidationService.alphabeticalValidator(value: nameTextField.text ?? ""){
                // Set the property with the value
                productName = nameTextField.text!
                nameTextField.resignFirstResponder()

            }else {
                // If validation was failed set the productName property with a default value
                productName = ""
                // Set the textField with a default value
                nameTextField.text = ""
                // Set the textField place holder to inform the user
                nameTextField.placeholder = "Enter valid name"
                // Show an alert view when the search value isn't valid
                showAlert(title: "Enter valid value", message: "Enter a valid search value")
            }
        }
    }
    
    // MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue destination is the ProductViewController
        if viewProduct != nil && segue.destination is ProductViewController{
            // Pass the selectedProduct to the ProductViewController
            let productVc = segue.destination as? ProductViewController
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
