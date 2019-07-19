//
//  SettingsTableViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-11.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct SectionData {
    
    var isExpanded = true
    let header: String
    var texts: [String]
    let targets: [String]
    
}

class SettingsTableViewController: UITableViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    // MARK: - Properties
    var sectionData = [SectionData(isExpanded: true, header: "Your Information",
                                   texts: ["Full Name: \(Stored.user!.firstName) \(Stored.user!.lastName)",
                                           "Email: \(Stored.user!.email)", "Change Password", "Quick Locations"],
                                   targets: ["ChangeNameSegue", "ChangeEmailSegue", "ChangePasswordSegue", "QuickLocationsSegue"]),
                       SectionData(isExpanded: true, header: "Notifications", texts: ["Email Notifications", "Phone Notifications"],
                                   targets: ["EmailNotificationsSegue", "PhoneNotificationsSegue"]),
                       SectionData(isExpanded: true, header: "Premium", texts: ["Info about premium", "Upgrade to premium"],
                                   targets: ["PremiumInfoSegue", "PayPremiumSegue"]),
                       SectionData(isExpanded: true, header: "Support", texts: ["FAQ", "Write a Review", "Report a Problem"],
                                   targets: ["FAQSegue", "WriteReviewSegue", "ReportProblemSegue"])]
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the closeButton
        closeButton.tintColor = Constants.Color.primary
        
        // Setup the signOutButton
        signOutButton.tintColor   = Constants.Color.primary
        
        // Setup the delete account button
        deleteAccountButton.tintColor = Constants.Color.deleteButton
        
    }

}

// MARK: - Table View Methods
extension SettingsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Return the number of sections
        return sectionData.count
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of rows in the section
        if sectionData[section].isExpanded == true {
            return sectionData[section].texts.count
        }
        // If the section is collapsed then return 0
        else {
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Let the cell be a settings bodyCell
        let cell = Bundle.main.loadNibNamed(Constants.ID.Nib.settingsBody, owner: self, options: nil)?.first as! SettingsBodyTableViewCell
        
        // Set the label to match the section and row in the sectionData
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
        
        // Let the row height be 40
        return 40
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        // Let the header height be 40
        return 40
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the rows target view controller
        performSegue(withIdentifier: sectionData[indexPath.section].targets[indexPath.row], sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Let the destinationVC be the destination of the segue
        let destinationVC = segue.destination
        
        // Attempt to type cast it as a ChangeNameVC
        if let destinationVC = destinationVC as? ChangeNameViewController {
            destinationVC.delegate = self
        }
        // Attempt to type cast it as a ChangeEmailVC
        else if let destinationVC = destinationVC as? ChangeEmailViewController {
            destinationVC.delegate = self
        }
        
    }
    
}

// MARK: - Navigation Bar Button Methods
extension SettingsTableViewController {
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        
        // Dismiss the settings vc
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func signOutButtonTapped(_ sender: UIBarButtonItem) {
        
        // Create an alert asking the user if they are sure
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
        
        // Attempt to sign out the user
        let firebaseAuth = Auth.auth()
        
        do {
            
            // Attempt to sign the user out
            try firebaseAuth.signOut()
            
            // Clear local storage
            LocalStorageService.clearUser()
            
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

// MARK: - Delete Button Methods
extension SettingsTableViewController {
    
    @IBAction func deleteAccountButtonTapped(_ sender: UIButton) {
        
        performSegue(withIdentifier: Constants.ID.Segues.deleteAccount, sender: self)
        
    }
    
}

// MARK: - Heading Button Methods
extension SettingsTableViewController {
    
    @objc func headerTapped(button: UIButton) {
        
        // Recover the section from the buttons tag
        let section = button.tag
        
        // Invert the state of the sections expansion
        sectionData[section].isExpanded = !sectionData[section].isExpanded
        
        // Create an empty array of index paths
        var indexPaths = [IndexPath]()
        
        // Collect all the index paths to be removed or added
        for row in 0 ..< sectionData[section].texts.count {
            
            indexPaths.append(IndexPath(row: row, section: section))
            
        }
        
        // Collapse the table view
        if sectionData[section].isExpanded == false {
            
            // Remove all the rows in the section
            tableView.deleteRows(at: indexPaths, with: .fade)
            
        }
        // Expand the table view
        else {
            
            // Add the rows back into the section
            tableView.insertRows(at: indexPaths, with: .fade)
            
        }
        
    }
    
}

// MARK: - Custom Protocol Methods
extension SettingsTableViewController: NameChangedProtocol, EmailChangedProtocol {
    
    func nameWasChanged(name: String) {
        
        // Change the name that is displayed
        sectionData[0].texts[0] = "First Name: \(name)"
        
        // Reload the tableView
        self.tableView.reloadData()
        
    }
    
    func emailWasChanged(email: String) {
        
        // Change the email that is displayed
        sectionData[0].texts[1] = "Email: \(email)"
        
        // Reload the tableView
        self.tableView.reloadData()
        
    }
    
}
