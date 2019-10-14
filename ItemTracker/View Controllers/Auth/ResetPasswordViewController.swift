//
//  ResetPasswordViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-09-08.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var resetPasswordButton: RoundedButton!
    
    // Properties
    var email: String?
    
    // MARK: - Initialization Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the content view
        self.view.isHidden = true
        
        // Setup the email text field
        emailTextField.delegate = self
        emailTextField.addBottomLine(color: UIColor.lightGray, width: 1)
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        // Slide the view in
        slideViewIn()
        
    }
    
}

// MARK: - Button Methods
extension ResetPasswordViewController {
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        
        // Dismiss the reset password vc
        slideViewOut()
        
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: RoundedButton) {
        
        // Complete some initial check before sending the request to thr server
        guard email != nil, email!.count > 0 else {
            ProgressService.errorAnimation(text: "Please fill out the email text field")
            return
        }
        
        // Disable the UI
        self.view.isUserInteractionEnabled = false
        
        // Attempt to send the user a link to reset their password
        FirebaseAuthService.attemptResetPassword(email: email!) { (error) in
            
            self.view.isUserInteractionEnabled = true
            
            // Check if there was an error
            guard error == nil else {
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            // Show that the password email was sent
            ProgressService.successAnimation(text: "An email was sent to reset your password")
            
        }
        
    }
    
}

// MARK: - Text Field Methods
extension ResetPasswordViewController: UITextFieldDelegate {
    
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
        email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
    }
    
    @IBAction func emailTextFieldEndedEditing(_ sender: CustomTextField) {
        
        // Unhighlight the underline
        self.emailTextField.addBottomLine(color: UIColor.lightGray, width: 1)
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Lower the keyboard
        textField.resignFirstResponder()
        return true
        
    }
    
}

// MARK: - Animation Methods
extension ResetPasswordViewController {
    
    func slideViewIn() {
        
        self.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
        self.view.isHidden = false
        
        // Slide the view to the center of the screen
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.view.transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideViewOut() {
        
        // Slide the view out to off the right side
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            self.view.transform = CGAffineTransform(translationX: UIScreen.main.bounds.width, y: 0)
            self.view.layoutIfNeeded()
            
        }) { (true) in
            self.dismiss(animated: false, completion: nil)
        }
        
    }
    
}
