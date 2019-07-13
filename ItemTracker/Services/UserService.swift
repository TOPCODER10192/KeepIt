//
//  UserService.swift
//  ReconciliationApp
//
//  Created by Brock Chelle on 2019-05-28.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import Firebase

final class UserService {
    
    private static let db = Firestore.firestore()
    
    static func readUserProfile(email: String, completion: @escaping (Error?, UserInfo?, [Item]?)  -> Void) {
        
        // Get a reference to the users information
        let userDocRef = db.collection(Constants.Key.User.users).document(email)
        
        // Fetch the document
        userDocRef.getDocument { (document, error) in
            guard document != nil && document!.exists && error == nil else {
                completion(error, nil, nil)
                return
            }
            
            // Get data from the snapshot, check that the data isn't nil
            let userData = document!.data()
            guard userData != nil else { return }
            
            // Get all the associated information
            let firstName = userData![Constants.Key.User.firstName]! as! String
            let lastName  = userData![Constants.Key.User.lastName]! as! String
            
            let user = UserInfo(firstName: firstName, lastName: lastName, email: email)
            LocalStorageService.writeUser(user: user)
            
            // Get a reference to the users items
            userDocRef.collection(Constants.Key.Item.items).getDocuments(completion: { (query, error) in
                
                // Check that the documents were succcessfully read
                guard query != nil && error == nil else {
                    completion(error, user, nil)
                    return
                }
                
                // Get all the documents that were obtained
                let documents = query!.documents
                var items = [Item]()
                
                // Iterate through all the documents
                for document in documents {
                    
                    // Get the data from the document
                    let itemData = document.data()
                    
                    let id             = document.documentID
                    let name           = itemData[Constants.Key.Item.name]           as! String
                    let location       = itemData[Constants.Key.Item.location]       as! [Double]
                    let lastUpdateDate = itemData[Constants.Key.Item.lastUpdateDate] as! String
                    let url            = itemData[Constants.Key.Item.imageURL]       as! String
                    
                    let item = Item.init(withID: id,
                                         withName: name,
                                         withLocation: location,
                                         withLastUpdateDate: lastUpdateDate,
                                         withImageURL: url)
                    
                    items.append(item)
                    
                }
                
                completion(nil, user, items)
                
            })
            
        }
        
    }
    
    static func writeUserProfile(user: UserInfo, completion: @escaping (Error?) -> Void) {
        
        // Get a reference to the document containing the users info
        let userInfoRef  = db.collection(Constants.Key.User.users).document(user.email)
        
        // Send the data to the database
        userInfoRef.setData([Constants.Key.User.firstName: user.firstName,
                             Constants.Key.User.lastName: user.lastName],
                            completion: { (error) in
            
            completion(error)
            
        })

    }
    
    static func writeItem(item: Item, isNew: Bool, completion: ((String) -> Void)?) {
        
        let itemsRef = db.collection(Constants.Key.User.users).document(Stored.user!.email).collection(Constants.Key.Item.items)
        
        let name            = item.name
        let location        = item.mostRecentLocation
        let url             = item.imageURL
        let lastTimeUpdated = item.lastUpdateDate
        
        if isNew == true {
            let itemRef = itemsRef.addDocument(data: [Constants.Key.Item.name          : name,
                                                      Constants.Key.Item.location      : location,
                                                      Constants.Key.Item.imageURL      : url,
                                                      Constants.Key.Item.lastUpdateDate: lastTimeUpdated])
            
            completion!(itemRef.documentID)
        }
        else {
            itemsRef.document(item.id).setData([Constants.Key.Item.name          : name,
                                                Constants.Key.Item.location      : location,
                                                Constants.Key.Item.imageURL      : url,
                                                Constants.Key.Item.lastUpdateDate: lastTimeUpdated])
            
            completion!(item.id)
        }
        
    }
    
    static func removeItem(item: Item) {
        
        let itemRef =
            db.collection(Constants.Key.User.users).document(Stored.user!.email).collection(Constants.Key.Item.items).document(item.id)
        
        itemRef.delete()
        
    }
    
}
