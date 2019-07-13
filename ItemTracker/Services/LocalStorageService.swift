//
//  LocalStorageService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-25.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation

final class LocalStorageService {
    
    // Get standard user defaults
    private static let defaults = UserDefaults.standard
    
    // MARK: - Write Methods
    static func writeUser(user: UserInfo) {
        
        // Store the users information locally
        defaults.set(user.firstName, forKey: Constants.Key.User.firstName)
        defaults.set(user.lastName, forKey: Constants.Key.User.lastName)
        defaults.set(user.email, forKey: Constants.Key.User.email)
        
    }
    
    static func writeItem(item: Item, isNew: Bool, index: Int? = nil) {
        
        // Pull all the current item arrays from local storage
        var itemIDs             = defaults.value(forKey: Constants.Key.Item.id)             as? [String]   ?? [String]()
        var itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as? [String]   ?? [String]()
        var itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as? [[Double]] ?? [[Double]]()
        var itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as? [String]   ?? [String]()
        var itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as? [String]   ?? [String]()
        
        // Append the new items propeties to the arrays
        if isNew == true {
            itemIDs             += [item.id]
            itemNames           += [item.name]
            itemLocations       += [item.mostRecentLocation]
            itemLastUpdateDates += [item.lastUpdateDate]
            itemImageURLs       += [item.imageURL]
        }
        else if isNew == false, let i = index {
            
            itemIDs[i]             = item.id
            itemNames[i]           = item.name
            itemLocations[i]       = item.mostRecentLocation
            itemLastUpdateDates[i] = item.lastUpdateDate
            itemImageURLs[i]       = item.imageURL
            
        }
        
        // Locally store the updated arrays
        defaults.set(itemIDs,             forKey: Constants.Key.Item.id)
        defaults.set(itemNames,           forKey: Constants.Key.Item.name)
        defaults.set(itemLocations,       forKey: Constants.Key.Item.location)
        defaults.set(itemLastUpdateDates, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(itemImageURLs,       forKey: Constants.Key.Item.imageURL)
        
    }
    
    // MARK: - Read Methods
    static func readUser() {
        
        // Retrieve the users information from local storage
        let firstName = defaults.value(forKey: Constants.Key.User.firstName) as? String
        let lastName  = defaults.value(forKey: Constants.Key.User.lastName) as? String
        let email     = defaults.value(forKey: Constants.Key.User.email) as? String
        
        // Check that all properties are filled otherwise return nil
        guard firstName != nil && lastName != nil && email != nil else { return }
        
        // Create the user
        let user = UserInfo(firstName: firstName!, lastName: lastName!, email: email!)
        
        // Read in the arrays of item properties
        let itemIDs             = defaults.value(forKey: Constants.Key.Item.id)             as? [String]   ?? [String]()
        let itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as? [String]   ?? [String]()
        let itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as? [[Double]] ?? [[Double]]()
        let itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as? [String]   ?? [String]()
        let itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as? [String]   ?? [String]()
        
        // Initialize an array for items
        var items = [Item]()
        
        for i in 0 ..< itemNames.count {
            
            // Pull the properties from each array
            let id             = itemIDs[i]
            let name           = itemNames[i]
            let location       = itemLocations[i]
            let lastUpdateDate = itemLastUpdateDates[i]
            let imageURL       = itemImageURLs[i]
            
            // Create the item and append it to the array of userItems
            let item = Item.init(withID: id,
                                 withName: name,
                                 withLocation: location,
                                 withLastUpdateDate: lastUpdateDate,
                                 withImageURL: imageURL)
            
            items.append(item)
            
        }
        
        Stored.user      = user
        Stored.userItems = items
        
    }
    
    
    // MARK: - Deletion Methods
    static func deleteUserItem(index: Int) {
        
        // Pull all the current item arrays from local storage
        var itemIDs             = defaults.value(forKey: Constants.Key.Item.id)             as! [String]
        var itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as! [String]
        var itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as! [[Double]]
        var itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as! [String]
        var itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as! [String]
        
        // Remove the item
        itemIDs.remove(at: index)
        itemNames.remove(at: index)
        itemLocations.remove(at: index)
        itemLastUpdateDates.remove(at: index)
        itemImageURLs.remove(at: index)
        
        // Locally store the arrays
        defaults.set(itemIDs,             forKey: Constants.Key.Item.id)
        defaults.set(itemNames,           forKey: Constants.Key.Item.name)
        defaults.set(itemLocations,       forKey: Constants.Key.Item.location)
        defaults.set(itemLastUpdateDates, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(itemImageURLs,       forKey: Constants.Key.Item.imageURL)
        
    }
    
    static func deleteAllInfo() {
        
        // Clear the users information
        defaults.set(nil, forKey: Constants.Key.User.firstName)
        defaults.set(nil, forKey: Constants.Key.User.lastName)
        defaults.set(nil, forKey: Constants.Key.User.email)
        
        // Clear the item arrays
        defaults.set(nil, forKey: Constants.Key.Item.name)
        defaults.set(nil, forKey: Constants.Key.Item.name)
        defaults.set(nil, forKey: Constants.Key.Item.location)
        defaults.set(nil, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(nil, forKey: Constants.Key.Item.imageURL)
        
    }
}
