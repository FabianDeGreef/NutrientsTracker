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
    
    var segmentIsLogin:Bool = true
    
    //MARK: IBActions

    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        segmentIsLogin = !segmentIsLogin
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
            // Firebase Auth
            if segmentIsLogin {
                Auth.auth().signIn(withEmail: email, password: password) { (userData, error) in
                    if (userData?.user) != nil {
                        self.performSegue(withIdentifier: "DateSelection", sender: self)
                    }else {
                        //Error
                        self.showAlertAction(title: "No User Found", message: "No user found with this email and password")
                    }
                }
            }else{
                Auth.auth().createUser(withEmail: email, password: password) { (userData, error) in
                    //guard (userData?.user) != nil else {return}
                    if (userData?.user) != nil {
                        self.segmentControl.selectedSegmentIndex = 0
                        self.resetTextFields()
                        self.showAlertAction(title: "Registration Complete", message: "Please enter  email and password to login")
                    }else{
                        //Error
                        self.showAlertAction(title: "Could Not Register", message: "Please try again")
                    }
                }
            }
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
    
    // Creates AlertActions to alert the user
    func showAlertAction(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (UIAlertAction) in
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Private Methods
    
    private func resetUIToRegister() {
        loginLabel.text = "Please Register"
        loginButton.setTitle("Register", for: .normal)
    }
    
    private func resetUIToLogin() {
        loginLabel.text = "Please Login"
        loginButton.setTitle("Login", for: .normal)
    }
    
    private func resetTextFields() {
        emailTextfield.text = ""
        passwordTextfield.text = ""
    }
    

    //MARK:  Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
