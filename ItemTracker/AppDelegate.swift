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
        
        // Setup Firebase
        FirebaseApp.configure()
        
        // Setup AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // Check if a user exists in local storage
        if Auth.auth().currentUser != nil {
            
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
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: CLLocationManagerDelegate {
    
    func handleEvent(for region: CLRegion!, entered: Bool) {
        
        // Check if the user is signed in
        guard Auth.auth().currentUser != nil else { return }
        
        for geoFence in Stored.geoFences {
            
            if region.identifier == geoFence.id {
                
                var message: String
                
                // Create a customized message based on if they entered or left the geofence
                if entered == true {
                    message = "You're at \(geoFence.name), note the items you brought"
                }
                else {
                    message = "You've left \(geoFence.name), note the items you brought"
                }
                
                // Pop up a notification telling the user that they crossed a geofence
                NotificationService.createLocationNotification(message: message)
                
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            
            handleEvent(for: region, entered: true)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if region is CLCircularRegion {
            
            handleEvent(for: region, entered: false)
            
        }
        
    }
    
}
