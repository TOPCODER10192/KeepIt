//
//  EditGeoFenceViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-08-01.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

import MapKit
import CoreLocation

protocol EditGeoFenceProtocol {
    
    func geoFenceEdited(geoFence: GeoFence)
    
}

final class EditGeoFenceViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet var dimView: UIView!
    
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewY: NSLayoutConstraint!
    
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var entrySwitch: UISwitch!
    @IBOutlet weak var exitSwitch: UISwitch!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var radiusTextField: UITextField!
    
    @IBOutlet weak var saveChangesButton: RoundedButton!
    
    // MARK: - Properties
    var geoFence: GeoFence?
    var index: Int?
    
    var name: String?
    var triggerOnEntry: Bool?
    var triggerOnExit: Bool?
    var center: [Double]?
    var radius: Double?
    var id: String?
    
    let locationManager = CLLocationManager()
    var delegate: EditGeoFenceProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize thge properties
        self.name           = geoFence?.name
        self.triggerOnEntry = geoFence?.triggerOnEntrance
        self.triggerOnExit  = geoFence?.triggerOnExit
        self.center         = geoFence?.centreCoordinate
        self.radius         = geoFence?.radius
        self.id             = geoFence?.id
        
        // Setup the dimView
        dimView.backgroundColor = UIColor.clear

        // Setup the floating view
        floatingViewY.constant = UIScreen.main.bounds.height
        floatingViewWidth.constant = Constants.View.Width.standard
        floatingViewHeight.constant = Constants.View.Height.editGeoFence
        
        // Setup the navigation bar
        backButton.tintColor = Constants.Color.primary
        navigationBarTitle.title = geoFence?.name
        
        // Setup the name text field text
        nameTextField.placeholder = geoFence?.name
        nameTextField.delegate    = self
        
        // Setup the switches
        entrySwitch.isOn          = geoFence!.triggerOnEntrance
        entrySwitch.onTintColor   = Constants.Color.primary
        entrySwitch.tintColor     = Constants.Color.softPrimary
        
        exitSwitch.isOn           = geoFence!.triggerOnExit
        exitSwitch.onTintColor    = Constants.Color.primary
        exitSwitch.tintColor      = Constants.Color.softPrimary
        
        // Setup the map
        mapView.delegate = self
        let latitude  = geoFence!.centreCoordinate[0]
        let longitude = geoFence!.centreCoordinate[1]
        let center    = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        drawGeoFence(center: center)
        centerMapOnGeoFence(center: center)
        
        // Setup the search bar
        mapSearchBar.delegate          = self
        mapSearchBar.backgroundImage   = UIImage()
        mapSearchBar.backgroundColor   = UIColor.white
        mapSearchBar.layer.borderColor = Constants.Color.primary.cgColor
        mapSearchBar.layer.borderWidth = 1
        
        // Setup the button
        saveChangesButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Slide the view in
        slideViewIn()
    }

}

// MARK: - Navigation Bar Methods
extension EditGeoFenceViewController {
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Slide the view out, dont make any changes
        slideViewOut()
        
    }
    
    
}

// MARK: - Text Field Methods
extension EditGeoFenceViewController: UITextFieldDelegate {
    
    @IBAction func nameTextFieldEditing(_ sender: UITextField) {
        
        // Set the name to match the text field
        self.name = nameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func radiusTextFieldEditingEnded(_ sender: UITextField) {
        
        // Check if the map has any overlays
        guard mapView.overlays.count > 0 else { return }
        
        // Redraw the geofence if it does
        drawGeoFence(center: mapView.overlays[0].coordinate)
        
    }
    
    @objc func doneButtonTapped() {
        
        // Lower the number pad
        view.endEditing(true)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // If its not the radius text field, then return
        guard textField == radiusTextField else { return true }
        
        // Find out what the text field will be after adding the current edit
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        // See if the text can be cast as a double
        if let numText = Double(text) {
            radius = numText
        }
        
        // Return true so the text field will be changed
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Lower the keyboard
        textField.resignFirstResponder()
        return true
        
    }
    
}

// MARK: - Switch Methods
extension EditGeoFenceViewController {
    
    @IBAction func entrySwitchValueChanged(_ sender: UISwitch) {
        
        // Set the value for triggering on entry
        self.triggerOnEntry = entrySwitch.isOn
        
    }
    
    @IBAction func exitSwitchValueChanged(_ sender: UISwitch) {
        
        // Set the value for triggering on exit
        self.triggerOnExit = exitSwitch.isOn
        
    }
    
}

// MARK: - Search Bar Methods
extension EditGeoFenceViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Lower the keyboard
        searchBar.resignFirstResponder()
        
        // Check if the seacrch bar has any text
        guard let location = searchBar.text, searchBar.text!.count > 0 else { return }
        
        // Check if the user has internet connection
        guard InternetService.checkForConnection() == true else {
            ProgressService.errorAnimation(text: "No Internet Connection")
            return
        }
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = location
        
        // Create an active search based off the search request and start the search
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            // If the search was unsuccessful then present an error message
            guard response != nil && error == nil else {
                ProgressService.errorAnimation(text: "No result For \"\(location)\"")
                return
            }
            
