//
//  LoginViewController.swift
//  iNav UW
//
//  Created by Nicholas Spiroff on 11/28/18.
//  Copyright © 2018 CS506. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var loggingIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func selectorChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            loggingIn = false
            actionButton.setTitle("Signup", for: .normal)
        }
        else {
            loggingIn = true
            actionButton.setTitle("Login", for: .normal)
        }
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        // Check if the input is valid.
        if let email = emailTextField.text, let pass = passwordTextField.text {
            if loggingIn {
                doUserLogin(email: email, pass: pass)
            } else {
                doUserSignUp(email: email, pass: pass)
            }
        }
    }
    
    @IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func doUserSignUp(email : String, pass: String) {
        if (pass.count > 6 && email.count != 0 && email.range(of: "@") != nil){
            // if isSignIn {
            Auth.auth().createUser(withEmail: email, password: pass, completion: { (user, error) in
                if error == nil && user != nil {
                    print("User Created!")
                    self.performSegue(withIdentifier: "Enter", sender: nil)
                } else {
                    // Error.
                    print("Error creating user: \(error!.localizedDescription)")
                }
            })
        }
    }
    
    func doUserLogin(email: String, pass: String) {
        if (pass.count > 6 && email.count != 0 && email.range(of: "@") != nil) {
            
            Auth.auth().signIn(withEmail: email, password: pass, completion: { (user, error) in
                if error == nil && user != nil {
                    print("Logged In!")
                    self.performSegue(withIdentifier: "Enter", sender: nil)
                } else {
                    // Error.
                    print("Error Logging in: \(error!.localizedDescription)")
                }
            })
        }
    }
}
