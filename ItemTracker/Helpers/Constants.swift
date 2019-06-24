//
//  Constants.swift
//  ReconciliationApp
//
//  Created by Brock Chelle on 2019-05-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    
    // Storyboard Identifiers
    static let LOGIN_VCID           = "LoginVC"
    static let CREATE_ACCOUNT_VCID  = "CreateAccountVC"
    static let FORGOT_PASSWORD_VCID = "ForgotPasswordVC"
    static let ADD_ITEM_VCID        = "AddItemVC"
    
    // Segue Identifiers
    static let LOGGED_IN_SEGUE_ID       = "LoggedIn"
    static let ACCOUNT_CREATED_SEGUE_ID = "AccountCreated"
    
    // Corner radius
    static let GENERAL_CORNER_RADIUS: CGFloat          = 15
    static let BUTTON_CORNER_RADIUS: CGFloat           = 10
    
    // Authentication View Sizes
    static let LOGIN_VIEW_WIDTH: CGFloat  = min(400, UIScreen.main.bounds.width - 20)
    static let LOGIN_VIEW_HEIGHT: CGFloat = min(240, UIScreen.main.bounds.height - 350)
    
    static let CREATE_ACCOUNT_VIEW_WIDTH: CGFloat  = min(400, UIScreen.main.bounds.width - 20)
    static let CREATE_ACCOUNT_VIEW_HEIGHT: CGFloat = min(230, UIScreen.main.bounds.height - 350)
    
    static let FORGOT_PASSWORD_VIEW_WIDTH: CGFloat = min(400, UIScreen.main.bounds.width - 20)
    
    static let ADD_ITEM_VIEW_WIDTH: CGFloat  = min(400, UIScreen.main.bounds.width - 20)
    static let ADD_ITEM_VIEW_HEIGHT: CGFloat = 310
    
    static let ERROR_VIEW_Y: CGFloat = UIScreen.main.bounds.height * 0.3
    
    // MARK: - MapView Sizes
    static let REGION_IN_METERS: Double = 10000
    
    // Colors
    static let FLOATING_VIEW_COLOR   = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 204/255)
    static let PRIMARY_COLOR         = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 255/255)
    static let INACTIVE_BUTTON_COLOR = UIColor(red: 175/255, green: 82/255, blue: 222/255, alpha: 120/255)
    
    static let SUCCESS_COLOR         = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 255/255)
    static let ERROR_COLOR           = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 255/255)
    
    static let SOFT_SUCCESS_COLOR    = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 125/255)
    static let SOFT_ERROR_COLOR      = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 125/255)
    
    // MARK: Error Handling Messages
    static let ACCOUNT_DISABLED         = "This account has been disabled"
    static let EMAIL_ALREADY_REGISTERED = "This Email already in use"
    static let EMAIL_MISSING            = "An Email must be provided"
    static let EMAIL_NOT_REGISTERED     = "This Email is not registered"
    static let INVALID_EMAIL            = "This Email has an invalid format"
    static let NETWORK_ERROR            = "Unable to connect to the server"
    static let WEAK_PASSWORD            = "Password needs at least 6 characters"
    static let WRONG_PASSWORD           = "Incorrect password"
    
    // MARK: Database Keys
    static let USERS_KEY         = "Users"
    static let USER_ID_KEY       = "User ID"
    static let FIRST_NAME_KEY    = "First Name"
    static let LAST_NAME_KEY     = "Last Name"
    static let EMAIL_KEY         = "Email"
    static let ITEMS_KEY         = "Items"
    static let ITEM_NAME_KEY     = "Item Name"
    static let ITEM_MOVEMENT_KEY = "Is Moved Often"
    static let ITEM_LOCATION_KEY = "Location"
    
    // MARK: - Cell ID's
    static let ITEM_CELL_ID     = "ItemCell"
    static let ADD_ITEM_CELL_ID = "AddItemCell"
    
}
