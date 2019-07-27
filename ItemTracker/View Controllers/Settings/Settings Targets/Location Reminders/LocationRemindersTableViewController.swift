//
//  LocationRemindersTableViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import CoreLocation

class LocationRemindersTableViewController: UITableViewController {
    
    // MARK: IBOutlet Properties
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var addGeoFenceButton: RoundedButton!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    
    // MARK: View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the info label
        infoLabel.adjustsFontSizeToFitWidth = true
        loadInfoLabel()
        
        // Setup the addGeoFenceButton
        addGeoFenceButton.setTitleColor(UIColor.white, for: .normal)
        addGeoFenceButton.setTitleColor(UIColor.clear, for: .disabled)
        
        checkToActivateButton()

        // Display an edit button
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // Expand the footerView to show an add button
        if editing == true {
            
            UIView.animate(withDuration: 0.2) {
                self.addGeoFenceButton.activateButton(isActivated: true, color: Constants.Color.primary)
            }
            
        }
        else {
            
            UIView.animate(withDuration: 0.2) {
                self.checkToActivateButton()
            }
            
        }
        
    }

}

extension LocationRemindersTableViewController {
    
    func loadInfoLabel() {
        
        if Stored.geoFences.count > 0 {
            
            infoLabel.text = "All your GeoFences are shown below. We will remind you to update the location of your items when you enter or exit these areas"
            infoLabel.font = UIFont(name: "SF Pro Text", size: 18)
            infoLabel.textColor = UIColor.darkText
            
        }
        else {
            
            infoLabel.text = "You Have No GeoFences, Click On The Button Below To Register One"
            infoLabel.font = UIFont(name: "Trebuchet MS", size: 18)
            infoLabel.textColor = UIColor.gray
            
        }
        
    }
}

// MARK: - Row Methods
extension LocationRemindersTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of geofences the user has registered
        return Stored.geoFences.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ID.Cell.geoFence, for: indexPath) as! LocationRemindersTableViewCell
        
        // Get the corresponding geofence for the cell
        let geoFence = Stored.geoFences[indexPath.row]
        
        // Center the mapview on the geofence
        cell.centerMapViewOnGeoFence(coordinate: geoFence.centreCoordinate, radius: geoFence.radius)
        
        // Set the name for the cell
        cell.nameLabel.text = geoFence.name
        
        // Show whether a notification is triggered on entrance
        if geoFence.triggerOnEntrance == true {
            cell.entryNotificationLabel.text = "Notify on Entry: YES"
        }
        else {
            cell.entryNotificationLabel.text = "Notify on Entry: NO"
        }
        
        // Show whether a notification is triggered on exit
        if geoFence.triggerOnExit == true {
            cell.exitNotificationLabel.text = "Notify on Exit: YES"
        }
        else {
            cell.exitNotificationLabel.text = "Notify on Exit: NO"
        }
        
        
        return cell
    }
    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        // Disable reordering of the row
        return false
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Enable editing of the row
        return true
        
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // Stop Monitoring the geofence
            stopMonitoring(geoFence: Stored.geoFences[indexPath.row])
            
            // Delete the geofence from local storage
            Stored.geoFences.remove(at: indexPath.row)
            LocalStorageService.deleteGeoFence(index: indexPath.row)
            
            // Clear the overlays for the cell
            if let cell = tableView.cellForRow(at: indexPath) as? LocationRemindersTableViewCell {
                cell.clearMapOverlays()
            }
            
            
            // Load the new info label
            loadInfoLabel()
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Reload data for the tableview
            tableView.reloadData()
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Check if the cell can be cast as location reminders table view cell
        guard let cell = cell as? LocationRemindersTableViewCell else { return }
        
        // Clear all the overlays in the cell
        cell.clearMapOverlays()
        
    }
    
}

// MARK: - Section Methods
extension LocationRemindersTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // return a single section for the geofences
        return 1
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Create a view
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        headerView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 255/255)
        
        // Create a section title
        let sectionTitle = UILabel(frame: CGRect(x: 20, y: 0, width: 200, height: 30))
        sectionTitle.font = UIFont.boldSystemFont(ofSize: 22)
        sectionTitle.text = "GeoFences"
        
        sectionTitle.isHidden = Stored.geoFences.count == 0
        
        // Add the section title to the view
        headerView.addSubview(sectionTitle)
        
        return headerView
        
    }
    
}

// MARK: - Add GeoFence Button Methods
extension LocationRemindersTableViewController: AddGeoFenceProtocol {
    
    @IBAction func addGeoFenceButtonTapped(_ sender: RoundedButton) {
        
        // Create the addGeoFence Controller
        guard let addGeoFenceVC = UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main)
            .instantiateViewController(withIdentifier: Constants.ID.VC.addGeoFence) as? AddGeoFenceViewController else {
                return
        }
        
        addGeoFenceVC.delegate = self
        
        addGeoFenceVC.modalPresentationStyle = .overCurrentContext
        present(addGeoFenceVC, animated: false, completion: nil)
        
    }
    
    func checkToActivateButton() {
        
        // Check if the user has any geofences
        if Stored.geoFences.count > 0 {
            addGeoFenceButton.activateButton(isActivated: false, color: UIColor.clear)
        }
        else {
            addGeoFenceButton.activateButton(isActivated: true, color: Constants.Color.primary)
        }
        
    }
    
    func geoFenceAdded(geoFence: GeoFence) {
        
        tableView.insertRows(at: [IndexPath(row: tableView.numberOfRows(inSection: 0), section: 0)], with: .fade)
        loadInfoLabel()
        tableView.reloadData()
        
    }
    
}

// MARK: Location Methods
extension LocationRemindersTableViewController {
    
    func stopMonitoring(geoFence: GeoFence) {
        
        // Iterate through the geofences
        for region in locationManager.monitoredRegions {
            
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geoFence.id else { continue }
            locationManager.stopMonitoring(for: circularRegion)
            
        }
        
    }
    
}
