//
//  AppDelegate.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-20.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        FirebaseApp.configure()

        // Attempt to load the current user
        LocalStorageService.getUser()
        
        // Check if a user exists in local storage
        if Stored.user != nil {
            
            LocalStorageService.listItems()
            LocalStorageService.listGeoFences()
            
            // Create the Tab Bar Controller
            let tabBarVC = UIStoryboard(name: Constants.ID.Storyboard.tabBar, bundle: .main).instantiateViewController(withIdentifier: Constants.ID.VC.tabBar) as! UITabBarController
            
            // Set the tint color of the tab bar
            tabBarVC.tabBar.tintColor = Constants.Color.primary
            
            // Present the Tab Bar Controller
            window?.rootViewController = tabBarVC
            window?.makeKeyAndVisible()
            
        }
        
        locationManager.delegate = self
        
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { success, error in
                if let error = error {
                    print("Error: \(error)")
                }
        }

        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        application.applicationIconBadgeNumber = 0
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    
    func handleEvent(for region: CLRegion!) {
        
        // Otherwise present a local notification
        guard let body = note(from: region.identifier) else { return }
        let notificationContent = UNMutableNotificationContent()
        notificationContent.body = body
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "location_change",
                                            content: notificationContent,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
        
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            handleEvent(for: region)
        }
        
    }
    
    func note(from identifier: String) -> String? {
        
        return "You've crossed a geofence"
        
    }
}

