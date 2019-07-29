//
//  ChangeNameViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-12.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

protocol NameChangedProtocol {
    
    func nameWasChanged(name: String)
    
}

class ChangeNameViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var saveChangesButton: RoundedButton!
    
    // MARK: - Properties
    var newFirstName: String?
    var newLastName : String?
    
    var delegate: NameChangedProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the views for the text field
        firstNameView.layer.borderColor = UIColor.gray.cgColor
        firstNameView.layer.borderWidth = 0.5
        
        lastNameView.layer.borderColor = UIColor.gray.cgColor
        lastNameView.layer.borderWidth = 0.5

        // Setup the text fields
        firstNameTextField.delegate  = self
        firstNameTextField.tintColor = Constants.Color.primary
        
        lastNameTextField.delegate   = self
        lastNameTextField.tintColor  = Constants.Color.primary
        
        // Setup the button
        saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }

}

// MARK: - Text Field Methods
extension ChangeNameViewController: UITextFieldDelegate {
    
    @IBAction func firstNameTextFieldEditing(_ sender: UITextField) {
        
        // Change the stored text
        newFirstName = firstNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func lastNameTextFieldEditing(_ sender: UITextField) {
        
        // Change the stored text
        newLastName = lastNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resign the active text fields
        textField.resignFirstResponder()
        
        // Move to the lastNameTextField if on first name
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        }
        
        return true
    }
    
}

// MARK: - Save Changes Button Methods
extension ChangeNameViewController {
    
    @IBAction func saveChangesButtonTapped(_ sender: UIButton) {
        
        // Disable the button to prevent multiple taps
        saveChangesButton.isEnabled = false
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Check if the user has internet connection
        guard InternetService.checkForConnection() == true else {
            saveChangesButton.isEnabled = true
            ProgressService.errorAnimation(text: "No Internet Connection")
            return
        }
        
        // Start the progress animation
        ProgressService.progressAnimation(text: "Trying to Update Your Name")
        
        // Collect the users information keeping the same names
        let user = UserInfo(id: Stored.user!.id, firstName: newFirstName!, lastName: newLastName!, email: Stored.user!.email)
        
        // Check if the new name is different from the old name
        guard newFirstName! != Stored.user!.firstName || newLastName! != Stored.user!.lastName else {
                saveChangesButton.isEnabled = true
                ProgressService.errorAnimation(text: "Your Name is Already \(newFirstName!) \(newLastName!)")
                return
        }
        
        // Attempt to update the users document in firestore
        FirestoreService.writeUser(user: user) { (error) in
            
            // Check if the update was successful
            guard error == nil else {
                ProgressService.errorAnimation(text: "Unable to Update Your Name")
                return
            }
            
            // Show that the update was successful
            ProgressService.successAnimation(text: "Successfully Updated Your Name to \(self.newFirstName!) \(self.newLastName!)")
            
            // Update the user locally
            LocalStorageService.writeUser(user: user)
            Stored.user = user
            
            self.delegate?.nameWasChanged(name: "\(self.newFirstName!) \(self.newLastName!)")
            
            // Return to the settings page
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
    
    func checkToActivateButton() {
        
        // Check that both fields have been filled out, otherwise disable the button
        guard newFirstName != nil, newFirstName!.count > 0, newLastName != nil, newLastName!.count > 0 else {
            saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        saveChangesButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
}

// MARK: - Helper Methods
extension ChangeNameViewController {
    
    func lowerKeyboard() {
        
        // Lower the keyboard
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        
    }
    
}
