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
            
            static let auth    = "Auth"
            static let tabBar   = "TabBar"
            static let popups   = "Popups"
            static let settings = "Settings"
            
        }
        
        struct Segues {
            
            static let itemSelected = "ItemSelected"
            
        }
        
        struct VC {

            static let backgroundAuth = "BackgroundAuthVC"
            static let login          = "LoginVC"
            static let createAccount  = "CreateAccountVC"
            static let forgotPassword = "ForgotPasswordVC"
            
            static let tabBar         = "TabBarVC"
            static let selectedItem   = "SelectedItemVC"
            
            static let addItem        = "AddItemVC"
            static let updateLocation = "UpdateLocationVC"
            static let noLocation     = "LocationReminderVC"
            
            static let settings       = "SettingsVC"
            
        }
        
        struct Cell {
            
            static let item           = "ItemCell"
            static let addItem        = "AddItemCell"
            static let updateLocation = "UpdateLocationCell"
            
        }
        
        struct Annotation {
            
            static let item = "ItemAnnotation"
            static let user = "UserAnnotation"
            
        }
        
    }
    
    // MARK: - Views
    struct View {
        
        // MARK: - Corner Radius
        struct CornerRadius {
            
            static let standard: CGFloat = 15
            static let button: CGFloat   = 10
            
        }
        
        // MARK: - Width
        struct Width {
            
            static let standard: CGFloat   = min(420, UIScreen.main.bounds.width - 20)
            static let annotation: CGFloat = 40
            
        }
        
        // MARK: - Height
        struct Height {
            
            static let login: CGFloat          = min(240, UIScreen.main.bounds.height - 350)
            static let createAccount: CGFloat  = min(230, UIScreen.main.bounds.height - 350)
            static let addItem: CGFloat        = min(530, UIScreen.main.bounds.height - 40)
            static let annotation: CGFloat     = 40
            static let updateLocation: CGFloat = 150
            static let itemHeader: CGFloat     = 200
            
        }
        
        // MARK: - Y
        struct Y {
            
            static let error: CGFloat = UIScreen.main.bounds.height * 0.3
            
        }
        
    }
    
    // MARK: - Color
    struct Color {
        
        static let floatingView   = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 240/255)
        static let primary        = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 255/255)
        static let settings       = UIColor(red: 142/255, green: 142/255, blue: 147/255, alpha: 255/255)
        static let inactiveButton = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 120/255)
        
        
        static let success        = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 255/255)
        static let error          = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 255/255)
        
        static let softError      = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 140/255)
    
    }
    
    // MARK: - Error Handling Messages
    struct ErrorMessage {
        
        static let accountDisabled         = "This account has been disabled"
        static let emailAlreadyRegistered  = "This Email already in use"
        static let emailMissing            = "An Email must be provided"
        static let emailNotRegistered      = "This Email is not registered"
        static let invalidEmail            = "This Email has an invalid format"
        static let networkError            = "Unable to connect to the server"
        static let weakPassword            = "Password needs at least 6 characters"
        static let wrongPassword           = "Incorrect password"
        
    }
    
    // MARK: - Keys for database and local storage
    struct Key {
        
        struct User {
            
            static let users         = "Users"
            static let userID        = "User ID"
            static let firstName     = "First Name"
            static let lastName      = "Last Name"
            static let email         = "Email"
            
        }
        
        struct Item {
            
            static let items          = "Items"
            static let name           = "Item Name"
            static let movement       = "Is Moved Often"
            static let lastUpdateDate = "Last Updated"
            static let location       = "Location"
            static let imageURL       = "Image URL"
            
        }
    
    }
    
    struct Map {
    
        static let defaultSpan: MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
    }
    
}
