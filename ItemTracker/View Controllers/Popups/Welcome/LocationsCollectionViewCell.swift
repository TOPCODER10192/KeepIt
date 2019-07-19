//
//  LocationsCollectionViewCell.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import CoreLocation

class LocationsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var locationButton: UIButton!
    
    let locationManager = CLLocationManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the button
        locationButton.layer.borderColor = Constants.Color.primary.cgColor
        locationButton.layer.borderWidth = 1
        
    }

    @IBAction func locationButtonTapped(_ sender: UIButton) {
        
        // Request Access to the users location
        locationManager.requestAlwaysAuthorization()
        
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.backgroundColor = Constants.Color.primary
        
    }
}
