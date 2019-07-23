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
    
    func locationTapped(access: Bool?)
    
}

class LocationsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var locationButton: UIButton!
    
    let locationManager = CLLocationManager()
    var delegate: LocationProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
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
        
        // Check location services first
        checkLocationServices()
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor)  {
        
        // Set the state of the button based on the parameters
        locationButton.isEnabled = isActivated
        locationButton.backgroundColor = color
        
    }
    
}

// MARK: - Location Authorization Methods
extension LocationsCollectionViewCell {
    
    func checkLocationServices() {
        
        // If the user has location services enabled then setup the location manager and check authorization
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
        else {
            // Let the user know that they have to turn location services on
            delegate?.locationTapped(access: false)
            activateButton(isActivated: true, color: UIColor.white)
        }
        
    }
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            delegate?.locationTapped(access: true)
            activateButton(isActivated: false, color: Constants.Color.primary)
            
        // Case if its not determined
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            delegate?.locationTapped(access: nil)
            activateButton(isActivated: false, color: Constants.Color.primary)
            
        // Case if no authorization
        case .restricted, .denied:
            // Let the user know that they have to turn location services on
            delegate?.locationTapped(access: false)
            activateButton(isActivated: true, color: UIColor.white)
            
        @unknown default:
            break
        }
        
    }
    
}
