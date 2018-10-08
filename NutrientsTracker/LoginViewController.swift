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
    
    //MARK: ViewController Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // When the view will appear check first if a user is already singed in
        checkSingedInUser()
    }
    
    //MARK: IBActions
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        // When the segmentControl is switched , switch the segmentContol values
        segmentIsLogin = !segmentIsLogin
        // When the segmentControl values are changed check the state and reset the UI to the correct action
        if segmentIsLogin {
            resetUIToLogin()
        }else {
            resetUIToRegister()
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        // Validate email and password
        if validateLogin() {
            let email = emailTextfield.text!
            let password = passwordTextfield.text!
            // If login is selected
            if segmentIsLogin {
                // Sign in an existing user
                Auth.auth().signIn(withEmail: email, password: password) { (userData, error) in
                    // Check if the user exists
                    if (userData?.user) != nil {
                        // Reset the textfields with default values
                        self.resetTextFields()
                        // Display the next view afer the succesful sign in
                        self.performSegue(withIdentifier: "DateSelection", sender: self)
                    }else {
                        // Show custom alert message when login was failed
                        self.showAlertAction(title: "No User Found", message: "No user found with this email and password")
                    }
                }
            }else{
                // Create a new user
                Auth.auth().createUser(withEmail: email, password: password) { (userData, error) in
                    // Check if the creaded user was succesfull added to the api
                    if (userData?.user) != nil {
                        // Reset the textfields with default values
                        self.resetTextFields()
                        // Show custom alert message when the registration is succesfull
                        self.showAlertAction(title: "Registration Complete", message: "Please enter  email and password to login")
                    }else{
                        // Show custom alert message when registration was failed
                        self.showAlertAction(title: "Could Not Register", message: "Please try again")
                    }
                }
            }
        }
    }
    
    //MARK: Helper Functions
    private func checkSingedInUser(){
    // Check if there is stil a singed in user tracked by the web API if not this function will return nil and nothing more will happen
        if AuthenticationService.checkSingedInUser() {
            // If a user is already signed in, pass the login screen and give access to the app because this user is currently signed in display the next screen after the login view
            self.performSegue(withIdentifier: "DateSelection", sender: self)
        }
    }
    
    // Validate email and password by checking for empty values, @ value for email and password length
    func validateLogin() -> Bool {
        let email = emailTextfield.text!
        let password = passwordTextfield.text!
        
        if !email.isEmpty {
            if !password.isEmpty {
                if email.contains("@") && password.count > 3{
                    return true
                }else {
                    showAlertAction(title: "Unvalid Values", message: "Please enter correct email and password")
                    return false
                }
            }else {
                showAlertAction(title: "Unvalid Password", message: "Please enter a valid password")
                return false
            }
        }else {
            showAlertAction(title: "Unvalid Email", message: "Please enter a valid email")
            return false
        }
    }
    
    // Creates custom AlertActions to alert the user
    func showAlertAction(title: String, message: String){
        // Create the UIAlertController with the given values
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Create the UIAlertAction to display a Ok button and dismisses the alert after it is pressed
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
        }
        // Adding the UIAlertAction to the UIAlertController
        alert.addAction(action)
        // Displaying the alert view
        present(alert, animated: true, completion: nil)
    }
    
    // Reset the UI matching to a registration form
    private func resetUIToRegister() {
        loginLabel.text = "Please Register"
        loginButton.setTitle("Register", for: .normal)
    }
    
    // Reset the UI matching to a login form
    private func resetUIToLogin() {
        loginLabel.text = "Please Login"
        loginButton.setTitle("Login", for: .normal)
    }
    
    // Reset the 2 textfields to an empty string
    private func resetTextFields() {
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    
    //MARK: UITextfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextfield:
            passwordTextfield.becomeFirstResponder()
        default:
            passwordTextfield.resignFirstResponder()
        }
        return true
    }

    //MARK: Segue Prepare
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
