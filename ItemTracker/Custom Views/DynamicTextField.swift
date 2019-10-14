//
//  DynamicTextField.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-09-11.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class DynamicTextField: UIView {

    // MARK: IBOutlet Properties
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var shiftingLabel: UILabel!
    @IBOutlet weak var underlineView: UIView!
    
    // Initialization Methods
    func initializeTextField(keyboardType: UIKeyboardType, secureText: Bool, borderStyle: UITextField.BorderStyle) {
        
        // Set the delegate
        textField.delegate = self
        
        // Apply the parameters
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = secureText
        textField.borderStyle = borderStyle
        
    }
    
    func initializeLabel(text: String) {
        
        // Set the text
        shiftingLabel.text = text
        
    }
    
}

extension DynamicTextField: UITextFieldDelegate {
    
    @IBAction func textFieldChangedEditing(_ sender: UITextField) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Highlight the underline
        self.underlineView.backgroundColor = Constants.Color.primary
        
        // Raise, shrink, recolor the Email Placeholder Text
        UIView.animate(withDuration: 0.2) {
            
            self.shiftingLabel.textColor = Constants.Color.primary
            self.shiftingLabel.font = UIFont(name: "SFProText-Bold", size: 16)
            self.shiftingLabel.transform = CGAffineTransform(translationX: 0, y: -25)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Resign first responder
        self.resignFirstResponder()
        return true
        
    }
    
}
