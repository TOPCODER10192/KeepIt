//
//  LinkAccountViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-08-14.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol LinkAccountProtocol {
    
    func accountLinked()
    
}

final class LinkAccountViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var linkAccountButton: RoundedButton!
    
    // MARK: - Properties
    var email: String?
    var password: String?
    
    var delegate: LinkAccountProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the views for the text fields
        emailView.layer.borderColor = UIColor.gray.cgColor
        emailView.layer.borderWidth = 0.5
        
        passwordView.layer.borderColor = UIColor.gray.cgColor
        passwordView.layer.borderWidth = 0.5
        
        // Setup the text fields
        emailTextField.delegate   = self
        emailTextField.tintColor  = Constants.Color.primary
        
        passwordTextField.delegate   = self
        passwordTextField.tintColor  = Constants.Color.primary
        
        // Setup the link account button
        linkAccountButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }
    
}

// MARK: - Text Field Methods
extension LinkAccountViewController: UITextFieldDelegate {
    
    @IBAction func emailTextFieldEditing(_ sender: UITextField) {
        
        // Set the value for the text field
        self.email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func passwordTextFieldEditing(_ sender: UITextField) {
        
        // Set the value for the text field
        self.password = passwordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resign the text field
        textField.resignFirstResponder()
        
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        return true
        
    }
    
}

// MARK: - Button Methods
extension LinkAccountViewController {
    
    @IBAction func linkAccountButtonTapped(_ sender: RoundedButton) {
        
        // Get the current user
        guard let user = Auth.auth().currentUser else { return }
        
        // Create a credential
        let credential = EmailAuthProvider.credential(withEmail: email!, password: password!)
        
        // Disable the button
        linkAccountButton.activateButton(isActivated: false, color: Constants.Color.primary)
        
        // Check that the user has internet
        guard InternetService.checkForConnection() == true else {
            ProgressService.errorAnimation(text: "No Internet Connection")
            linkAccountButton.activateButton(isActivated: true, color: Constants.Color.primary)
            return
        }
        
        // Start a progress animation
        ProgressService.progressAnimation(text: "Trying to link your account")
        
        // Link the user
        user.link(with: credential) { (dataResult, error) in
            
            // Check if the process was successful
            guard error == nil, dataResult != nil else {
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                self.linkAccountButton.activateButton(isActivated: true, color: Constants.Color.primary)
                return
            }
            
            // Store the user locally
            LocalStorageService.writeUser(id: user.uid, email: user.email!)
            
            // Show the process was successsful
            ProgressService.successAnimation(text: "Successfully linked your account")
            
            self.navigationController?.popViewController(animated: true)
            self.delegate?.accountLinked()
                
            
        }
        
    }
    
    func checkToActivateButton() {
        
        // Check if all the text field have been filled out
        guard email != nil, password != nil else {
            linkAccountButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        guard email!.count > 0, password!.count > 0 else {
            linkAccountButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        linkAccountButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
}
