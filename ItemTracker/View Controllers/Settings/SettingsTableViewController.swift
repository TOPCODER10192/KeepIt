//
//  SettingsTableViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-11.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

struct SectionData {
    
    var isExpanded = true
    let header: String
    let texts: [String]
    let targets: [String]
    
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIButton!
    
    var sectionData = [SectionData(isExpanded: true, header: "Your Information", texts: ["Full Name", "Email", "Change Password"],
                                   targets: ["ChangeNameSegue", "ChangeEmailSegue", "ChangePasswordSegue"]),
                       SectionData(isExpanded: true, header: "Notifications", texts: ["Email Notifications", "Phone Notifications"],
                                   targets: ["EmailNotificationsSegue", "PhoneNotificationsSegue"]),
                       SectionData(isExpanded: true, header: "Support", texts: ["Write a Review", "Report a Problem"],
                                   targets: ["WriteReviewSegue", "ReportProblemSegue"])]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the closeButton
        closeButton.tintColor = Constants.Color.primary
        
        // Setup the signOutButton
        signOutButton.layer.cornerRadius = Constants.View.CornerRadius.bigButton
        signOutButton.backgroundColor    = Constants.Color.primary
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Return the number of sections
        return sectionData.count
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section
        if sectionData[section].isExpanded == true {
            return sectionData[section].texts.count
        }
        else {
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("SettingsBodyTableViewCell", owner: self, options: nil)?.first as! SettingsBodyTableViewCell
        
        cell.promptLabel.text = sectionData[indexPath.section].texts[indexPath.row]
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerButton = UIButton()
        
        // Set the header buttons text
        headerButton.setTitle(sectionData[section].header, for: .normal)
        headerButton.setTitleColor(UIColor.white, for: .normal)
        headerButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // Setup a border for the header
        headerButton.layer.borderWidth = 0.3
        headerButton.layer.borderColor = UIColor.white.cgColor
        
        // Set the header buttons color
        headerButton.backgroundColor = Constants.Color.primary
        
        // Add a target for the button
        headerButton.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
        headerButton.tag = section
        
        return headerButton
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 40
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: sectionData[indexPath.section].targets[indexPath.row], sender: self)
        
    }

    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIButton) {
        
        let areYouSureAlert = UIAlertController(title: "Sign out?", message: nil, preferredStyle: .alert)
        
        areYouSureAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        areYouSureAlert.addAction(UIAlertAction(title: "Sign Out", style: .default, handler: { (action) in
            
            // Sign the user out
            self.signOutUser()
            
        }))
        
        // Present the are you sure alert controller
        present(areYouSureAlert, animated: true)
        
    }
    
    func signOutUser() {
        
        let firebaseAuth = Auth.auth()
        
        do {
            
            // Attempt to sign the user out
            try firebaseAuth.signOut()
            
            // Clear local storage
            LocalStorageService.deleteAllInfo()
            
            // Create the authVC
            let authVC = UIStoryboard(name: Constants.ID.Storyboard.auth, bundle: .main)
                .instantiateViewController(withIdentifier: Constants.ID.VC.backgroundAuth) as! BackgroundViewController
            
            // Present the Auth VC
            self.view.window?.rootViewController = authVC
            self.view.window?.makeKeyAndVisible()
            
            
        } catch let signOutError as NSError {
            
            print ("Error signing out: %@", signOutError)
            
        }
        
    }
    
}

extension SettingsTableViewController {
    
    @objc func headerTapped(button: UIButton) {
        
        let section = button.tag
        
        // Invert the state of the sections expansion
        sectionData[section].isExpanded = !sectionData[section].isExpanded
        
        var indexPaths = [IndexPath]()
        
        for row in 0 ..< sectionData[section].texts.count {
            
            indexPaths.append(IndexPath(row: row, section: section))
            
        }
        
        if sectionData[section].isExpanded == false {
            
            // Remove all the rows in the section
            tableView.deleteRows(at: indexPaths, with: .fade)
            
        }
        else {
            
            // Add the rows back into the section
            tableView.insertRows(at: indexPaths, with: .fade)
            
        }
        
    }
    
}
