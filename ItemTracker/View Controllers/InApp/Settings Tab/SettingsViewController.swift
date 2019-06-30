//
//  SettingsViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

final class SettingsViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        
        // Attempt to sign the user out
        do {
            try firebaseAuth.signOut()
        }
        catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        // Clear the local storage
        LocalStorageService.clearCurrentUser()
        
        let authVC = UIStoryboard(name: "Auth", bundle: .main).instantiateViewController(withIdentifier: Constants.ID.VC.backgroundAuth) as! BackgroundViewController
        
        view.window?.rootViewController = authVC
        view.window?.makeKeyAndVisible()
        
        
    }
    
    
}
