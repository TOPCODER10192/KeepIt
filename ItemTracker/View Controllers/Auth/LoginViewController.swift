//
//  LoginViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-27.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

// MARK: - Login Protocol
protocol LoginProtocol {
    
    func goToCreateAccount()
    func goToForgotPassword()
    
}

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginViewX: NSLayoutConstraint!
    @IBOutlet weak var loginViewWidth: NSLayoutConstraint!
    @IBOutlet weak var loginViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorViewY: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    
    // MARK: - LoginViewController Properties
    var delegate: LoginProtocol?
    var firstTimeSeeingView: Bool?
    
    var email: String?
    var password: String?

    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the loginView
        loginView.backgroundColor    = Constants.Color.floatingView
        loginView.layer.cornerRadius = Constants.View.CornerRadius.standard
        loginViewWidth.constant      = Constants.View.Width.standard
        loginViewHeight.constant     = Constants.View.Height.login
        loginViewX.constant          = -UIScreen.main.bounds.width
        
        // If first time seeing the view then slide in from the right
        if firstTimeSeeingView == true {
            loginViewX.constant *= -1
        }
        
        // Setup the emailTextField
        emailTextField.delegate = self
        
        // Setup the passwordTextField
        passwordTextField.delegate = self
        
        // Setup the forgotpasswordButton
        forgotPasswordButton.setTitleColor(Constants.Color.primary, for: .normal)
        
        // Setup the loginButton
        loginButton.layer.cornerRadius = Constants.View.CornerRadius.button
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
        // Setup the createAccountButton
        createAccountButton.setTitleColor(Constants.Color.primary, for: .normal)
        
        // Setup the error view
        errorView.alpha              = 0
        errorView.layer.cornerRadius = Constants.View.CornerRadius.standard
        errorView.backgroundColor    = Constants.Color.error
        errorViewY.constant          = Constants.View.Y.error
        
        // Create a listener for the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Slide the view into the screen
        slideViewIn()
        
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
    
    // MARK: - IBAction Methods
    @IBAction func emailIsEditing(_ sender: UITextField) {
        
        // Store the email thats in the text field
        email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the loginButton should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func passwordIsEditing(_ sender: UITextField) {
        
        // Store the password thats in the text field
        password = passwordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the loginButton should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        
        // Go to the forgotPasswordViewController
        slideViewOut {
            self.dismiss(animated: false, completion: {
                self.delegate?.goToForgotPassword()
            })
        }

    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        // Disable the button
        loginButton.isEnabled = false
        
        // Attempt to login the user
        Auth.auth().signIn(withEmail: email!, password: password!) { [weak self] user, error in
            guard let self = self else { return }
            
            // Check to see if any errors occured
            guard user != nil && error == nil else {
                self.loginButton.isEnabled = true
                self.handleErrors(error: error! as NSError)
                return
            }
            
            // Collect all the users information
            UserService.readUserProfile(email: self.email!, completion: {
                self.performSegue(withIdentifier: Constants.ID.Segue.loggedIn, sender: sender)
            })
            
        }
        
    }
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        
        // Slide the view off the screen
        slideViewOut {
            self.dismiss(animated: false, completion: {
                self.delegate?.goToCreateAccount()
            })
        }
        
    }
    
}

// MARK: - Helper Methods
extension LoginViewController {
    
    func checkToActivateButton() {
        
        // Check that both text fields are not nil and that they have at least one character
        guard email != nil && password != nil && email!.count > 0 && password!.count > 0 else {
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Disables or Enables the button and sets the button background color
        loginButton.isEnabled = isActivated
        loginButton.backgroundColor = color
        
    }
    
}
    
// MARK: - Animation Methods
extension LoginViewController {

    func slideViewIn() {
        
        // Slide the view in to the center
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.loginViewX.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideViewOut(completion: @escaping () -> Void) {
        
        // Make the errorView invisible
        errorView.alpha = 0
        
        // Animate the view off screen to the left
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            self.loginViewX.constant = -UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
            
        }) { (true) in
            
            // Execute the completion handler
            completion()
            
        }
    }
    
}

// MARK: - Error handling methods
extension LoginViewController {
    
    func presentErrorMessage(text: String) {
        
        // Set the text for the label, Set the alpha to 0 so it can fade back in
        errorLabel.text = text
        errorView.alpha = 0
        
        // Fade in the error bar
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            
            self.errorView.alpha = 1
            
        }, completion: nil)
        
    }
    
    func handleErrors(error: NSError) {
        
        // Retrieve the error code and then switch between possible errors
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
                
            case .wrongPassword:
                presentErrorMessage(text: Constants.ErrorMessage.wrongPassword)
                
            case .invalidEmail:
                presentErrorMessage(text: Constants.ErrorMessage.invalidEmail)
                
            case .userNotFound:
                presentErrorMessage(text: Constants.ErrorMessage.emailNotRegistered)
                
            case .missingEmail:
                presentErrorMessage(text: Constants.ErrorMessage.emailMissing)
                
            case .networkError:
                presentErrorMessage(text: Constants.ErrorMessage.networkError)
                
            case .userDisabled:
                presentErrorMessage(text: Constants.ErrorMessage.accountDisabled)
            default:
                presentErrorMessage(text: "Unable to sign in")
            }
        }
        
    }
    
}

// MARK: - Functions that conform to the UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Move to the next text field, or lower the keyboard if at the end
        if textField == emailTextField {
            emailTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        }
        else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
        }
        
        return true
        
    }
    
}
