//
//  UpdateLocationViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-04.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import CoreLocation
import StoreKit

protocol UpdateLocationProtocol {
    
    func reloadAnnotations()
    
}

final class UpdateLocationViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet var dimView: UIView!
    
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var updateTableView: UITableView!
    
    @IBOutlet weak var updateButton: RoundedButton!
    
    // MARK: - Properties
    var boxesChecked: [Bool] = Array.init(repeating: false, count: Stored.userItems.count)
    
    let locationManager = CLLocationManager()
    var delegate: UpdateLocationProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check the users locationServices
        checkLocationServices()

        // Setup the dim view
        dimView.backgroundColor = UIColor.clear
        
        // Setup the back button
        backButton.tintColor = Constants.Color.primary
        
        // Setup the floating view
        floatingViewWidth.constant       = Constants.View.Width.standard
        floatingViewHeight.constant      = Constants.View.Height.updateLocation + CGFloat(Stored.userItems.count * 50)
        floatingViewYConstraint.constant = UIScreen.main.bounds.height
        
        // Setup the table view
        updateTableView.delegate         = self
        updateTableView.dataSource       = self
        
        // If the floating view is going to overflow the screen then enable scrolling for the table view
        if floatingViewHeight.constant > UIScreen.main.bounds.height - 60 {
            floatingViewHeight.constant = UIScreen.main.bounds.height - 60
            updateTableView.isScrollEnabled = true
        }
        else {
            updateTableView.isScrollEnabled = false
        }
        
        // Update the button
        updateButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Slide the view in
        slideViewIn()
        
    }

}

// MARK: - Navigation Bar Methods
extension UpdateLocationViewController {
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Slide the view out
        slideViewOut()
        
    }
    
}

// MARK: - Update Button Methods
extension UpdateLocationViewController {
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        
        // Disable the button
        updateButton.isEnabled = false
        
        guard let userLocation = [locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude] as? [Double] else {
            updateButton.isEnabled = true
            
            // Let the user know that they have to turn location services on
            present(AlertService.createSettingsAlert(title: "Locations Off", message: "Go to settings to turn your location on",            cancelAction: nil),
                    animated: true,
                    completion: nil)
            
            return
        }
        
        // Check if there is any internet connection
        guard InternetService.checkForConnection() == true else {
            updateButton.isEnabled = true
            ProgressService.errorAnimation(text: "No Internet Connection")
            return
        }
        
        // Show a progress animation
        ProgressService.progressAnimation(text: "Trying to Update the Location of Your Items")
        
        // Get the current date
        let time = getTheDate()
        
        // Iterate through all the items
        for i in 0 ..< Stored.userItems.count {
            
            // Skip the item if the box wasn't checked
            if boxesChecked[i] == false {
                continue
            }
            
            // Retrieve the item being updated
            var item = Stored.userItems[i]
            
            // Change the items location and time of last update
            item.lastUpdateDate = time
            item.mostRecentLocation = userLocation
            
            // Attempt to update the item in firestore
            FirestoreService.updateItem(item: item) { (error) in
                
                // Check if the update was successful
                guard error == nil else {
                    self.updateButton.isEnabled = true
                    ProgressService.errorAnimation(text: "Unable to Update Your Item Locations")
                    return
                }
                
                // Show that the process was successful
                ProgressService.successAnimation(text: "Successfully Updated the Location of Your Items")
                
                // Check if we should ask the user for a review
                self.checkToAskForReview()
                
                // Save the changes locally
                Stored.userItems[i] = item
                LocalStorageService.updateItem(item: item, index: i)
                
                // Tell the delegate reload the annotations and slide the view out
                self.delegate?.reloadAnnotations()
                self.slideViewOut()
                
            }
            
        }
        
    }
    
    func checkToActivateButton() {
        
        // Iterate through all the boxes
        for boxChecked in boxesChecked {
            
            // If the box is checked, then activate the button
            if boxChecked == true {
                updateButton.activateButton(isActivated: true, color: Constants.Color.primary)
                return
            }
            
        }
        
        // If no boxes were checked then deactivate the button
        updateButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
    }
    
}

// MARK: - Animation Methods
extension UpdateLocationViewController {
    
    func slideViewIn() {
        
        // Slide the view in from the botton
        UIView.animate(withDuration: 0.2, animations: {
            
            // First, fade in the dimView
            self.dimView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 180/255)
            
        }) { (true) in
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                // Second, slide in the Floating View
                self.floatingViewYConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
    }
    
    func slideViewOut() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            // First, slide out the Floating View
            self.floatingViewYConstraint.constant = UIScreen.main.bounds.height
            self.view.layoutIfNeeded()
            
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                
                // Second, fade out the Dim View
                self.dimView.backgroundColor = UIColor.clear
                
            }, completion: { (true) in
                
                // Third, dismiss the VC
                self.dismiss(animated: false, completion: nil)
                
            })
        }
        
    }
    
}

// MARK: - Helper Methods
extension UpdateLocationViewController {
    
    func getTheDate() -> String {
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Extract the string for the current time
        return dateFormatter.string(from: Date())
        
    }
    
    func checkToAskForReview() {
        
        // Get the user defaults
        let defaults = UserDefaults.standard
        let updatesPerRequest = 20
        
        // Get the number of times the user has updated and increment it
        var numUpdates = defaults.value(forKey: Constants.Key.numberOfUpdates) as? Int ?? 0
        numUpdates += 1
        
        // If the number of times is divisible by 20 then request a review
        if numUpdates % updatesPerRequest == 0 {
            SKStoreReviewController.requestReview()
        }
        
        // Store the new number of updates
        defaults.set(numUpdates, forKey: Constants.Key.numberOfUpdates)
        
    }
    
}

// MARK: - TableView Methods
extension UpdateLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Create a row for each registered item
        return Stored.userItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ID.Cell.updateLocation, for: indexPath) as? UpdateLocationTableViewCell else { return UITableViewCell() }
        
        // Set the properties for the cell
        cell.selectionStyle = .none
        cell.cellIndex = indexPath.row
        cell.itemName.text = Stored.userItems[indexPath.row].name
        cell.delegate = self
        
        if let url = URL(string: Stored.userItems[indexPath.row].imageURL) {
            cell.setPhoto(url: url)
        }
        
        // Return the cell
        return cell
        
        
    }
    
}

// MARK: - UpdateLocationCell Methods
extension UpdateLocationViewController: UpdateLocationCellProtocol {
   
    func itemSelected(index: Int, state: Bool) {
        
        // Set the buttons state
        boxesChecked[index] = state
        
        // Check to activate the button
        checkToActivateButton()
        
    }
    
}

// MARK: - Location Methods
extension UpdateLocationViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        
        // Setup the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationServices() {
        
        // Check if the location services are enabled
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        
    }
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        // Case if its not determined
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            
        // Case if no authorization
        case .restricted, .denied:
            break
            
        @unknown default:
            break
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check the location authorization
        checkLocationServices()
        
    }
    
}
