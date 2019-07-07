//
//  SettingsViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-07.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import  FirebaseAuth

class SettingsViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var userInfoStackViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var notificationsStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var notificationFrequencySegmentedControl: UISegmentedControl!
    @IBOutlet weak var notificationFrequencyPickerView: UIPickerView!
    
    @IBOutlet weak var supportStackViewHeight: NSLayoutConstraint!
    
    
    // MARK: - Properties
    let firebaseAuth = Auth.auth()
    
    var stackViewsExtended: [Bool] = Array.init(repeating: true, count: 3)
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        
        // Dismiss the view controller
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
    
        do {
            // Attempt to sign the user out
            try firebaseAuth.signOut()
            
            // Clear Local Storage
            LocalStorageService.clearCurrentUser()
            
            // Go back to the login screen
            let authVC = UIStoryboard(name: Constants.ID.Storyboard.auth, bundle: .main)
                         .instantiateViewController(withIdentifier: Constants.ID.VC.backgroundAuth) as? BackgroundViewController
            
            guard authVC != nil else { return }
            
            view.window?.rootViewController = authVC!
            view.window?.makeKeyAndVisible()
            
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
    }
    
}

// MARK: - Information Stack View Members
extension SettingsViewController {
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        
        // Invert the state of the stack view
        stackViewsExtended[0] = !stackViewsExtended[0]
        
        // Pull up the height
        UIView.animate(withDuration: 0.2) {
            
            if self.stackViewsExtended[0] == true {
                self.userInfoStackViewHeight.constant = 120
            }
            else if self.stackViewsExtended[0] == false {
                self.userInfoStackViewHeight.constant = 40
            }
            
            self.view.layoutIfNeeded()
            
        }
        
    }
    
}

// MARK: - Notification Stack View Members
extension SettingsViewController {
    
    @IBAction func notificationsButtonTapped(_ sender: UIButton) {
        
        // Invert the state of the stack view
        stackViewsExtended[1] = !stackViewsExtended[1]
        
        // Pull up the height
        UIView.animate(withDuration: 0.2) {
            
            if self.stackViewsExtended[1] == true {
                self.notificationsStackViewHeight.constant = 200
            }
            else if self.stackViewsExtended[1] == false {
                self.notificationsStackViewHeight.constant = 40
            }
            
            self.view.layoutIfNeeded()
            
        }
        
        
    }
    
}

// MARK: - Supprt Stack View Members
extension SettingsViewController {
    
    @IBAction func supportButtonTapped(_ sender: UIButton) {
        
        // Pull up the height
        UIView.animate(withDuration: 0.2) {
            
            self.supportStackViewHeight.constant = 40
            self.view.layoutIfNeeded()
            
        }
        
    }
    
    
}
