//
//  LocalStorageService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-25.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation

final class LocalStorageService {
    
    static func saveCurrentUser(user: UserInfo, items: [Item]) {
        
        // Get standard user defaults
        let defaults = UserDefaults.standard
        
        // Store the users information locally
        defaults.set(user.firstName, forKey: Constants.Key.User.firstName)
        defaults.set(user.lastName, forKey: Constants.Key.User.lastName)
        defaults.set(user.email, forKey: Constants.Key.User.email)
        
        // Initialize array that will store item properties
        var itemNames           = [String]()
        var itemLocations       = [[Double]]()
        var itemLastUpdateDates = [String]()
        var itemMovements       = [Bool]()
        var itemImageURLs       = [String]()
        
        // Fill the arrays
        for item in items {
            itemNames.append(item.name)
            itemLocations.append(item.mostRecentLocation)
            itemLastUpdateDates.append(item.lastUpdateDate)
            itemMovements.append(item.isMovedOften)
            itemImageURLs.append(item.imageURL)
            
        }
        
        // Locally store the arrays
        defaults.set(itemNames, forKey: Constants.Key.Item.name)
        defaults.set(itemLocations, forKey: Constants.Key.Item.location)
        defaults.set(itemLastUpdateDates, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(itemMovements, forKey: Constants.Key.Item.movement)
        defaults.set(itemImageURLs, forKey: Constants.Key.Item.imageURL)
        
    }
    
    static func saveUserItem(item: Item, isNew: Bool, index: Int? = nil) {
        
        // Get standard user defaults
        let defaults = UserDefaults.standard
        
        // Pull all the current item arrays from loca
        var itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as! [String]
        var itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as! [[Double]]
        var itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as! [String]
        var itemMovements       = defaults.value(forKey: Constants.Key.Item.movement)       as! [Bool]
        var itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as! [String]
        
        // Append the new items propeties to the arrays
        if isNew == true {
            itemNames.append(item.name)
            itemLocations.append(item.mostRecentLocation)
            itemLastUpdateDates.append(item.lastUpdateDate)
            itemMovements.append(item.isMovedOften)
            itemImageURLs.append(item.imageURL)
        }
        else if isNew == false, let i = index {
            
            itemNames[i]           = item.name
            itemLocations[i]       = item.mostRecentLocation
            itemLastUpdateDates[i] = item.lastUpdateDate
            itemMovements[i]       = item.isMovedOften
            itemImageURLs[i]       = item.imageURL
            
        }
        
        // Locally store the arrays
        defaults.set(itemNames, forKey: Constants.Key.Item.name)
        defaults.set(itemLocations, forKey: Constants.Key.Item.location)
        defaults.set(itemLastUpdateDates, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(itemMovements, forKey: Constants.Key.Item.movement)
        defaults.set(itemImageURLs, forKey: Constants.Key.Item.imageURL)
        
    }
    
    static func loadCurrentUser() {
        
        // Get standard user defaults
        let defaults = UserDefaults.standard
        
        // Retrieve the users information from local storage
        let firstName = defaults.value(forKey: Constants.Key.User.firstName) as? String
        let lastName  = defaults.value(forKey: Constants.Key.User.lastName) as? String
        let email     = defaults.value(forKey: Constants.Key.User.email) as? String
        
        // Check that all properties are filled otherwise return nil
        guard firstName != nil && lastName != nil && email != nil else { return }
        
        // Create the user
        let user = UserInfo(firstName: firstName!, lastName: lastName!, email: email!)
        
        // Read in the arrays of item properties
        let itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as! [String]
        let itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as! [[Double]]
        let itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as! [String]
        let itemMovements       = defaults.value(forKey: Constants.Key.Item.movement)       as! [Bool]
        let itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as! [String]
        
        // Initialize an array for items
        var items = [Item]()
        
        for i in 0 ..< itemNames.count {
            // Pull the properties from each array
            let name           = itemNames[i]
            let location       = itemLocations[i]
            let lastUpdateDate = itemLastUpdateDates[i]
            let isMovedOften   = itemMovements[i]
            let imageURL       = itemImageURLs[i]
            
            // Create the item and append it to the array of userItems
            let item = Item.init(withName: name,
                                 withLocation: location,
                                 withLastUpdateDate: lastUpdateDate,
                                 withMovement: isMovedOften,
                                 withImageURL: imageURL)
            items.append(item)
            
        }
        
        Stored.user      = user
        Stored.userItems = items
        
        
    }
    
    static func clearCurrentUser() {
        
        // Get standard user defaults
        let defaults = UserDefaults.standard
        
        // Clear the users information
        defaults.set(nil, forKey: Constants.Key.User.firstName)
        defaults.set(nil, forKey: Constants.Key.User.lastName)
        defaults.set(nil, forKey: Constants.Key.User.email)
        
        // Locally clear the item arrays
        defaults.set(nil, forKey: Constants.Key.Item.name)
        defaults.set(nil, forKey: Constants.Key.Item.location)
        defaults.set(nil, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(nil, forKey: Constants.Key.Item.movement)
        defaults.set(nil, forKey: Constants.Key.Item.imageURL)
        
    }
}
