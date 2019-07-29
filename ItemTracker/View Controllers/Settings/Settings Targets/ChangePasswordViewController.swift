//
//  ChangePasswordViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-17.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {

    // MARK: - IBOUtlet Properties
    @IBOutlet weak var oldPasswordView: UIView!
    @IBOutlet weak var oldPasswordTextField: UITextField!
    
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var confirmNewPasswordView: UIView!
    @IBOutlet weak var confirmNewPasswordTextField: UITextField!
    
    @IBOutlet weak var saveChangesButton: RoundedButton!
    
    // MARK: - Properties
    var oldPassword: String?
    var newPassword: String?
    var confirmNewPassword: String?
    
    let firebaseAuth = Auth.auth()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the text field views
        oldPasswordView.layer.borderColor = UIColor.gray.cgColor
        oldPasswordView.layer.borderWidth = 0.5
        
        newPasswordView.layer.borderColor = UIColor.gray.cgColor
        newPasswordView.layer.borderWidth = 0.5
        
        confirmNewPasswordView.layer.borderColor = UIColor.gray.cgColor
        confirmNewPasswordView.layer.borderWidth = 0.5
        
        // Setup the text fields
        oldPasswordTextField.delegate            = self
        oldPasswordTextField.tintColor           = Constants.Color.primary
        oldPasswordTextField.leftView?.tintColor = UIColor.black
        
        newPasswordTextField.delegate            = self
        newPasswordTextField.tintColor           = Constants.Color.primary
        
        confirmNewPasswordTextField.delegate     = self
        confirmNewPasswordTextField.tintColor    = Constants.Color.primary
        
        // Setup the save changes button
        saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }
    
}

// MARK: - Text Field Methods
extension ChangePasswordViewController: UITextFieldDelegate {
    
    @IBAction func oldPasswordTextFieldEditing(_ sender: UITextField) {
        
        // Pull the password out of the text field
        oldPassword = oldPasswordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func newPasswordTextFieldEditing(_ sender: UITextField) {
        
        // Pull the password out of the text field
        newPassword = newPasswordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func confirmNewPasswordTextFieldEditing(_ sender: UITextField) {
        
        // Pull the password out of the text field
        confirmNewPassword = confirmNewPasswordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resign the active text field
        textField.resignFirstResponder()
        
        // Move to the next text field
        if textField == oldPasswordTextField {
            newPasswordTextField.becomeFirstResponder()
        }
        else if textField == newPasswordTextField {
            confirmNewPasswordTextField.becomeFirstResponder()
        }
        
        return true
        
    }
    
    func lowerKeyboard() {
        
        // Lower the keyboard
        oldPasswordTextField.resignFirstResponder()
        newPasswordTextField.resignFirstResponder()
        confirmNewPasswordTextField.resignFirstResponder()
        
    }
    
}

// MARK: - Save Changes Button Methods
extension ChangePasswordViewController {
    
    @IBAction func saveChangesButtonTapped(_ sender: UIButton) {
        
        // Disable the button
        saveChangesButton.isEnabled = false
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Check if the user has internet connection
        
        // Start the progress animation
        ProgressService.progressAnimation(text: "Trying to Update Your Password")
        
        // Get the current user and check that it is not nil
        guard let user = firebaseAuth.currentUser else { return }
        
        // Get the current users email and check that it isn't nil
        guard let email = user.email else { return }
        
        // Create a credential from the users email and the password they typed in
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword!)
        
        // Reauthenticate the user
        user.reauthenticate(with: credential) { (authResult, error) in
            
            // Check if the users credential was valid
            guard error == nil, authResult != nil else {
                self.saveChangesButton.isEnabled = true
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            // Check to see if the new passwords match
            guard self.newPassword!.uppercased() == self.confirmNewPassword!.uppercased() else {
                self.saveChangesButton.isEnabled = true
                ProgressService.errorAnimation(text: "Passwords Do Not Match")
                return
            }
            
            user.updatePassword(to: self.newPassword!, completion: { (error) in
                
                // Check if the process was successful
                guard error == nil else {
                    self.saveChangesButton.isEnabled = true
                    ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                    return
                }
                
                // Show that the process was successful
                ProgressService.successAnimation(text: "Successfully Updated Your Password")
                
                // Return to the settings page
                self.navigationController?.popViewController(animated: true)
                
            })
            
        }
        
    }
    
    func checkToActivateButton() {
        
        // Check if the text fields are filled
        guard oldPassword != nil, oldPassword!.count > 0,
              newPassword != nil, newPassword!.count > 0,
              confirmNewPassword != nil, confirmNewPassword!.count > 0 else {
            
                saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
                return
                
        }
        
        // Activate the button if they are
        saveChangesButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
}
