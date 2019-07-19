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

    @IBOutlet weak var notificationsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the button
        notificationsButton.layer.borderColor = Constants.Color.primary.cgColor
        notificationsButton.layer.borderWidth = 1
        
    }

    @IBAction func notificationsButtonTapped(_ sender: UIButton) {
        
        // Create a center for notifications
        let center = UNUserNotificationCenter.current()
        
        // Ask the user for notification authorization
        center.requestAuthorization(options: [.badge, .alert]) { (granted, error) in
            
            // If they deny then return
            guard error == nil else { return }
            
            // Create the notification content
            let content = UNMutableNotificationContent()
            content.title = "Time to update your item locations!"
            
            // Create the notification trigger
            let gregorian = Calendar(identifier: .gregorian)
            let now = Date()
            var components = gregorian.dateComponents([.hour, .minute, .second], from: now)
            
            components.hour = 20
            components.minute = 5
            components.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
            // Generate a request for the notification
            let request = UNNotificationRequest(identifier: "UpdateLocationsNotification", content: content, trigger: trigger)
            
            // Add a request to the notification center
            center.add(request, withCompletionHandler: { (error) in
                
                guard error == nil else { return }
                
            })
            
        }
        
        notificationsButton.setTitleColor(UIColor.white, for: .normal)
        notificationsButton.backgroundColor = Constants.Color.primary
        
    }
}
