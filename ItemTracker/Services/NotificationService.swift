//
//  NotificationService.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-23.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationService {
    
    private static let center = UNUserNotificationCenter.current()
    
    static func createTimedNotification(weekday: Int? = 0, hour: Int, minute: Int, repeats: Bool) {
        
        // Ask the user for notification authorization
        center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            
            // If they deny then return
            guard error == nil, granted == true else { return }
            
            // Create the notification content
            let content = UNMutableNotificationContent()
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
            let request = UNNotificationRequest(identifier: "CalendarNotification", content: content, trigger: trigger)
            
            // Add a request to the notification center
            center.add(request, withCompletionHandler: { (error) in
                
                guard error == nil else { return }
                
            })
            
        }
        
    }
    
    static func checkNotificationAccess(closure: @escaping (Bool?) -> Void) {
        
        // Get the users notification settings
        center.getNotificationSettings { (settings) in
            
            switch settings.authorizationStatus {
                
            case .authorized:
                closure(true)
                
            case .denied:
                closure(false)
                
            case .notDetermined:
                createTimedNotification(hour: 20, minute: 0, repeats: true)
                closure(nil)
                
            case .provisional:
                break
                
            @unknown default:
                return
            }
            
            return
            
        }
    }
}
