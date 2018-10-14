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

    //MARK: IBOutlets
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    //MARK: Properties
    var segmentIsLogin:Bool = true
    var userEmail:String = ""
    var userPassword:String = ""
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check first if a user is already signed in
        checkSignedInUser()
        userEmail = ""
        userPassword = ""
    }
    
    //MARK: IBActions
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        // When segmentControl is changed switch property values
        segmentIsLogin = !segmentIsLogin
        // When property values are changed reset the UI to the correct state
        if segmentIsLogin {
            resetUIToLogin()
        }else {
            resetUIToRegister()
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // Dismisses the keyboard
        passwordTextfield.resignFirstResponder()
        // Check if userPassword and userEmail are not empty
        if userPassword.count > 0 && userEmail.count > 0 {
            // When login was selected
            if segmentIsLogin {
                // Sign in an existing user
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { (userData, error) in
                    // Check if the userData doesn't return nil
                    if (userData?.user) != nil {
                        // Reset the textFields
                        self.resetTextFields()
                        // When signed in perfrom segue to the DateViewController
                        self.performSegue(withIdentifier: "DateSelection", sender: self)
                    }else {
                        // Show alert message when login was failed
                        self.showAlertAction(title: "No user found", message: "No user found matching with email or password")
                    }
                }
                // When register was selected
            }else{
                // Create a new user
                Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (userData, error) in
                    // Check if the creaded userDate doesn't return nil
                    if (userData?.user) != nil {
                        // Reset the textFields
                        self.resetTextFields()
                        // Show alert message when the registration was succesfull
                        self.showAlertAction(title: "Registration complete", message: "Please enter  email and password to login")
                    }else{
                        // Show alert message when registration failed
                        self.showAlertAction(title: "Could not register", message: "Please try again")
                    }
                }
            }
        }else {
            showAlertAction(title: "Unvalid values", message: "Please enter a valid email and password")
        }
    }
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Jump from the email textField to the password textField when pressing return button from the keyboard
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
            if ValidationService.validateEmail(email: emailTextfield.text!){
                userEmail = emailTextfield.text!
            }else {
                userEmail = ""
                emailTextfield.text = ""
                emailTextfield.placeholder = "Enter valid email"
                showAlertAction(title: "Unvalid email", message: "Please enter a valid email")
            }
        default:
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
    private func checkSignedInUser(){
    // Check if a user is still signed in if so go directly to the next view
        if AuthenticationService.checkSingedInUser() {
            // If the user is signed in perform segue to the DateViewController
            self.performSegue(withIdentifier: "DateSelection", sender: self)
        }
    }
    
    // Creates custom AlertAction to alert the user
    func showAlertAction(title: String, message: String){
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
    
    // Reset UI to registration form
    private func resetUIToRegister() {
        loginLabel.text = "Please Register"
        resetProperties()
    }
    
    // Reset UI to login form
    private func resetUIToLogin() {
        loginLabel.text = "Please Login"
        resetProperties()
    }
    
    // Reset the textfields to empty string
    private func resetTextFields() {
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    
    private func resetProperties() {
        userPassword = ""
        userEmail = ""
    }

    //MARK: Segue Prepare
    //override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //}
}
