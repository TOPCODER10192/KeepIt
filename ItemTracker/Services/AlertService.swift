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
    
    static func createSettingsAlert(title: String?, message: String?, cancelAction: (() -> Void)?) -> UIAlertController {
        
        // Pop up a notification that tells the user how to allow location
        let settingsAlert = UIAlertController(title: title,
                                              message: message ,
                                              preferredStyle: .alert)
            
        settingsAlert.addAction(UIAlertAction(title: "Go to Settings",
                                              style: .default,
                                              handler: { (action) in
            
            // Go to the settings app
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            
        }))
        
        settingsAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (action) in
            
            cancelAction?()
            
        }))
        
        return settingsAlert
    }
    
}
