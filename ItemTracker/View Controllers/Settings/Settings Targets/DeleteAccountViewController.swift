//
//  DeleteAccountViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-19.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class DeleteAccountViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var passwordTextField: CustomTextField!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    // MARK: - Properties
    var password: String?

    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the password view
        passwordView.layer.borderColor = UIColor.lightGray.cgColor
        passwordView.layer.borderWidth = 0.5
        
        // Setup the password text field
        passwordTextField.delegate = self
        
        // Setup the delete account button
        deleteAccountButton.layer.cornerRadius = Constants.View.CornerRadius.bigButton
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }
    
}

// MARK: - Text Field Methods
extension DeleteAccountViewController: UITextFieldDelegate {
    
    @IBAction func passwordTextFieldEditing(_ sender: UITextField) {
        
        // Set the password to match the text field
        password = passwordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to se if the button should be activated
        checkToActivateButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Lower the keyboard
        textField.resignFirstResponder()
        
        return true
        
    }
    
}

// MARK: - Delete Account Button Methods
extension DeleteAccountViewController {
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        
        // Disable the button
        deleteAccountButton.isEnabled = false
        
        // Show a progress animation
        ProgressService.progressAnimation(text: "Trying to Delete Your Account")
        
        FirestoreService.deleteUser(password: password!) { (error) in
            
            guard error == nil else {
                self.deleteAccountButton.isEnabled = true
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            // Show that the deletion was successful
            ProgressService.successAnimation(text: "Successfully Deleted Your Account")
            
            // Clear local storage
            LocalStorageService.clearUser()
            
            // Create the authVC
            let authVC = UIStoryboard(name: Constants.ID.Storyboard.auth, bundle: .main)
                .instantiateViewController(withIdentifier: Constants.ID.VC.backgroundAuth) as! BackgroundViewController
            
            // Present the Auth VC
            self.view.window?.rootViewController = authVC
            self.view.window?.makeKeyAndVisible()
            
        }
        
    }
    
    func checkToActivateButton() {
        
        // Check if the password text field is filled
        guard password != nil, password!.count > 0 else {
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        activateButton(isActivated: true, color: Constants.Color.deleteButton)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Set the buttons properties based on the parameters
        deleteAccountButton.isEnabled = isActivated
        deleteAccountButton.backgroundColor = color
        
    }
    
}
