//
//  UserService.swift
//  ReconciliationApp
//
//  Created by Brock Chelle on 2019-05-28.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import Firebase

class UserService {
    
    static func readUserProfile(email: String, completion: @escaping ()  -> Void) {
        
        // Get a reference to the users information
        let userDocRef = Firestore.firestore().collection(Constants.Key.User.users).document(email)
        
        // Fetch the document
        userDocRef.getDocument { (document, error) in
            guard document != nil && document!.exists && error == nil else { return }
            
            // Get data from the snapshot, check that the data isn't nil
            let userData = document!.data()
            guard userData != nil else { return }
            
            // Get all the associated information
            let firstName = userData![Constants.Key.User.firstName]! as! String
            let lastName  = userData![Constants.Key.User.lastName]! as! String
            
            // Get a reference to the users items
            userDocRef.collection(Constants.Key.Item.items).getDocuments(completion: { (query, error) in
                
                // Check that the documents were succcessfully read
                guard query != nil && error == nil else { return }
                
                // Get all the documents that were obtained
                let documents = query!.documents
                var items = [Item]()
                
                // Iterate through all the documents
                for document in documents {
                    
                    // Get the data from the document
                    let itemData = document.data()
                    
                    let name     = itemData[Constants.Key.Item.name]     as! String
                    let location = itemData[Constants.Key.Item.location] as! [Double]
                    let movement = itemData[Constants.Key.Item.movement] as! Bool
                    let url      = itemData[Constants.Key.Item.imageURL] as? String
                    
                    let item = Item(name: name, mostRecentLocation: location, isMovedOften: movement, image: nil)
                    items.append(item)
                    
                }
                
                let user = UserInfo(firstName: firstName, lastName: lastName, email: email)
                LocalStorageService.saveCurrentUser(user: user, items: items)
                
                Stored.user = user
                Stored.userItems = items
                
                completion()
                
            })
            
        }
        
    }
    
    static func writeUserProfile(user: UserInfo, items: [Item]) {
        
        // Get a reference to the document containing the users info
        let userInfoRef  = Firestore.firestore().collection(Constants.Key.User.users).document(user.email)
        
        // Collect the data that will be stored
        let dataToSave: [String: Any] = [Constants.Key.User.firstName: user.firstName,
                                         Constants.Key.User.lastName: user.lastName]
        
        // Send the data to the database
        userInfoRef.setData(dataToSave, completion: { (error) in
            
            // Exit if the data could not be set
            guard error != nil else { return }
            
            // Get a reference to the items collection
            let userItemsRef = userInfoRef.collection(Constants.Key.Item.items)
            
            // Then attempt to write the users items
            for item in items {
                writeItem(item: item, ref: userItemsRef.document(item.name))
            }
            
        })

    }
    
    static func writeItem(item: Item, ref: DocumentReference) {
        
        let location     = item.mostRecentLocation
        let isMovedOften = item.isMovedOften
        let url          = item.image
        
        ref.setData([Constants.Key.Item.location: location,
                     Constants.Key.Item.movement: isMovedOften,
                     Constants.Key.Item.imageURL: url])
        
    }
    
}
