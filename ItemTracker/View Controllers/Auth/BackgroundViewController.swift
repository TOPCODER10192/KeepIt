//
//  BackgroundViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-05-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

final class BackgroundViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var tintView: UIView!
    
    // MARK: - Properties
    var justLaunched = true
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the tintColor
        tintView.backgroundColor = Constants.Color.softPrimary
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Present the LoginVC
        presentVC(id: Constants.ID.VC.login, animate: false)
        
    }

}

// MARK: - Helper methods
extension BackgroundViewController {
    
    func presentVC(id: String, animate: Bool) {
        
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
        
        // Check that the vc isn't nil
        guard vc != nil else { return }
        
        // Present the vc
        present(vc!, animated: animate, completion: nil)
        
    }
    
}

// MARK: - Custom Protocol Methods
extension BackgroundViewController: LoginProtocol, CreateAccountProtocol, ForgotPasswordProtocol {
    
    func goToInApp() {
        
        // Create a tab bar controller
        let tabBarVC = UIStoryboard(name: Constants.ID.Storyboard.tabBar, bundle: .main)
                                    .instantiateViewController(withIdentifier: Constants.ID.VC.tabBar) as! UITabBarController
        
        // Setup the tab bar controller
        tabBarVC.tabBar.tintColor = Constants.Color.primary
        
        // Present the tab bar controller
        view.window?.rootViewController = tabBarVC
        view.window?.makeKeyAndVisible()
        
    }
    
    
    func goToCreateAccount() {
        
        // Present the CreateAccountVC
        presentVC(id: Constants.ID.VC.createAccount, animate: false)
        
    }
    
    func goToForgotPassword() {
        
        // Present the ForgotPasswordVC
        presentVC(id: Constants.ID.VC.forgotPassword, animate: false)
        
    }
    
    func goBackToLogin() {
        
        // Present the LoginVC
        presentVC(id: Constants.ID.VC.login, animate: false)
        
    }
    
    func goToWelcome() {
        
        // Present the WelcomeVC
        presentVC(id: Constants.ID.VC.welcome, animate: true)
        
    }
    
}
