//
//  ChangeEmailViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-15.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol EmailChangedProtocol {
    
    func emailWasChanged(email: String)
    
}

class ChangeEmailViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var newEmailView: UIView!
    @IBOutlet weak var newEmailTextField: UITextField!
    
    @IBOutlet weak var confirmNewEmailView: UIView!
    @IBOutlet weak var confirmNewEmailTextField: UITextField!
    
    @IBOutlet weak var saveChangesButton: RoundedButton!
    
    // MARK: - Properties
    var password:        String?
    var newEmail:        String?
    var confirmNewEmail: String?
    
    let firebaseAuth = Auth.auth()
    var delegate: EmailChangedProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the views that contain the text fields
        passwordView.layer.borderColor = UIColor.gray.cgColor
        passwordView.layer.borderWidth = 0.5
        
        newEmailView.layer.borderColor = UIColor.gray.cgColor
        newEmailView.layer.borderWidth = 0.5
        
        confirmNewEmailView.layer.borderColor = UIColor.gray.cgColor
        confirmNewEmailView.layer.borderWidth = 0.5
        
        // Setup the text fields
        passwordTextField.delegate = self
        newEmailTextField.delegate = self
        confirmNewEmailTextField.delegate = self
        
        // Setup the button
        saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }
    
}

// MARK: - Text Field Methods
extension ChangeEmailViewController: UITextFieldDelegate {
    
    @IBAction func passwordTextFieldEditing(_ sender: UITextField) {
        
        // Modify the stored password to match its respective text field
        password = passwordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func newEmailTextFieldEditing(_ sender: UITextField) {
        
        // Modify the stored new email to match its respective text field
        newEmail = newEmailTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func confirmNewEmailTextFieldEditing(_ sender: UITextField) {
        
        // Modify the stored confirm new email to match its respective text field
        confirmNewEmail = confirmNewEmailTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resign the responding text field
        textField.resignFirstResponder()
        
        // If on the password text field, move to the New Email Text Field
        if textField == passwordTextField {
            newEmailTextField.becomeFirstResponder()
        }
        // If on the New Email Text Field then move to the Confirm New Email Text Field
        else if textField == newEmailTextField {
            confirmNewEmailTextField.becomeFirstResponder()
        }
        
        return true
        
    }
    
    func lowerKeyboard() {
        
        // Lower the keyboard
        passwordTextField.resignFirstResponder()
        newEmailTextField.resignFirstResponder()
        confirmNewEmailTextField.resignFirstResponder()
        
    }
    
}

// MARK: - Save Changes Button Methods
extension ChangeEmailViewController {
    
    @IBAction func saveChangesButtonTapped(_ sender: UIButton) {
        
        // Disable the button
        saveChangesButton.isEnabled = false
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Start the progress animation
        ProgressService.progressAnimation(text: "Trying to Update Your Email")
        
        // Get the curren user and check that it is not nil
        let user = firebaseAuth.currentUser
        guard user != nil else { return }
        
        // Get the current users email and check that it isn't nil
        let oldEmail = user!.email
        guard oldEmail != nil else { return }
        
        // Create a credential from the users email and the password they typed in
        let credential = EmailAuthProvider.credential(withEmail: oldEmail!, password: password!)
        
        // Reauthenticate the user
        user?.reauthenticate(with: credential, completion: { (authResult, error) in
            
            // Check if the users credential was valid
            guard error == nil, authResult != nil else {
                self.saveChangesButton.isEnabled = true
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            // Check to see if the new emails match
            guard self.newEmail!.uppercased() == self.confirmNewEmail!.uppercased() else {
                self.saveChangesButton.isEnabled = true
                ProgressService.errorAnimation(text: "Emails Do Not Match")
                return
            }
            
            // Check if the new email is different than the old email
            guard self.newEmail!.uppercased() != oldEmail!.uppercased() else {
                self.saveChangesButton.isEnabled = true
                ProgressService.errorAnimation(text: "Your Email is Already \(self.newEmail!)")
                return
            }
            
            // Attempt to update the users email
            user!.updateEmail(to: self.newEmail!, completion: { (error) in
                
                // Check if there were any errors
                guard error == nil else {
                    self.saveChangesButton.isEnabled = true
                    ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                    return
                }
                
                // Store the user with their new email
                let user = UserInfo(id: Stored.user!.id, firstName: Stored.user!.firstName, lastName: Stored.user!.lastName, email: self.newEmail!)
                
                // Update the users email in the database
                FirestoreService.writeUser(user: user, completion: { (error) in
                    
                    // Check if there were any errors
                    guard error == nil else {
                        ProgressService.errorAnimation(text: "Unable to Update Your Email")
                        self.saveChangesButton.isEnabled = true
                        return
                    }
                    
                    // Show that the process was successful
                    ProgressService.successAnimation(text: "Successfully Updated Your Email to \(self.newEmail!)")
                    
                    // Save the changes locally
                    LocalStorageService.writeUser(user: user)
                    Stored.user = user
                    
                    // Tell the settings that the email was changed
                    self.delegate?.emailWasChanged(email: self.newEmail!)
                    
                    // Return to the settings page
                    self.navigationController?.popViewController(animated: true)
                })
                
            })
            
        })
        
    }
    
    func checkToActivateButton() {
        
        // Check to see if all the text fields have been filled out
        guard password != nil, password!.count > 0, newEmail != nil, newEmail!.count > 0, confirmNewEmail != nil, confirmNewEmail!.count > 0 else {
            saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        saveChangesButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
}
