//
//  LocationsCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import CoreLocation

protocol LocationProtocol {
    
    func locationTapped()
    
}

class LocationsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: - Properties
    let locationManager = CLLocationManager()
    var delegate: LocationProtocol?
    
    var buttonTapped = false
    
    // MARK: - View Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the location manager
        locationManager.delegate = self
        
        // Setup the imageViewContainer
        imageViewContainer.layer.cornerRadius = imageViewContainer.bounds.width / 2
        imageViewContainer.backgroundColor    = UIColor.lightGray
        imageViewContainer.clipsToBounds      = true
        
        // Setup the image view
        imageView.image                       = UIImage(named: "LocationImage")
        imageView.tintColor                   = Constants.Color.primary
        
        // Setup the button
        locationButton.setTitleColor(Constants.Color.primary, for: .normal)
        locationButton.setTitleColor(UIColor.white, for: .disabled)
        
        locationButton.layer.borderColor = Constants.Color.primary.cgColor
        locationButton.layer.borderWidth = 1
        
    }
    
}

// MARK: - Button Methods
extension LocationsCollectionViewCell {
    
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        
        buttonTapped = true
        
        // Acknowledge that the user has seen the welcome view and dismiss it
        UserDefaults.standard.set(false, forKey: Constants.Key.firstLaunch)
        
        // Check location services first
        locationManager.requestAlwaysAuthorization()
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor)  {
        
        // Set the state of the button based on the parameters
        locationButton.isEnabled = isActivated
        locationButton.backgroundColor = color
        
    }
    
}

// MARK: - Location Authorization Methods
extension LocationsCollectionViewCell: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check if the user allowed or denied the location request
        if buttonTapped == true {
            checkLocationServices()
        }
        
    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() == true {
            // Check the location authorization
            checkLocationAuthorization()
        }
        else {
            activateButton(isActivated: false, color: Constants.Color.primary)
            delegate?.locationTapped()
        }
        
    }
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
            // Move to the next page
            activateButton(isActivated: false, color: Constants.Color.primary)
            delegate?.locationTapped()
            
        case .notDetermined:
            break
            
        @unknown default:
            break
            
        }
        
    }

}
