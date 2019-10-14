//
//  ProgressService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-17.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import SVProgressHUD

final class ProgressService {
    
    private static func setupSVProgressHUD() {
        
        // Set the colors
        SVProgressHUD.setBackgroundColor(Constants.Color.notificationView)
        SVProgressHUD.setForegroundColor(Constants.Color.primary)
        
        // Set the font
        SVProgressHUD.setFont(UIFont(name: "SF Pro Text", size: 16) ?? UIFont.systemFont(ofSize: 16))
        
    }
    
    static func progressAnimation(text: String?) {
        
        // Setup SVProgressHUD
        setupSVProgressHUD()
        
        // Show the animation with the desired text
        SVProgressHUD.show(withStatus: text)
        
    }
    
    static func errorAnimation(text: String?) {
        
        // Setup SVProgressHUD
        setupSVProgressHUD()
        
        // Show the error with the desired text
        SVProgressHUD.showError(withStatus: text)
        SVProgressHUD.dismiss(withDelay: 2)
        
    }
    
    static func successAnimation(text: String?) {
        
        // Setup SVProgressHUD
        setupSVProgressHUD()
        
        // Show the error with the desired text
        SVProgressHUD.showSuccess(withStatus: text)
        SVProgressHUD.dismiss(withDelay: 2)
        
    }
    
}
