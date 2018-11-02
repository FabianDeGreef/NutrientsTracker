//
//  LoginViewController.swift
//  NutrientsTracker
//
//  Created by Fabian De Greef on 03/10/2018.
//  Copyright © 2018 Fabian De Greef. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    var segmentIsLogin:Bool = true
    var userEmail:String = ""
    var userPassword:String = ""
    var localUser:User?

    //MARK: IBOutlets
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check for signed in users
        checkSignedInUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup Userdefaults settings
        _ = UserDefaultsSettings.init()
        // Reset the textfields and variables
        resetForm()
    }
    
    //MARK: IBActions
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        // When the segmentControl is changed switch property values
        segmentIsLogin = !segmentIsLogin
        // When property values are changed reset the UI to the correct display mode
        if segmentIsLogin {
            // Reset to login
            resetUIToLogin()
        }else {
            // Reset to register
            resetUIToRegister()
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // Dismisses the keyboard
        view.endEditing(true)
        // Check userPassword and userEmail values are not empty
        if !userPassword.isEmpty && !userEmail.isEmpty {
            // When the login segment was selected
            if segmentIsLogin {
                // Sign in user
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (userData, error) in
                    // Check if the userData doesn't return nil
                    if (userData?.user) != nil {
                        // DEBUG MESSAGE
                        print("Login Successful")
                    }else {
                        // Show an alert message when login was failed
                        self.showAlertAction(title: "No user found", message: "No user found with matching email or password")
                    }
                }
                // When the register segement was selected
            }else{
                // Create a new user
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (userData, error) in
                    // Check if the creaded userData doesn't return nil
                    if (userData?.user) != nil {
                        // DEBUG MESSAGE
                        print("Registration Successful")
                    }else{
                        // Show an alert message when registration failed
                        self.showAlertAction(title: "Could not register", message: "Please try again")
                    }
                }
            }
        }else {
            // Show an alert message when invalid values where entered
            showAlertAction(title: "Invalid values", message: "Please enter a valid email or password")
        }
    }
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // switch email textField to password textField with the return button
        switch textField {
        case emailTextfield:
            passwordTextfield.becomeFirstResponder()
        default:
            passwordTextfield.resignFirstResponder()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailTextfield:
            // Validate entered email
            if ValidationService.validateEmail(email: emailTextfield.text!){
                userEmail = emailTextfield.text!
            }else {
                userEmail = ""
                emailTextfield.text = ""
                emailTextfield.placeholder = "Enter valid email"
                showAlertAction(title: "Unvalid email", message: "Please enter a valid email")
            }
        default:
            // Validate entered password
            if ValidationService.validatePassword(password: passwordTextfield.text!){
                userPassword = passwordTextfield.text!
            }else {
                userPassword = ""
                passwordTextfield.text = ""
                passwordTextfield.placeholder = "Enter valid password"
                showAlertAction(title: "Unvalid password", message: "Please enter a valid password")
            }
        }
    }
    
    //MARK: Helper Functions
    private func checkSignedInUser() {
        // Authentication listener that handels all authentication changes
        Auth.auth().addStateDidChangeListener { auth, user in
            // When the Authentication server returns a valid session
            if user != nil {
                // Check if the online user matches with the local user if not create one
                self.localUser = UserRepository.fetchUserByEmail(email: (user?.email)!)
                // Get stored user email from the userDefaults
                let storedUserEmail = UserDefaultsSettings.getUserEmail()
                // Get stored user UID from the userDefaults
                let storedUserUID = UserDefaultsSettings.getUserUID()
                // Check if the online user email and UID matches with the stored values
                if storedUserEmail != user?.email  && storedUserUID != user?.uid  {
                    // Save the new user email to the userDefaults
                    UserDefaultsSettings.setUserEmail(userEmail: (user?.email)!)
                    // Save the new user UID to the userDefaults
                    UserDefaultsSettings.setUserUID(userUID:(user?.uid)!)
                    // DEBUG MESSAGE
                    print("Changing user local information")
                }
                print("UserUID: \(user?.uid ?? "")")
                // Check if the getStarterProductsCondition is true
                if UserDefaultsSettings.getStarterProductsCondition() {
                    // If true run the starterProducts setup
                    let setupStarterProducts = CloudProductRepository()
                    setupStarterProducts.importStarterProducts()
                    // Turn Off the StarterProducts after the setup
                    UserDefaultsSettings.turnOfStarterProducts()
                    // DEBUG MESSAGE
                    print("Importing starter products")
                }
                // Perform segue to the DateViewController
                self.performSegue(withIdentifier: "GoToDateSelection", sender: self)
                // DEBUG MESSAGE
                print("User with email: \(user?.email ?? "") is signed in")
            } else {
                // DEBUG MESSAGE
                print("No user is signed in")
            }
        }
    }
    
    // Creates custom AlertActions
    func showAlertAction(title: String, message: String){
        // Create the UIAlertController with the incoming values
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Create the UIAlertAction to display an ok button and dismisses the alert after it is pressed
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
        }
        // Adding the UIAlertAction to the UIAlertController
        alert.addAction(action)
        // Displaying the alert message
        present(alert, animated: true, completion: nil)
    }
    
    private func resetUIToRegister() {
        // Set UI to registration
        loginLabel.text = "Please Register"
        resetForm()
    }
    
    private func resetUIToLogin() {
        // Set UI to login
        loginLabel.text = "Please Login"
        resetForm()
    }
    
    private func resetForm() {
        // Reset the form
        userPassword = ""
        userEmail = ""
        passwordTextfield.text = ""
        emailTextfield.text = ""
    }

    //MARK: Segue Prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the segue destination is the DateViewController
        if segue.destination is DateViewController {
            let dateVc = segue.destination as? DateViewController
            // Send the local user
            dateVc?.localUser = localUser
        }
    }
}
