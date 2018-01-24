//
//  SignInVC.swift
//  RiderApp
//
//  Created by Sergio Manrique on 1/18/18.
//  Copyright © 2018 smm. All rights reserved.
//

import UIKit

class SignInVC: UIViewController {
    
    private let RIDER_SEGUE = "RiderVCSegue"
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logIn(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != ""{
            
            AuthProvider.Instance.login(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil{
                    self.alertTheUser(title: "Problem With Authentication", message: message!)
                }else{
                    
                    UberHandler.Instance.driver = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                    print("LOGIN COMPLETED")
                }
            })
            
        }else{
            alertTheUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields")
        }
        
    }
    
    @IBAction func signUp(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" {
            
            AuthProvider.Instance.signUp(withEmail: emailTextField.text!, password: passwordTextField.text!, loginHandler: { (message) in
                
                if message != nil {
                    self.alertTheUser(title: "Problem With Creating A New User", message: message!)
                }else{
                    
                    UberHandler.Instance.driver = self.emailTextField.text!
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    
                    self.performSegue(withIdentifier: self.RIDER_SEGUE, sender: nil)
                    print("CREATING USER COMPLETED")
                }
            })
            
        }else{
            alertTheUser(title: "Email And Password Are Required", message: "Please enter email and password in the text fields")
        }
        
    }
    
    private func alertTheUser(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}






















