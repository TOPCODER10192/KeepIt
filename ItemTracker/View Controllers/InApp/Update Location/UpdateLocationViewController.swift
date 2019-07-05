//
//  UpdateLocationViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-04.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class UpdateLocationViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet var dimView: UIView!
    
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var updateTableView: UITableView!
    
    @IBOutlet weak var updateButton: UIButton!
    
    // MARK: - UpdateLoctationViewController Properties
    var boxesChecked: [Bool] = Array.init(repeating: false, count: Stored.userItems.count)
    
    let locationManager = CLLocationManager()
    let db = Firestore.firestore()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check the users locationServices
        checkLocationServices()

        // Setup the dim view
        dimView.backgroundColor = UIColor.clear
        
        // Setup the floating view
        floatingView.backgroundColor     = Constants.Color.floatingView
        floatingView.layer.cornerRadius  = Constants.View.CornerRadius.standard
        floatingViewWidth.constant       = Constants.View.Width.standard
        floatingViewHeight.constant      = Constants.View.Height.updateLocation + CGFloat(Stored.userItems.count * 50)
        floatingViewYConstraint.constant = UIScreen.main.bounds.height
        
        // Setup the navigation bar
        navigationBar.layer.cornerRadius = Constants.View.CornerRadius.standard
        navigationBar.clipsToBounds      = true
        
        // Setup the table view
        updateTableView.delegate         = self
        updateTableView.dataSource       = self
        
        if floatingViewHeight.constant > UIScreen.main.bounds.height - 20 {
            updateTableView.isScrollEnabled = true
        }
        else {
            updateTableView.isScrollEnabled = false
        }
        
        // Setup the add button
        updateButton.layer.cornerRadius  = Constants.View.CornerRadius.button
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        slideViewIn()
        
    }
    
    
    // MARK: - IBAction Methods
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        slideViewOut()
        
    }
    
    @IBAction func updateButtonTapped(_ sender: UIButton) {
        
        // Get a reference to the users items collection
        let itemsRef = db.collection(Constants.Key.User.users).document(Stored.user!.email).collection(Constants.Key.Item.items)
        
        // Get the users information and cast it as [Double]
        let usersLocation = [locationManager.location?.coordinate.latitude, locationManager.location?.coordinate.longitude] as! [Double]
        
        // Get the current date
        let time = getTheDate()
        
        // Iterate through all the items
        for i in 0 ..< Stored.userItems.count {
            
            // Skip the item if the box wasn't checked
            if boxesChecked[i] == false {
                continue
            }
            
            var item = Stored.userItems[i]
            item.lastUpdateDate = time
            item.mostRecentLocation = usersLocation
            
            Stored.userItems[i] = item
            LocalStorageService.saveUserItem(item: item, isNew: false, index: i)
            UserService.writeItem(item: item, ref: itemsRef.document(item.name))
            
        }
        
        slideViewOut()
        
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
    
}

// MARK: - TableView Methods
extension UpdateLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Stored.userItems.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ID.Cell.updateLocation, for: indexPath) as! UpdateLocationTableViewCell
        
        cell.selectionStyle = .none
        cell.cellIndex = indexPath.row
        cell.itemName.text = Stored.userItems[indexPath.row].name
        cell.delegate = self
        
        if let url = URL(string: Stored.userItems[indexPath.row].imageURL) {
            cell.setPhoto(url: url)
        }
        
        return cell
        
        
    }
    
}

// MARK: - UpdateLocationCell Methods
extension UpdateLocationViewController: UpdateLocationCellProtocol {
   
    func itemSelected(index: Int, state: Bool) {
        
        boxesChecked[index] = state
        
    }
    
}

// MARK: - Location Manager Methods
extension UpdateLocationViewController: CLLocationManagerDelegate {
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        // Case if its not determined
        case .notDetermined:
            break
            
        // Case if no authorization
        case .restricted, .denied:
            // Dismiss the view controller
            slideViewOut()
            
        @unknown default:
            break
        }
        
    }
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            // Let the user know that they have to turn location services on
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check the location authorization
        checkLocationAuthorization()
        
    }
    
}
