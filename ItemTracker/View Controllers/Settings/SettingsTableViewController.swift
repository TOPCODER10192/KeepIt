//
//  SettingsTableViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-11.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MessageUI

import FirebaseAuth
import FirebaseFirestore

struct CellData {
    
    var text: String
    let icon: UIImage
    let target: String
    
}

class SettingsTableViewController: UITableViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    // MARK: - Properties
    var tableData = [CellData(text: "Change Name", icon: UIImage(named: "NameIcon")!, target: "ChangeNameSegue"),
                     CellData(text: "Change Email", icon: UIImage(named: "MailIcon")!, target: "ChangeEmailSegue"),
                     CellData(text: "Change Password", icon: UIImage(named: "LockIcon")!, target: "ChangePasswordSegue"),
                     CellData(text: "Notifications", icon: UIImage(named: "BellIcon")!, target: "PhoneNotificationsSegue"),
                     CellData(text: "Report a Problem", icon: UIImage(named: "ErrorIcon")!, target: ""),
                     CellData(text: "Credits", icon: UIImage(named: "CreditIcon")!, target: "CreditsSegue")]
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the navigation controller
        self.navigationController?.navigationBar.tintColor = Constants.Color.primary
        
        // Setup the closeButton
        closeButton.tintColor = Constants.Color.primary
        
        // Setup the signOutButton
        signOutButton.tintColor   = Constants.Color.primary
        
        // Setup the name label and the email label
        nameLabel.text  = "\(Stored.user!.firstName) \(Stored.user!.lastName)"
        emailLabel.text = "\(Stored.user!.email)"
        
        // Setup the delete account button
        deleteAccountButton.backgroundColor = Constants.Color.deleteButton
        
    }

}

// MARK: - Table View Methods
extension SettingsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Return the number of sections
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tableData.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Let the cell be a settings bodyCell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ID.Cell.settingsRow) as! SettingsRowTableViewCell
        
        // Set the label to match the section and row in the sectionData
        cell.iconImageView.image = tableData[indexPath.row].icon
        cell.label.text          = tableData[indexPath.row].text
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Let the row height be 44
        return 44
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the rows target view controller
        let segueID = tableData[indexPath.row].target
        
        if segueID == "" {
            composeMail()
        }
        else {
            performSegue(withIdentifier: segueID, sender: self)
        }
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

// MARK: - Mail Methods
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    func composeMail() {
        
        // Check if the device can send mail
        guard MFMailComposeViewController.canSendMail() else {
            ProgressService.errorAnimation(text: "Your Device Can't Send Mail")
            return
        }
        
        // Create a mail composer and send it to the support email
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients([Constants.Email.support])
        composer.setSubject("Problem/Suggestion")
        
        // Present the mail composer
        present(composer, animated: true, completion: nil)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // Check if there was an error
        guard error == nil else { return }
        
        // Switch over the results of the mail composition
        switch result {
        case .cancelled, .saved:
            break
            
        case .failed:
            ProgressService.errorAnimation(text: "Unable to Send Email")
            
        case .sent:
            ProgressService.successAnimation(text: "Email Sent, We'll Get Back to You Soon!")
            
        @unknown default:
            break
        }
        
        // Dismiss the composer
        dismiss(animated: true, completion: nil)
        
        
        
    }
    
}

// MARK: - Custom Protocol Methods
extension SettingsTableViewController: NameChangedProtocol, EmailChangedProtocol {
    
    func nameWasChanged(name: String) {
        
        // Change the name that is displayed
        nameLabel.text = name
        
    }
    
    func emailWasChanged(email: String) {
        
        // Change the email that is displayed
        emailLabel.text = email
        
    }
    
}
