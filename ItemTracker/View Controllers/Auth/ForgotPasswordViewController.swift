//
//  ForgotPasswordViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-28.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

// MARK: - Forgot Password Protocol
protocol ForgotPasswordProtocol {
    
    func goBackToLogin()
    
}

final class ForgotPasswordViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewX: NSLayoutConstraint!
    @IBOutlet weak var floatingViewToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    // MARK: - ForgotPasswordViewController Properties
    var delegate: ForgotPasswordProtocol?
    
    var email: String?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the forgotPasswordVIew
        floatingView.backgroundColor    = Constants.Color.floatingView
        floatingView.layer.cornerRadius = Constants.View.CornerRadius.standard
        floatingViewWidth.constant      = Constants.View.Width.standard
        floatingViewX.constant          = UIScreen.main.bounds.width
        floatingViewHeight.constant           = Constants.View.Height.forgotPassword
        floatingViewToBottom.constant         = UIScreen.main.bounds.height * 0.3
        
        // Setup the navigation bar
        backButton.tintColor             = Constants.Color.primary
        navigationBar.layer.cornerRadius = Constants.View.CornerRadius.standard
        navigationBar.clipsToBounds      = true
        
        // Setup the text field
        emailTextField.keyboardType    = .emailAddress
        emailTextField.textContentType = .emailAddress
        emailTextField.placeholder     = "Email Address"
        
        // Setup the button
        resetPasswordButton.layer.cornerRadius = Constants.View.CornerRadius.bigButton
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
        // Create a listener for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // Get the keyboard frame
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            // Get the height of the keyboard
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            // If the keyboard height is too low then don't adjust the view
            guard keyboardHeight > UIScreen.main.bounds.height * 0.2 else { return }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                
                // Move the view to just above the keyboard
                self.floatingViewToBottom.constant = keyboardHeight + 15
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Slide the view into the frame
        slideViewIn()
        
    }

    // MARK: - IBAction Methods
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Slide the view out to the right
        slideViewOut {
            
            // Dismiss the current view and then present the loginVC
            self.dismiss(animated: false, completion: {
                self.delegate!.goBackToLogin()
            })
        }
        
    }
    
    @IBAction func emailTextFieldEditing(_ sender: UITextField) {
        
        // Store the email textfields text
        email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
        checkToActivateButton()
        
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        
        // Temporarily disable the button and lower the keyboard
        resetPasswordButton.isEnabled = false
        emailTextField.resignFirstResponder()
        
        // Start a progress animation
        ProgressService.progressAnimation(text: "Trying to Send You an Email")
        
        // Send the password reset email
        Auth.auth().sendPasswordReset(withEmail: email!) { error in
            
            // If there is an error, print an appropriate error message
            guard error == nil else {
                self.resetPasswordButton.isEnabled = true
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            ProgressService.successAnimation(text: "Email to Reset Password was Sent")
            
        }
        
    }
    
}

// MARK: - Helper Methods
extension ForgotPasswordViewController {
    
    func checkToActivateButton() {
        
        // If the text field is empty, deactivate the button
        guard email != nil && email!.count > 0 else {
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Otherwise, activate it
        activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Disables or Enables the button and sets the button background color
        resetPasswordButton.isEnabled = isActivated
        resetPasswordButton.backgroundColor = color
        
    }
    
}

// MARK: - Methods relating to animation
extension ForgotPasswordViewController {
    
    func slideViewIn() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.floatingViewX.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideViewOut(completion: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            self.floatingViewX.constant = UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
            
        }) { (true) in
            
            completion()
            
        }
        
    }
    
}
