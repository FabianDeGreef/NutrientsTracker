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
    var productName:String?
    var weight:Decimal?
    var products:[Product] = []
    //var context:NSManagedObjectContext?
    var selectedProduct:NSManagedObject?
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Give the viewcontroller delegate acces from the used tableview
        productTable.delegate = self
        productTable.dataSource = self
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var weightTextfield: UITextField!
    @IBOutlet weak var productTable: UITableView!
    
    //MARK:  IBActions
    @IBAction func signOffUser(_ sender: UIBarButtonItem) {
        if AuthenticationService.signOffUser() {
            _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func searchProduct(_ sender: UIButton) {
        // Check textfield for empty value
        if !(nameTextField.text?.isEmpty)!{
            // Closses the keyboard if the user didn't use the return button
            nameTextField.resignFirstResponder()
            // Store the textfields value
            productName = nameTextField.text
            // Load the stored data form Core Data
            fetchDataFromContext()
            // Reload the product table to view the fetched products
            productTable.reloadData()
        }
    }
    
    @IBAction func addToDayTotal(_ sender: UIButton) {
        // Check textfield for empty value
        if !(weightTextfield.text?.isEmpty)!{
            // Convert and store the textfield value
            weight = Decimal(string: weightTextfield.text!)
            // Load the DayResultViewController to add the selected product with the weight to the DayTotal
            performSegue(withIdentifier: "DayEntrySetup", sender: self)
        }
    }
    
    @IBAction func addNewProduct(_ sender: UIBarButtonItem) {
        // Load the ProductViewController to create a new product
        performSegue(withIdentifier: "AddProduct", sender: self)
    }
    
    //MARK: Helper Functions
    func fetchDataFromContext(){
        // Make the product array empty for every query
        products.removeAll()
        // Initialize the context
    //    accessContext()
        // Create the fetchRequest for the type of product
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Product")
        // Initialize a predicate to use with the fetchRequest (Fetch product name must contain the user input name)
        fetchRequest.predicate = NSPredicate(format:"name contains[c] %@", productName!)
        do {
            // Access the store to retrieve the product
            products = try (PersistenceService.context.fetch(fetchRequest)) as! [Product]
        }catch let error as NSError{
            print("Could not fetch. \(error)")
        }
    }
    
    func showSelectionMenu(selection: NSManagedObject){
        // Create an actionSheet with 4 user options
        let actionSheet = UIAlertController(title: "Choose an option", message: "Select, View or Remove product", preferredStyle: .actionSheet)
        // Add the first action (Select) to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Select", style: .default, handler: { (action: UIAlertAction) in
            // Make the selectedProduct variable the current selected product from the table
            self.selectedProduct = selection
        }))
        // Add the second action (View) to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "View", style: .default, handler: { (UIAlertAction) in
            // Display a detail view for the selected product
        }))
        // Add the third action (Remove) to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Remove", style: .default, handler: { (UIAlertAction) in
            // Acces the current context with the delete method and pass the selected product to delete through
            //self.context?.delete(selection)
            PersistenceService.context.delete(selection)
            // Call the saveContext method to save all changes made in the context
            PersistenceService.saveContext()
            //self.saveContext()
            // Repopulate the product array with valid products from the database
            self.fetchDataFromContext()
            // Reload the viewTable so the removed product won't be displayed anymore
            self.productTable.reloadData()
        }))
        // Add the fourth action (Cancel) to the actionSheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        // Dissmis the UIAlertController
        present(actionSheet,animated: true, completion: nil)
    }
    

    //MARK: UITableView Delegates
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Add an editing style function to the table (Delete)
        // When delete gesture is made call style delete
        if editingStyle == .delete {
            // Select the product on the current selected index inside the table
            let selection = products[indexPath.row]
            // Delete the selected product inside the context
            PersistenceService.context.delete(selection)
            //self.context?.delete(selection)
            // Save all the changes inside the context
            PersistenceService.saveContext()
            // Delete the selected product form the current found products array
            self.products.remove(at: indexPath.row)
            // Delete the product from the UITableView with the fade animation
            self.productTable.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the total size from the products array to calculate the numbers of rows needed
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Thake the product from every index value inside the prodcuts array
        let product = products[indexPath.row]
        // Create a cell that is reusable for every index
        let cell = productTable.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        // Give the cell textlabel a value
        //cell.textLabel!.text = product.value(forKeyPath: "name") as? String
        cell.textLabel!.text = product.name
        // return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a user select an index form the table the UIAlertView opens with the 4 options and gets access to the selected value at the moment
        showSelectionMenu(selection: products[indexPath.row])
    }
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // When inside a textfield the retun keyboard button is pressed the keyboard first responder changes
        switch textField {
        case nameTextField:
            // Closses the keyboard after return
            nameTextField.resignFirstResponder()
        default:
            // Clossed the keyboard after return
            weightTextfield.resignFirstResponder()
        }
        return true
    }
    
    // MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
