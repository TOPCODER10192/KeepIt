//
//  ForgotPasswordViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-28.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import Firebase

protocol ForgotPasswordProtocol {
    func goBackToLogin()
}

class ForgotPasswordViewController: UIViewController {
    
    // MARK:- IBOutlet Properties
    @IBOutlet weak var forgotPasswordView: UIView!
    @IBOutlet weak var forgotPasswordViewWidth: NSLayoutConstraint!
    @IBOutlet weak var forgotPasswordViewX: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorViewY: NSLayoutConstraint!
    
    // MARK: - ForgotPasswordViewController Properties
    var delegate: ForgotPasswordProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the forgotPasswordVIew
        forgotPasswordView.backgroundColor    = Constants.FLOATING_VIEW_COLOR
        forgotPasswordView.layer.cornerRadius = Constants.GENERAL_CORNER_RADIUS
        forgotPasswordViewWidth.constant      = Constants.FORGOT_PASSWORD_VIEW_WIDTH
        forgotPasswordViewX.constant          = UIScreen.main.bounds.width
        
        // Setup the navigation bar
        backButton.tintColor = Constants.PRIMARY_COLOR
        navigationBar.layer.cornerRadius = Constants.GENERAL_CORNER_RADIUS
        navigationBar.clipsToBounds = true
        
        // Setup the text field
        emailTextField.keyboardType = .emailAddress
        emailTextField.placeholder = "Email Address"
        emailTextField.textContentType = .emailAddress
        
        // Setup the button
        resetPasswordButton.backgroundColor = Constants.PRIMARY_COLOR
        resetPasswordButton.layer.cornerRadius = Constants.BUTTON_CORNER_RADIUS
        activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
        
        // Setup the error view
        errorView.alpha = 0
        errorView.layer.cornerRadius = Constants.GENERAL_CORNER_RADIUS
        errorView.backgroundColor = Constants.ERROR_COLOR
        errorViewY.constant = Constants.ERROR_VIEW_Y
        
        // Create a listener for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // Get the keyboard frame
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            // Get the height of the keyboard
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            // If the keyboard height is too low then dont adjust the view
            guard keyboardHeight > UIScreen.main.bounds.height * 0.2 else { return }
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
                
                // Move the view to just above the keyboard
                self.errorViewY.constant = keyboardHeight + 5
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Slide the view into the frame
        slideViewIn()
        
    }

}

// MARK:- IBAction Methods
extension ForgotPasswordViewController {
    
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        
        // Slide the view out to the right
        slideViewOut {
            
            // Dismiss the current view and then present the loginVC
            self.dismiss(animated: false, completion: {
                self.delegate!.goBackToLogin()
            })
        }
        
    }
    
    @IBAction func emailTextFieldEditing(_ sender: UITextField) {
        
        // Check if the button should be activated
        if emailTextField.text != nil && emailTextField.text!.trimmingCharacters(in: .whitespaces).count > 0 {
            activateButton(isActivated: true, color: Constants.PRIMARY_COLOR)
        }
        else {
            activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
        }
        
    }
    
    @IBAction func resetPasswordTapped(_ sender: UIButton) {
        
        // Send the password reset email
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            
            // If there is an error, print an appropriate error message
            guard error == nil else {
                self.handleErrors(error: error! as NSError)
                return
            }
            
            // The email was successful so the email should be sent
            self.presentErrorMessage(text: "Email sent to reset password", color: Constants.PRIMARY_COLOR)
            self.emailTextField.resignFirstResponder()
            
        }
        
    }
    
}

// MARK:- Methods relating to animation
extension ForgotPasswordViewController {
    
    func slideViewIn() {
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.forgotPasswordViewX.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func slideViewOut(completion: @escaping () -> Void) {
        
        errorView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.forgotPasswordViewX.constant = UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
        }) { (true) in
            completion()
        }
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Disables or Enables the button and sets the button background color
        resetPasswordButton.isEnabled = isActivated
        resetPasswordButton.backgroundColor = color
        
    }
    
}

// MARK:- Methods relating to error handling
extension ForgotPasswordViewController {
    
    func presentErrorMessage(text: String, color: UIColor) {
        
        // Set the text for the label, Set the alpha to 0 so it can fade back in
        errorLabel.text = text
        errorView.alpha = 0
        errorView.backgroundColor = color
        
        // Fade in the error bar
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.errorView.alpha = 1
        }, completion: nil)
        
    }
    
    func handleErrors(error: NSError) {
        
        // Retrieve the error code and then switch between possible errors
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
                
            case .invalidEmail:
                presentErrorMessage(text: Constants.INVALID_EMAIL, color: Constants.ERROR_COLOR)
                
            case .userNotFound:
                presentErrorMessage(text: Constants.EMAIL_NOT_REGISTERED, color: Constants.ERROR_COLOR)
                
            case .missingEmail:
                presentErrorMessage(text: Constants.EMAIL_MISSING, color: Constants.ERROR_COLOR)
                
            case .networkError:
                presentErrorMessage(text: Constants.NETWORK_ERROR, color: Constants.ERROR_COLOR)
                
            default:
                presentErrorMessage(text: "Unable to send email", color: Constants.ERROR_COLOR)
            }
        }
    }
    
}
