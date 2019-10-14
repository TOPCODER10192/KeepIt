//
//  SignUpViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-09-07.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var signUpButton: RoundedButton!
    
    // MARK: - Properties
    var email: String?
    var password: String?
    
    // MARK: - Initialization Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the email text field
        emailTextField.delegate = self
        emailTextField.addBottomLine(color: UIColor.lightGray, width: 1)
        
        // Setup the password text field
        passwordTextField.delegate = self
        passwordTextField.addBottomLine(color: UIColor.lightGray, width: 1)
        
    }
    
}

// MARK: - Button Methods
extension SignUpViewController {
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Dismiss all the view controllers
        self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func signUpButtonTapped(_ sender: RoundedButton) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Do some initial checks before sending the request
        guard checkValidCredentials() == true else { return }
        
        // Disable the UI
        self.view.isUserInteractionEnabled = false
        
        // Show a progress animation
        ProgressService.progressAnimation(text: "Trying to sign you up")
        
        // Attempt to sign up the user with the provided credentials
        FirebaseAuthService.attemptSignUp(email: email!, password: password!) { (error) in
            
            // Check if there is an error
            guard error == nil else {
                self.view.isUserInteractionEnabled = true
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            // Show a success animation
            ProgressService.successAnimation(text: "Successfully signed up")
            
            // Go into the app
            self.goIntoApp()
            
        }
        
    }
    
    @IBAction func goToLoginButtonTapped(_ sender: UIButton) {
        
        // Create a new login vc
        guard let userLoginVC = storyboard?.instantiateViewController(withIdentifier: Constants.ID.VC.userLogin) as? UserLoginViewController else {
            return
        }
        
        // Set the transition and presentation style
        userLoginVC.modalTransitionStyle = .crossDissolve
        userLoginVC.modalPresentationStyle = .overFullScreen
        
        // Present the login vc
        present(userLoginVC, animated: true, completion: nil)
        
    }
    
}


// MARK: - Text Field Methods
extension SignUpViewController: UITextFieldDelegate {
    
    @IBAction func emailTextFieldBeganEditing(_ sender: CustomTextField) {
        
        // Highlight the underline
        self.emailTextField.addBottomLine(color: Constants.Color.primary, width: 1)
        
        // Raise, shrink, recolor the Email Placeholder Text
        UIView.animate(withDuration: 0.2) {
            
            self.emailLabel.textColor = Constants.Color.primary
            self.emailLabel.font = UIFont(name: "SFProText-Bold", size: 16)
            self.emailLabel.transform = CGAffineTransform(translationX: 0, y: -25)
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    @IBAction func emailTextFieldTextChanged(_ sender: CustomTextField) {
        
        // Store the users typed in email
        self.email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
    }
    
    @IBAction func emailTextFieldEndedEditing(_ sender: CustomTextField) {
        
        // Unhighlight the underline
        self.emailTextField.addBottomLine(color: UIColor.gray, width: 1)
        
        // Check if there is any text
        guard emailTextField.text == nil || emailTextField.text!.trimmingCharacters(in: .whitespaces).count == 0 else { return }
        
        // Put the placeholder back
        UIView.animate(withDuration: 0.2) {
            
            self.emailLabel.textColor = UIColor.lightGray
            self.emailLabel.font = UIFont(name: "SFProText", size: 20)
            self.emailLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    @IBAction func passwordTextFieldBeganEditing(_ sender: CustomTextField) {
        
        // Highlight the underline
        self.passwordTextField.addBottomLine(color: Constants.Color.primary, width: 1)
        
        // Raise, shrink, recolor the Email Placeholder Text
        UIView.animate(withDuration: 0.2) {
            
            self.passwordLabel.textColor = Constants.Color.primary
            self.passwordLabel.font = UIFont(name: "SFProText-Bold", size: 16)
            self.passwordLabel.transform = CGAffineTransform(translationX: 0, y: -25)
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    @IBAction func passwordTextFieldTextChanged(_ sender: CustomTextField) {
        
        // Store the users typed in password
        self.password = passwordTextField.text
        
    }
    
    @IBAction func passwordTextFieldEndedEditing(_ sender: CustomTextField) {
        
        // Unhighlight the underline
        self.passwordTextField.addBottomLine(color: UIColor.lightGray, width: 1)
        
        // Check if there is any text
        guard passwordTextField.text == nil || passwordTextField.text!.trimmingCharacters(in: .whitespaces).count == 0 else { return }
        
        // Put the placeholder back
        UIView.animate(withDuration: 0.2) {
            
            self.passwordLabel.textColor = UIColor.lightGray
            self.passwordLabel.font = UIFont(name: "SFProText", size: 20)
            self.passwordLabel.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resign the text field as first responder
        textField.resignFirstResponder()
        
        // Move to the next text field
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        return true

    }
    
}

// MARK: - Helper Methods
extension SignUpViewController {
    
    func checkValidCredentials() -> Bool {
        
        // Check that both the email and password are not nil
        guard let email = self.email, let password = self.password else {
            ProgressService.errorAnimation(text: "All text fields must be filled out")
            return false
        }
        
        // Check that both the email and password have text
        guard email.count > 0, password.count > 0 else {
            ProgressService.errorAnimation(text: "All text fields must be filled out")
            return false
        }
        
        // Check that the users passwords is strong enough
        guard password.count >= 6 else {
            ProgressService.errorAnimation(text: "Your password must be 6 characters or longer")
            return false
        }
        
        return true
        
    }
    
    func lowerKeyboard() {
        
        // Lower the keyboard
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
    func goIntoApp() {
        
        let tabBarVC = UIStoryboard(name: Constants.ID.Storyboard.tabBar, bundle: .main)
            .instantiateViewController(withIdentifier: Constants.ID.VC.tabBar)
        
        present(tabBarVC, animated: true, completion: nil)
        
        
    }

}
