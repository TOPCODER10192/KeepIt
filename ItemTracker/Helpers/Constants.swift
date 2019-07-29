//
//  Constants.swift
//  ReconciliationApp
//
//  Created by Brock Chelle on 2019-05-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import UIKit
import MapKit

struct Constants {
    
    struct ID {
        
        struct Storyboard {
            
            static let auth     = "Auth"
            static let tabBar   = "TabBar"
            static let popups   = "Popups"
            static let settings = "Settings"
            
        }
        
        struct Segues {

            static let deleteAccount = "DeleteAccountSegue"
            
        }
        
        struct VC {

            static let backgroundAuth = "BackgroundAuthVC"
            static let login          = "LoginVC"
            static let createAccount  = "CreateAccountVC"
            static let forgotPassword = "ForgotPasswordVC"
            
            static let tabBar         = "TabBarVC"
            
            static let welcome        = "WelcomeVC"
            static let singleItem     = "SingleItemVC"
            static let updateLocation = "UpdateLocationVC"
            static let addGeoFence     = "AddGeoFenceVC"
            
            static let settings       = "SettingsVC"
            
        }
        
        struct Cell {
            
            static let welcomeLocations     = "LocationsCell"
            static let welcomeNotifications = "NotificationsCell"
            
            static let item                 = "ItemCell"
            static let addItem              = "AddItemCell"
            static let updateLocation       = "UpdateLocationCell"
            
            static let settingsRow          = "SettingsRowCell"
            static let geoFence             = "GeoFenceCell"
            
        }
        
        struct Nib {
            
            static let welcomeLocations     = "LocationsCollectionViewCell"
            static let welcomeNotifications = "NotificationsCollectionViewCell"
            static let settingsBody         = "SettingsBodyTableViewCell"
            
        }
        
        struct Annotation {
            
            static let item = "ItemAnnotation"
            static let user = "UserAnnotation"
            
        }
        
        struct Notification {
            
            static let timed = "TimedNotification"
            static let location = "LocationNotification"
            
        }
        
    }
    
    // MARK: - Views
    struct View {
        
        // MARK: - Width
        struct Width {
            
            static let standard: CGFloat   = min(450, UIScreen.main.bounds.width - 20)
            static let annotation: CGFloat = 40
            
        }
        
        // MARK: - Height
        struct Height {
            
            static let login: CGFloat          = min(240, UIScreen.main.bounds.height - 350)
            static let createAccount: CGFloat  = min(230, UIScreen.main.bounds.height - 350)
            static let forgotPassword: CGFloat = 200
            static let singleItem: CGFloat     = min(700, UIScreen.main.bounds.height - 60)
            static let annotation: CGFloat     = 40
            static let updateLocation: CGFloat = 150
            static let itemHeader: CGFloat     = 200
            static let addGeoFence: CGFloat     = min(700, UIScreen.main.bounds.height - 60)
            
        }
        
    }
    
    // MARK: - Color
    struct Color {
        
        static let notificationView = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 255/255)
        static let primary          = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 255/255)
        static let softPrimary      = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 120/255)
        
        static let inactiveButton   = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 255/255)
        static let deleteButton     = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 255/255)
    
    }
    
    // MARK: - Keys for database and local storage
    struct Key {
        
        struct User {
            
            static let users     = "users"
            static let id        = "userID"
            static let firstName = "firstName"
            static let lastName  = "lastName"
            static let email     = "email"
            
        }
        
        struct Item {
            
            static let items          = "items"
            static let id             = "itemID"
            static let name           = "itemName"
            static let lastUpdateDate = "itemLastUpdated"
            static let location       = "itemLocation"
            static let imageURL       = "imageURL"
            
        }
        
        struct GeoFence {
            
            static let id             = "fenceID"
            static let name           = "fenceName"
            static let center         = "fenceCenter"
            static let radius         = "fenceRadius"
            static let triggerOnEntry = "fenceTriggerOnEntry"
            static let triggerOnExit  = "fenceTriggerOnExit"
            
        }
        
        static let firstLaunch = "isFirstLaunch"
        static let firstLogin  = "isFirstLogin"
    
    }
    
    struct Map {
    
        static let defaultSpan: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
    }
    
    struct Email {
        
        static let support = "BrockLChelle@gmail.com"
        
    }
    
}
