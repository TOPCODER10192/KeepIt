//
//  BackgroundViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class BackgroundViewController: UIViewController {
    
    // MARK:- BackgroundViewController Properties
    var justLaunched = true

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Present the LoginVC
        presentVC(id: Constants.LOGIN_VCID, extraInfo: nil)
        
    }
    
    func presentVC(id: String, extraInfo: String?) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: id)
        
        // Determine which type of ViewController the storybard is
        if let vc = vc as? LoginViewController {
            // Set the delegate for the LoginVC
            vc.delegate = self
            
            if justLaunched == true {
                vc.firstTimeSeeingView = true
                justLaunched = false
            }
        }
        else if let vc = vc as? CreateAccountViewController {
            vc.delegate = self
        }
        else if let vc = vc as? ForgotPasswordViewController {
            vc.delegate = self
        }
        
        // Set the presentation style for the VC
        vc?.modalPresentationStyle = .overCurrentContext
        
        // Present the VC
        present(vc!, animated: false, completion: nil)
        
    }

}

// MARK:- Methods that conform to the LoginProtocol
extension BackgroundViewController: LoginProtocol {
    
    func goToCreateAccount() {
        
        // Present the CreateAccountVC
        presentVC(id: Constants.CREATE_ACCOUNT_VCID, extraInfo: nil)
        
    }
    
    func goToForgotPassword() {
        
        // Present the ForgotPasswordVC
        presentVC(id: Constants.FORGOT_PASSWORD_VCID, extraInfo: nil)
        
    }
    
}

// MARK:- Methods that conform to the CreateAccountProtocol and ForgotPasswordProtocol
extension BackgroundViewController: CreateAccountProtocol, ForgotPasswordProtocol {
    
    func goBackToLogin() {
        
        // Present the LoginVC
        presentVC(id: Constants.LOGIN_VCID, extraInfo: nil)
        
    }
    
}
