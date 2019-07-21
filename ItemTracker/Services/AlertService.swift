//
//  ErrorService.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-12.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

class AlertService {
    
    static func createGeneralAlert(description: String) -> UIAlertController {
        
        let successAlert = UIAlertController(title: description, message: nil, preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        return successAlert
        
    }
    
    static func createLocationsAlert() -> UIAlertController{
        
        // Pop up a notification that tells the user how to allow location
        let locationsAlert = UIAlertController(title: "Location Services Off", message: "Go to Settings to Turn Them On" , preferredStyle: .alert)
        locationsAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        locationsAlert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            
            // Go to the settings app
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            
        }))
        
        return locationsAlert
    }
    
}