//
//  ChangeNameViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-12.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class ChangeNameViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var saveChangesButton: UIButton!
    
    // MARK: - Properties
    var newFirstName: String?
    var newLastName : String?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the text fields
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        // Setup the button
        saveChangesButton.layer.cornerRadius = Constants.View.CornerRadius.bigButton
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
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
        
        textField.resignFirstResponder()
        
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
        
        let user = UserInfo(firstName: newFirstName!, lastName: newLastName!, email: Stored.user!.email)
        UserService.writeUserProfile(user: user) { (error) in
            
            if error == nil {
                LocalStorageService.writeUser(user: user)
                Stored.user = user
                
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.present(AlertService.createErrorAlert(error: error! as NSError),
                             animated: true,
                             completion: nil)
            }
            
        }
        
    }
    
}

// MARK: - Helper Methods
extension ChangeNameViewController {
    
    func checkToActivateButton() {
        
        // Check that both fields have been filled out, otherwise disable the button
        guard newFirstName != nil, newFirstName!.count > 0, newLastName != nil, newLastName!.count > 0 else {
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        saveChangesButton.isEnabled = isActivated
        saveChangesButton.backgroundColor = color
        
    }
    
}
