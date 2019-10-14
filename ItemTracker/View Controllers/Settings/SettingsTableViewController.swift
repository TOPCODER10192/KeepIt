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

import FirebaseAuth

struct CellData {
    
    var text: String
    let icon: UIImage
    let target: String
    let showIfAnonymous: Bool
    let showIfSignedIn: Bool
    
}

protocol SettingsProtocol {
    
    func settingsClosed()
    func showWalkthrough()
    
}

final class SettingsTableViewController: UITableViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var signOutButton: UIBarButtonItem!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    // MARK: - Properties
    var tableData = [CellData(text: "Change Email", icon: UIImage(named: "MailIcon")!, target: "ChangeEmailSegue", showIfAnonymous: false, showIfSignedIn: true),
                     CellData(text: "Change Password", icon: UIImage(named: "LockIcon")!, target: "ChangePasswordSegue", showIfAnonymous: false, showIfSignedIn: true),
                     CellData(text: "Link Account to An Email", icon: UIImage(named: "LinkIcon")!, target: "LinkAccountSegue", showIfAnonymous: true, showIfSignedIn: false),
                     CellData(text: "Timed Reminders", icon: UIImage(named: "TimedNotificationIcon")!, target: "TimedRemindersSegue", showIfAnonymous: true, showIfSignedIn: true),
                     CellData(text: "Location Reminders", icon: UIImage(named: "LocationNotificationIcon")!, target: "LocationRemindersSegue", showIfAnonymous: true, showIfSignedIn: true),
                     CellData(text: "Show Walkthrough Again", icon: UIImage(named: "WalkthroughIcon")!, target: "Walkthrough", showIfAnonymous: true, showIfSignedIn: true),
                     CellData(text: "Report a Problem", icon: UIImage(named: "ErrorIcon")!, target: "Mail", showIfAnonymous: true, showIfSignedIn: true),
                     CellData(text: "Credits", icon: UIImage(named: "CreditIcon")!, target: "CreditsSegue", showIfAnonymous: true, showIfSignedIn: true)]
    
    var delegate: SettingsProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the navigation controller
        self.navigationController?.navigationBar.tintColor = Constants.Color.primary
        
        // Setup the closeButton
        closeButton.tintColor = Constants.Color.primary
        
        // Setup the email label
        emailLabel.text = Auth.auth().currentUser?.email ?? "Anonymous User"
        
        // Setup the signOutButton
        signOutButton.tintColor   = Constants.Color.primary
        signOutButton.isEnabled   = !(Auth.auth().currentUser!.isAnonymous)
        
        if Auth.auth().currentUser!.isAnonymous == true {
            signOutButton.tintColor   = UIColor.clear
        }
        
        // Setup the delete account button
        deleteAccountButton.backgroundColor = Constants.Color.deleteButton
        deleteAccountButton.isHidden        = Auth.auth().currentUser!.isAnonymous
        
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ID.Cell.settingsRow) as? SettingsRowTableViewCell else {
            return UITableViewCell()
        }
        
        // Set the label to match the section and row in the sectionData
        cell.iconImageView.image = tableData[indexPath.row].icon
        cell.label.text          = tableData[indexPath.row].text
        
        if Auth.auth().currentUser!.isAnonymous {
            cell.isHidden = !tableData[indexPath.row].showIfAnonymous
        }
        else {
            cell.isHidden = !tableData[indexPath.row].showIfSignedIn
        }
        
        
        // Return the cell
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        // Check if the cell should be hidden
        if (Auth.auth().currentUser!.isAnonymous == true && tableData[indexPath.row].showIfAnonymous == false) ||
           (Auth.auth().currentUser!.isAnonymous == false && tableData[indexPath.row].showIfSignedIn == false) {
            return 0
        }
        
        // Let the row height be 44
        return 44
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Segue to the rows target view controller
        let segueID = tableData[indexPath.row].target
        
        if segueID == "Mail" {
            
            composeMail()
            
        }
        else if segueID == "Walkthrough" {
            
            // Tell the delegate that the settings will be closed and present the walkthrough
            delegate?.settingsClosed()
            
            // Close the settings tab
            self.dismiss(animated: true) {
                self.delegate?.showWalkthrough()
            }
            
        }
        else {
            
            performSegue(withIdentifier: segueID, sender: self)
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Let the destinationVC be the destination of the segue
        let destinationVC = segue.destination

        // Attempt to type cast it as a ChangeEmailVC
        if let destinationVC = destinationVC as? ChangeEmailViewController {
            destinationVC.delegate = self
        }
        else if let destinationVC = destinationVC as? LinkAccountViewController {
            destinationVC.delegate = self
        }
        
    }
    
}

// MARK: - Navigation Bar Button Methods
extension SettingsTableViewController {
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        
        // Tell the delegate that the settings has been closed
        delegate?.settingsClosed()
        
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
            Stored.userItems = [Item]()
            
            // Create the authVC
            let authVC = UIStoryboard(name: Constants.ID.Storyboard.auth, bundle: .main)
                .instantiateViewController(withIdentifier: Constants.ID.VC.initial) as! InitialViewController
            
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
        
        // Segue to the delete account vc
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
extension SettingsTableViewController: EmailChangedProtocol, LinkAccountProtocol {
    
    func emailWasChanged(email: String) {
        
        // Change the email that is displayed
        emailLabel.text = email
        
    }
    
    func accountLinked() {
    
        // Update the name and email label
        emailLabel.text = Auth.auth().currentUser?.email ?? "Anonymous User"
        
        // Make the sign out and delete account buttons visible
        signOutButton.isEnabled = true
        signOutButton.tintColor = Constants.Color.primary
        
        deleteAccountButton.isHidden = false
        
        // Reload the table view
        tableView.reloadData()
        
    }
    
}
