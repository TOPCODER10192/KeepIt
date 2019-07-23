//
//  NotificationsCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import UserNotifications

protocol NotificationsProtocol {
    
    func notificationsTapped(access: Bool)
    
}

class NotificationsCollectionViewCell: UICollectionViewCell {

    // MARK: IBOutlet Properties
    @IBOutlet weak var imageViewContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notificationsButton: UIButton!
    
    // MARK: Properties
    var delegate: NotificationsProtocol?
    
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

    @IBAction func notificationsButtonTapped(_ sender: UIButton) {
        
        NotificationService.checkNotificationAccess { (access) in
            
            // If the user has access, then disable the button
            if access == nil || access == true {
                
                DispatchQueue.main.async {
                    self.notificationsButton.isEnabled = false
                    self.notificationsButton.setTitleColor(UIColor.white, for: .disabled)
                    self.notificationsButton.backgroundColor = Constants.Color.primary
                }
                
            }
            
            if access != nil {
                self.delegate?.notificationsTapped(access: access!)
            }
        }
        
    }
}
