//
//  AddItemViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddItemViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var addItemStackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var movementSegmentedDisplay: UISegmentedControl!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationSegmentedDisplay: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    // MARK: - AddItemViewController Properties
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the Stack View
        addItemStackViewHeight.constant = 250

        // Setup the mapView
        mapViewHeight.constant = 0
        mapView.layer.borderColor = Constants.PRIMARY_COLOR.cgColor
        mapView.layer.borderWidth = 1
        checkLocationServices()
        
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        // Dismiss the view
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func locationSegmentChanged(_ sender: UISegmentedControl) {
        
        if locationSegmentedDisplay.selectedSegmentIndex == 0 {
            
            UIView.animate(withDuration: 0.3) {
                self.addItemStackViewHeight.constant -= 200
                self.mapViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            
            UIView.animate(withDuration: 0.3) {
                self.addItemStackViewHeight.constant += 200
                self.mapViewHeight.constant = 200
                self.view.layoutIfNeeded()
            }
            
        }
    }
    
}

// MARK: - Helper Methods
extension AddItemViewController {
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            // Show an alert
            break
        case .denied:
            // Show alert that tells how to turn on location services
            break
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
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: Constants.REGION_IN_METERS / 10,
                                                 longitudinalMeters: Constants.REGION_IN_METERS / 10)
            mapView.setRegion(region, animated: false)
        }
        
    }
    
}

// MARK: Methods Conforming to CLLocationManagerDelegate
extension AddItemViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Check that the location isn't nil
        guard let locations = locations.last else { return }
        
        // Get the center and the region
        let center = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        // Set the mapview
        mapView.setRegion(region, animated: false)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
