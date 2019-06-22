//
//  LoginViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-27.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import Firebase

protocol LoginProtocol {
    func goToCreateAccount()
    func goToForgotPassword()
}

class LoginViewController: UIViewController {
    
    // MARK:- IBOutlet Properties
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
    
    // MARK:- LoginViewController Properties
    var delegate: LoginProtocol?
    var firstTimeSeeingView: Bool?
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the loginView
        loginView.backgroundColor    = Constants.FLOATING_VIEW_COLOR
        loginView.layer.cornerRadius = Constants.GENERAL_CORNER_RADIUS
        loginViewWidth.constant      = Constants.LOGIN_VIEW_WIDTH
        loginViewHeight.constant     = Constants.LOGIN_VIEW_HEIGHT
        loginViewX.constant          = -UIScreen.main.bounds.width
        
        if firstTimeSeeingView == true {
            loginViewX.constant *= -1
        }
        
        // Setup the emailTextField
        emailTextField.delegate = self
        
        // Setup the passwordTextField
        passwordTextField.delegate = self
        
        // Setup the forgotpasswordButton
        forgotPasswordButton.setTitleColor(Constants.PRIMARY_COLOR, for: .normal)
        
        // Setup the loginButton
        loginButton.layer.cornerRadius = Constants.BUTTON_CORNER_RADIUS
        loginButton.backgroundColor    = Constants.PRIMARY_COLOR
        activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
        
        // Setup the createAccountButton
        createAccountButton.setTitleColor(Constants.PRIMARY_COLOR, for: .normal)
        
        // Setup the error view
        errorView.alpha              = 0
        errorView.layer.cornerRadius = Constants.GENERAL_CORNER_RADIUS
        errorView.backgroundColor    = Constants.ERROR_COLOR
        errorViewY.constant          = Constants.ERROR_VIEW_Y
        
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
}

// MARK:- IBAction Methods
extension LoginViewController {
   
    @IBAction func emailIsEditing(_ sender: UITextField) {
        
        // Check to see if the loginButton should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func passwordIsEditing(_ sender: UITextField) {
        
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
        
        // Grab the email and password from the text fields
        let email = emailTextField.text?.trimmingCharacters(in: .whitespaces)
        let password = passwordTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check that the email
        guard email != nil && email!.count > 0 && password != nil && password!.count > 0 else {
            presentErrorMessage(text: "Text fields are empty")
            return
        }
        
        // Attempt to login the user
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] user, error in
            guard let self = self else { return }
            
            // Check to see if any errors occured
            guard error == nil && user != nil else {
                self.handleErrors(error: error! as NSError)
                return
            }
            
            // Collect all the users information
            self.collectUserInformation(closure: {
                
                // Segue to the inapp storyboard
                self.performSegue(withIdentifier: Constants.LOGGED_IN_SEGUE_ID, sender: true)
                
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
    
    func collectUserInformation(closure: @escaping () -> Void) {
        
        let userDocRef = db.collection(Constants.USERS_KEY).document(emailTextField.text!)
        userDocRef.getDocument { (userDocument, error) in
            
            // Check that the document isnt nil
            guard userDocument != nil && error == nil else { return }
            
            // Get the data and check that it isn't nil
            let userData = userDocument?.data()
            guard userData != nil else { return }
            
            // Pull the data
            let firstName = userData![Constants.FIRST_NAME_KEY]! as? String
            let lastName  = userData![Constants.LAST_NAME_KEY]! as? String
            let email     = self.emailTextField.text!
            let userID    = userData![Constants.USER_ID_KEY] as? String
            
            // Store the data
            Shared.userProfile = UserInfo(firstName: firstName, lastName: lastName, email: email, userID: userID)
            
            closure()
            
        }
        
    }
    
}
    
// MARK:- Animation Methods
extension LoginViewController {

    func slideViewIn() {
        
        // Slide the view in from the left
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
            completion()
        }
    }
    
    
    func checkToActivateButton() {
        
        // Check that both text fields are not nil and that they have at least one character
        guard emailTextField.text != nil && passwordTextField != nil && emailTextField.text!.trimmingCharacters(in: .whitespaces).count != 0 && passwordTextField.text!.trimmingCharacters(in: .whitespaces).count != 0 else {
            
            activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
            return
            
        }
        
        // Otherwise, activate the button
        activateButton(isActivated: true, color: Constants.PRIMARY_COLOR)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Disables or Enables the button and sets the button background color
        loginButton.isEnabled = isActivated
        loginButton.backgroundColor = color
        
    }
    
}

// MARK:- Error handling methods
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
                presentErrorMessage(text: Constants.WRONG_PASSWORD)
                
            case .invalidEmail:
                presentErrorMessage(text: Constants.INVALID_EMAIL)
                
            case .userNotFound:
                presentErrorMessage(text: Constants.EMAIL_NOT_REGISTERED)
                
            case .missingEmail:
                presentErrorMessage(text: Constants.EMAIL_MISSING)
                
            case .networkError:
                presentErrorMessage(text: Constants.NETWORK_ERROR)
                
            case .userDisabled:
                presentErrorMessage(text: Constants.ACCOUNT_DISABLED)
            default:
                presentErrorMessage(text: "Unable to sign in")
            }
        }
    }
}

// MARK:- Functions that conform to the UITextFieldDelegate
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
