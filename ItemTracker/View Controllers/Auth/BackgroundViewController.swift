//
//  BackgroundViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

final class BackgroundViewController: UIViewController {
    
    // MARK: - BackgroundViewController Properties
    var justLaunched = true
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Present the LoginVC
        presentVC(id: Constants.ID.VC.login, extraInfo: nil)
        
    }

}

// MARK: - Helper methods
extension BackgroundViewController {
    
    func presentVC(id: String, extraInfo: String?) {
        
        // Create an generalized VC
        let vc = storyboard?.instantiateViewController(withIdentifier: id)
        
        // Determine which type of VC the storybard is
        if let vc = vc as? LoginViewController {
            // Set the delegate for the LoginVC
            vc.delegate = self
            
            // If the app just launched then tell this to the LoginVC
            if justLaunched == true {
                vc.firstTimeSeeingView = true
                justLaunched = false
            }
        }
        else if let vc = vc as? CreateAccountViewController {
            // Set the delegate for the CreateAccountVC
            vc.delegate = self
        }
        else if let vc = vc as? ForgotPasswordViewController {
            // Set the delegate for the ForgotPasswordVC
            vc.delegate = self
        }
        
        // Set the presentation style for the VC and present the VC
        vc?.modalPresentationStyle = .overCurrentContext
        present(vc!, animated: false, completion: nil)
        
    }
    
}

// MARK:- Methods that conform to the LoginProtocol
extension BackgroundViewController: LoginProtocol, CreateAccountProtocol, ForgotPasswordProtocol {
    
    func goToInApp() {
        
        let tabBarVC = UIStoryboard(name: Constants.ID.Storyboard.tabBar, bundle: .main)
                                    .instantiateViewController(withIdentifier: Constants.ID.VC.tabBar)
        
        view.window?.rootViewController = tabBarVC
        view.window?.makeKeyAndVisible()
        
    }
    
    
    func goToCreateAccount() {
        
        // Present the CreateAccountVC
        presentVC(id: Constants.ID.VC.createAccount, extraInfo: nil)
        
    }
    
    func goToForgotPassword() {
        
        // Present the ForgotPasswordVC
        presentVC(id: Constants.ID.VC.forgotPassword, extraInfo: nil)
        
    }
    
    func goBackToLogin() {
        
        // Present the LoginVC
        presentVC(id: Constants.ID.VC.login, extraInfo: nil)
        
    }
    
}
