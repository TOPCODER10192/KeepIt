//
//  NotificationService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-23.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import UserNotifications
import CoreLocation

final class NotificationService {
    
    private static let center = UNUserNotificationCenter.current()
    
    static func createTimedNotification(weekday: Int? = nil, hour: Int, minute: Int, repeats: Bool) {
        
        // Ask the user for notification authorization
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            
            // If they deny then return
            guard error == nil else { return }
            
            // Create the notification content
            let content = UNMutableNotificationContent()
            content.sound = UNNotificationSound.default
            content.title = "Time to update your item locations!"
            
            // Create the notification trigger
            let gregorian = Calendar(identifier: .gregorian)
            let now = Date()
            
            // Create the date components
            var components = gregorian.dateComponents([.weekday, .hour, .minute, .second], from: now)
            
            // Set the date components
            components.weekday = weekday
            components.hour = hour
            components.minute = minute
            components.second = 0
            
            // Create a trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: repeats)
            
            // Generate a request for the notification
            let request = UNNotificationRequest(identifier: Constants.ID.Notification.timed, content: content, trigger: trigger)
            
            // Add a request to the notification center
            center.add(request, withCompletionHandler: { (error) in
                
                guard error == nil else { return }
                
            })
            
        }
        
    }
    
    static func removeTimedNotification() {
        
        // Remove the timed notification
        center.removePendingNotificationRequests(withIdentifiers: [Constants.ID.Notification.timed])
        
    }
    
    static func createLocationNotification(message: String) {
        
        // Create the notification content
        let content   = UNMutableNotificationContent()
        content.sound = UNNotificationSound.default
        content.title = message
        
        // Create a trigger for the notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: Constants.ID.Notification.location, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            
            guard error == nil else { return }
            
        }
        
    }
    
}
