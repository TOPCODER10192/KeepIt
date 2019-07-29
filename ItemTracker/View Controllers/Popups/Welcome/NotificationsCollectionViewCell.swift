//
//  NotificationsCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsCollectionViewCell: UICollectionViewCell {

    // MARK: IBOutlet Properties
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notificationsButton: UIButton!
    
    // MARK: - View Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the imageViewContainer
        imageViewContainer.layer.cornerRadius = imageViewContainer.bounds.width / 2
        imageViewContainer.backgroundColor    = UIColor.lightGray
        imageViewContainer.clipsToBounds      = true
        
        // Setup the image view
        imageView.image                       = UIImage(named: "NotificationImage")
        imageView.tintColor                   = Constants.Color.primary
        
        // Setup the button
        notificationsButton.setTitleColor(Constants.Color.primary, for: .normal)
        notificationsButton.setTitleColor(UIColor.white, for: .disabled)
        
        notificationsButton.layer.borderColor = Constants.Color.primary.cgColor
        notificationsButton.layer.borderWidth = 1
        
    }
    
}

// MARK: - Button Methods
extension NotificationsCollectionViewCell {
    
    @IBAction func notificationsButtonTapped(_ sender: UIButton) {
        
        // Acknowledge that the user has seen the welcome view and dismiss it
        UserDefaults.standard.set(false, forKey: Constants.Key.firstLaunch)
        
        // Ask the user if they want notifications, if they say yes set a default for 7PM Daily
        NotificationService.createTimedNotification(hour: 19, minute: 0, repeats: true)
        
        // Disable the button
        activateButton(isActivated: false, color: Constants.Color.primary)
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        // Set the button state
        notificationsButton.isEnabled = isActivated
        notificationsButton.backgroundColor = color
        
    }
    
}