            // Check that the coordinates are not nil
            guard let latitude = response?.boundingRegion.center.latitude else { return }
            guard let longitude = response?.boundingRegion.center.longitude else { return }
            self.center = [latitude, longitude]
            
            let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
            
            // Create the annotation for the item
            self.drawGeoFence(center: coordinates)
            self.centerMapOnGeoFence(center: coordinates)
            
            // Check to see if the item should be activated
            self.checkToActivateButton()
            
        }
        
    }
    
}

// MARK: - Map Methods
extension EditGeoFenceViewController: MKMapViewDelegate {
    
    @IBAction func mapViewHeld(_ sender: UILongPressGestureRecognizer) {
        
        // Get the location of the tap and convert to a coordinate
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Reset the value of the coordinate
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let centerCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.center = [latitude, longitude]
        
        // Draw the geofence
        drawGeoFence(center: centerCoordinate)
        
    }
    
    func drawGeoFence(center: CLLocationCoordinate2D) {
        
        // Create a circular overlay and remove all preexisting ones
        let circle = MKCircle(center: center, radius: self.radius!)
        mapView.removeOverlays(mapView.overlays)
        mapView.addOverlay(circle)
        
    }
    
    func centerMapOnGeoFence(center: CLLocationCoordinate2D) {
        
        // Center the map over the geofence
        let region = MKCoordinateRegion(center: center, latitudinalMeters: self.radius! * 3, longitudinalMeters: self.radius! * 3)
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Check if the overlay can be cast as an MKCircle
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
        // Render the circle and set its properties
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        circleRenderer.strokeColor = Constants.Color.primary
        circleRenderer.lineWidth   = 5
        circleRenderer.fillColor   = Constants.Color.softPrimary
        circleRenderer.alpha       = 0.5
        
        // Return the circle renderer
        return circleRenderer
        
    }
    
}

// MARK: - Location Methods
extension EditGeoFenceViewController {
    
    func startMonitoring(geoFence: GeoFence) -> Bool {
        
        // Check if the device supports geofencing
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) == true else {
            present(AlertService.createGeneralAlert(description: "Geofencing Not Available On This Device"),
                    animated: true, completion: nil)
            return false
        }
        
        // Check if the user always allows location access
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else {
            present(AlertService.createSettingsAlert(title: "Location Permissions Must Be \"Always\" to Use GeoFences",
                                                     message: "",
                                                     cancelAction: nil),
                    animated: true,
                    completion: nil)
            return false
        }
        
        // Get the fence region for the geofence
        let fenceRegion = createRegion(with: geoFence)
        
        // Start monitoring for the geofence
        locationManager.startMonitoring(for: fenceRegion)
        
        return true
    }
    
    func createRegion(with geoFence: GeoFence) -> CLCircularRegion {
        
        // Set the region for the geofence
        let latitude = geoFence.centreCoordinate[0] as CLLocationDegrees
        let longitude = geoFence.centreCoordinate[1] as CLLocationDegrees
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = CLCircularRegion(center: center,
                                      radius: geoFence.radius,
                                      identifier: geoFence.id)
        
        // Get the notification conditions for the geofence
        region.notifyOnEntry = geoFence.triggerOnEntrance
        region.notifyOnExit = geoFence.triggerOnExit
        
        return region
        
    }
    
}

// MARK: - Save Changes Button Methods
extension EditGeoFenceViewController {
    
    @IBAction func saveChangesButtonTapped(_ sender: RoundedButton) {
        
        // Create a new geofence from the new info
        let newGeoFence = GeoFence(name: self.name!,
                                   centreCoordinate: self.center!,
                                   radius: self.radius!,
                                   triggerOnEntrance: self.triggerOnEntry!,
                                   triggerOnExit: self.triggerOnExit!,
                                   id: self.id!)
        
        // Check if the device can monitor for geofences
        guard startMonitoring(geoFence: newGeoFence) == true else { return }
        
        // Store the geofence locally
        LocalStorageService.updateGeoFence(index: index!, geoFence: newGeoFence)
        Stored.geoFences[index!] = newGeoFence
        
        ProgressService.successAnimation(text: "Successfully Updated GeoFence!")
        
        // Tell the delegate that a geofence was added
        delegate?.geoFenceEdited(geoFence: newGeoFence)
        
        // Slide the view out
        slideViewOut()
        
    }
    
    func checkToActivateButton() {
    
        // Check to see if all the fields are filled
        guard name != nil, name!.count > 0 else {
            saveChangesButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        saveChangesButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
}

// MARK: - Animation Methods
extension EditGeoFenceViewController {
    
    func slideViewIn() {
        
        // Slide the view in from the botton
        UIView.animate(withDuration: 0.2, animations: {
            
            // First, fade in the dimView
            self.dimView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 180/255)
            
        }) { (true) in
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                // Second, slide in the Floating View
                self.floatingViewY.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
    }
    
    func slideViewOut() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            // First, slide out the Floating View
            self.floatingViewY.constant = UIScreen.main.bounds.height
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
    
    func lowerKeyboard() {
        
        // Lower the keyboard
        nameTextField.resignFirstResponder()
        mapSearchBar.resignFirstResponder()
        
    }
    
}
