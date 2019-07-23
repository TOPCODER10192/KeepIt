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
    func goToInApp()
    
}

final class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewToCenterX: NSLayoutConstraint!
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var emailTextField: CustomTextField!
    @IBOutlet weak var passwordTextField: CustomTextField!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    
    // MARK: - Properties
    var delegate: LoginProtocol?
    var firstTimeSeeingView: Bool?
    
    var email: String?
    var password: String?

    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the loginView
        floatingView.backgroundColor    = UIColor.clear
        floatingViewWidth.constant      = Constants.View.Width.standard
        floatingViewHeight.constant     = Constants.View.Height.login
        floatingViewToCenterX.constant          = -UIScreen.main.bounds.width
        floatingViewToBottom.constant = UIScreen.main.bounds.height * 0.3
        
        // If first time seeing the view then slide in from the right
        if firstTimeSeeingView == true {
            floatingViewToCenterX.constant *= -1
        }
        
        // Setup the emailTextField
        emailTextField.delegate = self
        emailTextField.addBottomLine(color: UIColor.white, width: 0.5)
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email Address",
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        // Setup the passwordTextField
        passwordTextField.delegate = self
        passwordTextField.addBottomLine(color: UIColor.white, width: 0.5)
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password",
                                                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        // Setup the forgotpasswordButton
        forgotPasswordButton.setTitleColor(UIColor.white, for: .normal)
        
        // Setup the loginButton
        loginButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
        // Setup the createAccountButton
        createAccountButton.setTitleColor(UIColor.white, for: .normal)
        
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
                self.floatingViewToBottom.constant = keyboardHeight + 15
                self.view.layoutIfNeeded()
                
            }, completion: nil)
        }
    }
    
}

// MARK: - Text Field Methods
extension LoginViewController: UITextFieldDelegate {
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Deselect the responding text field
        textField.resignFirstResponder()
        
        // Move to the next text field, or lower the keyboard if at the end
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        
        return true
        
    }
    
}

// MARK: - Button Methods
extension LoginViewController {
    
    @IBAction func createAccountTapped(_ sender: UIButton) {
        
        // Slide the view out
        slideViewOut {
            
            // Dismiss Login VC
            self.dismiss(animated: false, completion: {
                
                // Tell the delegate to go to create account
                self.delegate?.goToCreateAccount()
                
            })
            
        }
        
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Disable the button
        loginButton.isEnabled = false
        
        // Start the progress animation
        ProgressService.progressAnimation(text: "Trying to Log You In")
        
        // Attempt to login the user
        Auth.auth().signIn(withEmail: email!, password: password!) { [weak self] authResult, error in
            guard let self = self else { return }
            
            // Check to see if any errors occured
            guard authResult != nil, error == nil else {
                self.loginButton.isEnabled = true
                ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                return
            }
            
            // Attempt to get the user from the database
            FirestoreService.getUser(userID: Auth.auth().currentUser!.uid, completion: { (error, user) in
                
                // Check to see if information was successfully read
                guard error == nil, user != nil else {
                    self.loginButton.isEnabled = true
                    ProgressService.errorAnimation(text: "Unable to Get Your Information")
                    return
                }
                
                // Store the user locally
                LocalStorageService.writeUser(user: user!)
                Stored.user = user
                
                // Attempt to get the users items form the database
                FirestoreService.listItems(completion: { (error, items) in
                    
                    // Check to see if items were succesfully read
                    guard error == nil, items != nil else {
                        self.loginButton.isEnabled = true
                        ProgressService.errorAnimation(text: "Unable to Get Your Information")
                        return
                    }
                    
                    // Present a success message
                    ProgressService.successAnimation(text: "Successfully Logged In")
                    
                    // Store all the users items locally
                    for item in items! {
                        LocalStorageService.createItem(item: item)
                    }
                    Stored.userItems = items!
                    
                    // Go into the app
                    self.dismiss(animated: true, completion: {
                        self.delegate?.goToInApp()
                    })
                    
                })
                
            })
            
        }
        
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        
        // Slide the View Out
        slideViewOut {
            
            // Dismiss the Login VC
            self.dismiss(animated: false, completion: {
                
                // Tell the delegate to go to the Forgot Password VC
                self.delegate?.goToForgotPassword()
                
            })
        }
        
    }
    
}

// MARK: - Helper Methods
extension LoginViewController {
    
    func checkToActivateButton() {
        
        // Check that both text fields are not nil and that they have at least one character
        guard email != nil && password != nil && email!.count > 0 && password!.count > 0 else {
            loginButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        loginButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
}

// MARK: - Animation Methods
extension LoginViewController {
    
    func slideViewIn() {
        
        // Slide the view in to the center
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.floatingViewToCenterX.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideViewOut(completion: @escaping () -> Void) {
        
        // Animate the view off screen to the left
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            self.floatingViewToCenterX.constant = -UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
            
        }) { (true) in
            
            // Execute the completion handler
            completion()
            
        }
    }
    
    func lowerKeyboard() {
        
        // Resign first responder from either text field
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
    }
    
}
