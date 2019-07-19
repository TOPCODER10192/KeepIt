//
//  CreateAccountViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-27.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

// MARK: - Create Account Protocol
protocol CreateAccountProtocol {
    
    func goBackToLogin()
    func goToWelcome()
    
}

final class CreateAccountViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewX: NSLayoutConstraint!
    @IBOutlet weak var floatingViewToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var bottomButton: UIButton!
    
    // MARK: - CreateAccountViewController Properties
    var formIndex: Int = 0
    var delegate: CreateAccountProtocol?
    
    var firstName: String?
    var lastName: String?
    var email: String?
    var password: String?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the createAccountView
        floatingView.backgroundColor    = Constants.Color.floatingView
        floatingView.layer.cornerRadius = Constants.View.CornerRadius.standard
        floatingViewWidth.constant      = Constants.View.Width.standard
        floatingViewHeight.constant     = Constants.View.Height.createAccount
        floatingViewX.constant          = UIScreen.main.bounds.width
        floatingViewToBottom.constant        = UIScreen.main.bounds.height * 0.3
        
        // Setup the navigationBar
        backButton.tintColor             = Constants.Color.primary
        navigationBar.layer.cornerRadius = Constants.View.CornerRadius.standard
        navigationBar.clipsToBounds      = true
        navigationBarTitle.title         = "Step 1 of 2"
        
        // Setup the prompt label
        promptLabel.text = "What is your name?"
        
        // Setup the topTextField
        topTextField.placeholder = "First Name"
        topTextField.delegate    = self
        
        // Setup the bottomTextField
        bottomTextField.placeholder = "Last Name"
        bottomTextField.delegate    = self
        
        // Setup the button
        bottomButton.layer.cornerRadius = Constants.View.CornerRadius.bigButton
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
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

// MARK: - Back Button Methods
extension CreateAccountViewController {
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Disable the button
        bottomButton.isEnabled = false
        
        formIndex -= 1
        
        // Slide the view out of the screen
        slideViewOut(finalX: UIScreen.main.bounds.width) { () -> Void in
            
            if self.formIndex < 0 {
                // Dismiss the current view controller
                self.dismiss(animated: false) {
                    self.delegate?.goBackToLogin()
                }
            }
            else if self.formIndex == 0 {
                // Otherwise, go to the first page of the create account
                self.reloadForm()
            }
            
        }
        
    }
    
}

// MARK: - Bottom Button Methods
extension CreateAccountViewController {
    
    @IBAction func bottomButtonTapped(_ sender: UIButton) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Disable the button
        bottomButton.isEnabled = false
        
        if formIndex == 0 {
            
            // Go to the next form
            formIndex += 1
            reloadForm()
            
        }
        else if formIndex == 1 {
            
            // Start a progress animation
            ProgressService.progressAnimation(text: "Trying to Create Your Account")
            
            // Attempt to create an account
            Auth.auth().createUser(withEmail: email!, password: password!) { authResult, error in
                
                // Check if the account was created successfully
                guard error == nil else {
                    self.bottomButton.isEnabled = true
                    ProgressService.errorAnimation(text: ErrorService.firebaseAuthError(error: error!))
                    return
                }
                
                // Get the users id
                let userID = Auth.auth().currentUser?.uid
                
                // Collect the users information
                let user = UserInfo(id: userID!, firstName: self.firstName!, lastName: self.lastName!, email: self.email!)
                
                // Store the users information in the database and store it locally
                FirestoreService.writeUser(user: user, completion: { (error) in
                    
                    // Check to see if there is an error
                    guard error == nil else {
                        
                        self.bottomButton.isEnabled = true
                        ProgressService.errorAnimation(text: "Unable to Create Your Account")
                        return
                        
                    }
                    
                    ProgressService.successAnimation(text: "Successfully Created Your Account")
                    
                    // Store the users information locally
                    LocalStorageService.writeUser(user: user)
                    Stored.user = user
                    
                    // Go into the main app
                    self.dismiss(animated: true, completion: {
                        
                        self.delegate?.goToWelcome()
                        
                    })
                    
                })
                
            }
            
        }
        
    }
    
}

// MARK: - Text Field Methods
extension CreateAccountViewController: UITextFieldDelegate {
    
