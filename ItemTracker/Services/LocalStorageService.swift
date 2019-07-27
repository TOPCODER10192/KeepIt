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
        defaults.set(user.id       , forKey: Constants.Key.User.id)
        defaults.set(user.firstName, forKey: Constants.Key.User.firstName)
        defaults.set(user.lastName , forKey: Constants.Key.User.lastName)
        defaults.set(user.email    , forKey: Constants.Key.User.email)
        
    }
    
    static func createItem(item: Item) {
        
        // Pull all the current item arrays from local storage
        var itemIDs             = defaults.value(forKey: Constants.Key.Item.id)             as? [String]   ?? [String]()
        var itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as? [String]   ?? [String]()
        var itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as? [[Double]] ?? [[Double]]()
        var itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as? [String]   ?? [String]()
        var itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as? [String]   ?? [String]()
        
        // Append the new item to the arrays
        itemIDs             += [item.id]
        itemNames           += [item.name]
        itemLocations       += [item.mostRecentLocation]
        itemLastUpdateDates += [item.lastUpdateDate]
        itemImageURLs       += [item.imageURL]
        
        // Locally store the updated arrays
        defaults.set(itemIDs,             forKey: Constants.Key.Item.id)
        defaults.set(itemNames,           forKey: Constants.Key.Item.name)
        defaults.set(itemLocations,       forKey: Constants.Key.Item.location)
        defaults.set(itemLastUpdateDates, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(itemImageURLs,       forKey: Constants.Key.Item.imageURL)
        
    }
    
    static func updateItem(item: Item, index: Int) {
        
        // Pull all the current item arrays from local storage
        var itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as? [String]   ?? [String]()
        var itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as? [[Double]] ?? [[Double]]()
        var itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as? [String]   ?? [String]()
        var itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as? [String]   ?? [String]()
        
        // Update the items properties
        itemNames[index]           = item.name
        itemLocations[index]       = item.mostRecentLocation
        itemLastUpdateDates[index] = item.lastUpdateDate
        itemImageURLs[index]       = item.imageURL
        
        // Locally store the updated arrays
        defaults.set(itemNames,           forKey: Constants.Key.Item.name)
        defaults.set(itemLocations,       forKey: Constants.Key.Item.location)
        defaults.set(itemLastUpdateDates, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(itemImageURLs,       forKey: Constants.Key.Item.imageURL)
        
    }
    
    static func createGeoFence(geoFence: GeoFence) {
        
        // Pull all the existing array from local storage
        var names         = defaults.value(forKey: Constants.Key.GeoFence.name)           as? [String]   ?? [String]()
        var centers       = defaults.value(forKey: Constants.Key.GeoFence.center)         as? [[Double]] ?? [[Double]]()
        var radii         = defaults.value(forKey: Constants.Key.GeoFence.radius)         as? [Double]   ?? [Double]()
        var entryTriggers = defaults.value(forKey: Constants.Key.GeoFence.triggerOnEntry) as? [Bool]     ?? [Bool]()
        var exitTriggers  = defaults.value(forKey: Constants.Key.GeoFence.triggerOnExit)  as? [Bool]     ?? [Bool]()
        var ids           = defaults.value(forKey: Constants.Key.GeoFence.id)             as? [String]   ?? [String]()
        
        // Append the new  geofence
        names         += [geoFence.name]
        centers       += [geoFence.centreCoordinate]
        radii         += [geoFence.radius]
        entryTriggers += [geoFence.triggerOnEntrance]
        exitTriggers  += [geoFence.triggerOnExit]
        ids           += [geoFence.id]
        
        // Place the arrays back in local storage
        defaults.set(names, forKey: Constants.Key.GeoFence.name)
        defaults.set(centers, forKey: Constants.Key.GeoFence.center)
        defaults.set(radii, forKey: Constants.Key.GeoFence.radius)
        defaults.set(entryTriggers, forKey: Constants.Key.GeoFence.triggerOnEntry)
        defaults.set(exitTriggers, forKey: Constants.Key.GeoFence.triggerOnExit)
        defaults.set(ids, forKey: Constants.Key.GeoFence.id)
        
    }
    
    // MARK: - Read Methods
    static func getUser() {
        
        // Retrieve the users information from local storage
        let userID    = defaults.value(forKey: Constants.Key.User.id)        as? String
        let firstName = defaults.value(forKey: Constants.Key.User.firstName) as? String
        let lastName  = defaults.value(forKey: Constants.Key.User.lastName)  as? String
        let email     = defaults.value(forKey: Constants.Key.User.email)     as? String
        
        // Check that all properties are filled otherwise return nil
        guard userID != nil, firstName != nil && lastName != nil && email != nil else { return }
        
        // Create the user
        let user         = UserInfo(id: userID!, firstName: firstName!, lastName: lastName!, email: email!)
        Stored.user      = user
        
    }
    
    static func listItems() {
        
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
            let item = Item(withID: id,
                            withName: name,
                            withLocation: location,
                            withLastUpdateDate: lastUpdateDate,
                            withImageURL: imageURL)
            
            items.append(item)
            
        }
        
        // Store the user and their items in a variable
        Stored.userItems = items
        
    }
    
    static func listGeoFences() {
        
        // Pull all the existing array from local storage
        var names         = defaults.value(forKey: Constants.Key.GeoFence.name)           as? [String]   ?? [String]()
        var centers       = defaults.value(forKey: Constants.Key.GeoFence.center)         as? [[Double]] ?? [[Double]]()
        var radii         = defaults.value(forKey: Constants.Key.GeoFence.radius)         as? [Double]   ?? [Double]()
        var entryTriggers = defaults.value(forKey: Constants.Key.GeoFence.triggerOnEntry) as? [Bool]     ?? [Bool]()
        var exitTriggers  = defaults.value(forKey: Constants.Key.GeoFence.triggerOnExit)  as? [Bool]     ?? [Bool]()
        var ids           = defaults.value(forKey: Constants.Key.GeoFence.id)             as? [String]   ?? [String]()
        
        var geoFences = [GeoFence]()
        
        // Iterate through the arrays
        for i in 0 ..< names.count {
            
            // Append a geofence
            geoFences.append(GeoFence(name: names[i],
                                      centreCoordinate: centers[i],
                                      radius: radii[i],
                                      triggerOnEntrance: entryTriggers[i],
                                      triggerOnExit: exitTriggers[i],
                                      id: ids[i]))
            
        }
        
        // Store it in the stored variables
        Stored.geoFences = geoFences
        
    }
    
    
    // MARK: - Deletion Methods
    static func deleteItem(index: Int) {
        
        // Pull all the current item arrays from local storage
        var itemIDs             = defaults.value(forKey: Constants.Key.Item.id)             as! [String]
        var itemNames           = defaults.value(forKey: Constants.Key.Item.name)           as! [String]
        var itemLocations       = defaults.value(forKey: Constants.Key.Item.location)       as! [[Double]]
        var itemLastUpdateDates = defaults.value(forKey: Constants.Key.Item.lastUpdateDate) as! [String]
        var itemImageURLs       = defaults.value(forKey: Constants.Key.Item.imageURL)       as! [String]
        
        // Remove the items properties
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
    
    static func deleteGeoFence(index: Int) {
        
        // Pull all the existing array from local storage
        var names         = defaults.value(forKey: Constants.Key.GeoFence.name)           as? [String]   ?? [String]()
        var centers       = defaults.value(forKey: Constants.Key.GeoFence.center)         as? [[Double]] ?? [[Double]]()
        var radii         = defaults.value(forKey: Constants.Key.GeoFence.radius)         as? [Double]   ?? [Double]()
        var entryTriggers = defaults.value(forKey: Constants.Key.GeoFence.triggerOnEntry) as? [Bool]     ?? [Bool]()
        var exitTriggers  = defaults.value(forKey: Constants.Key.GeoFence.triggerOnExit)  as? [Bool]     ?? [Bool]()
        var ids           = defaults.value(forKey: Constants.Key.GeoFence.id)             as? [String]   ?? [String]()
        
        names.remove(at: index)
        centers.remove(at: index)
        radii.remove(at: index)
        entryTriggers.remove(at: index)
        exitTriggers.remove(at: index)
        ids.remove(at: index)
        
        // Place the arrays back in local storage
        defaults.set(names, forKey: Constants.Key.GeoFence.name)
        defaults.set(centers, forKey: Constants.Key.GeoFence.center)
        defaults.set(radii, forKey: Constants.Key.GeoFence.radius)
        defaults.set(entryTriggers, forKey: Constants.Key.GeoFence.triggerOnEntry)
        defaults.set(exitTriggers, forKey: Constants.Key.GeoFence.triggerOnExit)
        defaults.set(ids, forKey: Constants.Key.GeoFence.id)
        
    }
    
    static func clearUser() {
        
        // Clear the users information
        defaults.set(nil, forKey: Constants.Key.User.id)
        defaults.set(nil, forKey: Constants.Key.User.firstName)
        defaults.set(nil, forKey: Constants.Key.User.lastName)
        defaults.set(nil, forKey: Constants.Key.User.email)
        
        // Clear the item arrays
        defaults.set(nil, forKey: Constants.Key.Item.id)
        defaults.set(nil, forKey: Constants.Key.Item.name)
        defaults.set(nil, forKey: Constants.Key.Item.location)
        defaults.set(nil, forKey: Constants.Key.Item.lastUpdateDate)
        defaults.set(nil, forKey: Constants.Key.Item.imageURL)
        
    }
}