    @IBAction func topTextFieldEditing(_ sender: UITextField) {
        
        // Retrieve the contents of the top text field and store it
        if formIndex == 0 {
            // First form, so store in firstName
            firstName = topTextField.text?.trimmingCharacters(in: .whitespaces)
        }
        else if formIndex == 1 {
            // Second form, so store in email
            email = topTextField.text?.trimmingCharacters(in: .whitespaces)
        }
        
        // Check if the bottom button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func bottomTextFieldEditing(_ sender: UITextField) {
        
        // Retrieve the contents of the bottom text field and store it
        if formIndex == 0 {
            // First form, so store in lastName
            lastName = bottomTextField.text?.trimmingCharacters(in: .whitespaces)
        }
        else if formIndex == 1 {
            // Second form, so store in password
            password = bottomTextField.text?.trimmingCharacters(in: .whitespaces)
        }
        
        // Check if the bottom button should be activated
        checkToActivateButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // If on the top text field, go to the second one
        if textField == topTextField {
            topTextField.resignFirstResponder()
            bottomTextField.becomeFirstResponder()
        }
        // If on the bottom text field, lower the keyboard
        else if textField == bottomTextField {
            bottomTextField.resignFirstResponder()
        }
        
        return true
        
    }
}

// MARK: - Animation Methods
extension CreateAccountViewController {
    
    func slideViewIn() {
        
        // Slide the view in from the right
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            // Adjust the x value of the view
            self.floatingViewX.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    
    func slideViewOut(finalX: CGFloat, completion: @escaping () -> Void) {
        
        // Slide the view out to the right
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            
            self.floatingViewX.constant = finalX
            self.view.layoutIfNeeded()
            
        }) { (true) in
            
            completion()
            
        }
        
    }
    
    func lowerKeyboard() {
        
        // Resign first responder from either keyboard
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        
    }
    
}

// MARK: - Helper Methods
extension CreateAccountViewController {
    
    func checkToActivateButton() {
        
        // Check that both text fields are not nil and that they have at least one character
        guard topTextField.text != nil && bottomTextField != nil && topTextField.text!.trimmingCharacters(in: .whitespaces).count != 0 && bottomTextField.text!.trimmingCharacters(in: .whitespaces).count != 0 else {
            
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
            
        }
        
        // Otherwise, activate the button
        activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Disables or Enables the button and sets the button background color
        bottomButton.isEnabled = isActivated
        bottomButton.backgroundColor = color
        
    }
    
    func reloadForm() {
        
        // Disable the text fields
        topTextField.isEnabled = false
        bottomTextField.isEnabled = false
        
        // Slide the form out
        if formIndex == 0 {
            slideViewOut(finalX: UIScreen.main.bounds.width) {
                
                // Load the first form
                self.loadFirstForm()
                
            }
        }
        else if formIndex == 1 {
            slideViewOut(finalX: -UIScreen.main.bounds.width) {
                
                // Load the second form
                self.loadSecondForm()
                
            }
        }
        
    }
    
    func loadFirstForm() {
        
        // Set the text fields text to nil
        self.topTextField.text = nil
        self.bottomTextField.text = nil
        
        // Reset the view labels and placeholder texts
        self.navigationBarTitle.title = "Step 1 of 2"
        self.promptLabel.text = "What is your name?"
        self.topTextField.placeholder = "First Name"
        self.bottomTextField.placeholder = "Last Name"
        self.bottomButton.setTitle("Next", for: .normal)
        self.bottomButton.setTitle("Next", for: .disabled)
        
        // Adjust the text fields
        self.topTextField.textContentType = .givenName
        self.topTextField.keyboardType = .default
        self.bottomTextField.textContentType = .familyName
        self.bottomTextField.isSecureTextEntry = false
        self.bottomTextField.passwordRules = nil
        
        self.floatingViewX.constant = -UIScreen.main.bounds.width
        self.view.layoutIfNeeded()
        self.slideViewIn()
        
        // Enable the text fields
        self.topTextField.isEnabled = true
        self.bottomTextField.isEnabled = true
        
    }
    
    func loadSecondForm() {
        
        // Set the text fields text to nil
        self.topTextField.text = nil
        self.bottomTextField.text = nil
        
        // Reset the view labels and placeholder
        navigationBarTitle.title = "Step 2 of 2"
        promptLabel.text = "Email and Password"
        topTextField.placeholder = "Email Address"
        bottomTextField.placeholder = "Password (At least 6 characters)"
        self.bottomButton.setTitle("Create Account", for: .normal)
        self.bottomButton.setTitle("Create Account", for: .disabled)
        
        // Adjust the text fields
        topTextField.textContentType = .emailAddress
        topTextField.keyboardType = .emailAddress
        bottomTextField.textContentType = .password
        bottomTextField.isSecureTextEntry = true
        bottomTextField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: digit; minlength: 8;")
        
        // Move the view to the opposite side so it can slide back in
        floatingViewX.constant = UIScreen.main.bounds.width
        view.layoutIfNeeded()
        slideViewIn()
        
        // Enable the text fields
        topTextField.isEnabled = true
        bottomTextField.isEnabled = true
        
    }
    
}
