//
//  UserService.swift
//  ReconciliationApp
//
//  Created by Brock Chelle on 2019-05-28.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class FirestoreService {
    
    private static let firebaseAuth = Auth.auth()
    private static let db = Firestore.firestore()
    
    // MARK: - Read Methods
    static func getUser(userID: String, completion: @escaping (Error?, UserInfo?) -> Void) {
        
        // Get a reference to the users document
        let userDocRef = db.collection(Constants.Key.User.users).document(userID)
        
        // Attempt to read the user document
        userDocRef.getDocument
        { (document, error) in
           
            // Check that the document was fetched without any errors
            guard document != nil, document!.exists, error == nil else {
                completion(error, nil)
                return
            }
            
            // Fetch the data from the document and check that it isn't nil
            let data = document!.data()
            guard data != nil else { return }
            
            // Pull the users information from the document
            let user = UserInfo(id       : document!.documentID                           ,
                                firstName: data![Constants.Key.User.firstName]! as! String,
                                lastName : data![Constants.Key.User.lastName]!  as! String,
                                email    : data![Constants.Key.User.email]!     as! String)
            
            // Call the Completion handler with no error and the user
            completion(nil, user)
            
        }
        
    }
    
    static func listItems(completion: @escaping (Error?, [Item]?) -> Void) {
        
        // Get a reference to the items collection
        let itemsRef = db.collection(Constants.Key.User.users)
                        .document(Stored.user!.id)
                        .collection(Constants.Key.Item.items)
        
        // Attempt to get all the documents in the users item collection
        itemsRef.getDocuments
        { (query, error) in
            
            // Check to see if all the documents were obtained without an error
            guard error == nil, query != nil else {
                completion(error, nil)
                return
            }
            
            // Create an empty array of items
            var items = [Item]()
            
            // Obtain all the documents that were found
            let documents = query!.documents
            
            // Iterate through all the documents
            for document in documents {
                
                // Get the data for the current document
                let data = document.data()
                
                // Append the data to the array of items
                items.append(Item(withID            : document.documentID,
                                  withName          : data[Constants.Key.Item.name]           as! String,
                                  withLocation      : data[Constants.Key.Item.location]       as! [Double],
                                  withLastUpdateDate: data[Constants.Key.Item.lastUpdateDate] as! String,
                                  withImageURL      : data[Constants.Key.Item.imageURL]       as! String))
                
            }
            
            completion(nil, items)
            
        }
        
    }
    
    // MARK: - Write Methods
    static func writeUser(user: UserInfo, completion: @escaping (Error?) -> Void) {
        
        // Get a reference to the document that the user will be written to
        let userDocRef = db.collection(Constants.Key.User.users).document(user.id)
        
        // Attempt to send the data to firestore
        userDocRef.setData([Constants.Key.User.firstName: user.firstName,
                            Constants.Key.User.lastName : user.lastName ,
                            Constants.Key.User.email    : user.email     ])
        { (error) in
            
            // Call the completion parameter with the error as the parameter
            completion(error)
                                
        }
        
    }
    
    static func createItem(item: Item, completion: @escaping (String, Error?) -> Void) {
        
        // Get a reference to where the document will be written
        let itemRef = db.collection(Constants.Key.User.users)
                        .document(Stored.user!.id)
                        .collection(Constants.Key.Item.items)
                        .document()
        
        // Attempt to send the data to firestore
        itemRef.setData([Constants.Key.Item.name          : item.name,
                         Constants.Key.Item.location      : item.mostRecentLocation,
                         Constants.Key.Item.imageURL      : item.imageURL,
                         Constants.Key.Item.lastUpdateDate: item.lastUpdateDate])
        { (error) in
            
            // Call the completion handler with the document id and the error
            completion(itemRef.documentID, error)
            
        }
        
    }
    
    static func updateItem(item: Item, completion: @escaping (Error?) -> Void) {
        
        // Get a reference to the items path in firestore
        let itemRef = db.collection(Constants.Key.User.users)
                         .document(Stored.user!.id)
                         .collection(Constants.Key.Item.items)
                         .document(item.id)
        
        // Attempt to send the data to firestore
        itemRef.setData([Constants.Key.Item.name          : item.name,
                         Constants.Key.Item.location      : item.mostRecentLocation,
                         Constants.Key.Item.imageURL      : item.imageURL,
                         Constants.Key.Item.lastUpdateDate: item.lastUpdateDate   ])
        { (error) in
            
            // Call the completion handler with the error
            completion(error)
            
        }
        
    }
    
    static func deleteItem(item: Item, completion: @escaping (Error?) -> Void) {
        
        // Get a reference to the items path in firestore
        let itemDocRef = db.collection(Constants.Key.User.users)
                        .document(Stored.user!.id)
                        .collection(Constants.Key.Item.items)
                        .document(item.id)
        
        // Attempt to delete the item from firestore
        itemDocRef.delete
        { (error) in
            
            // Call the completion handler with the error
            completion(error)
        
        }
        
    }
    
    static func deleteUser(password: String, completion: @escaping (Error?) -> Void) {
        
        // Get the curren user and check that it is not nil
        guard let user = firebaseAuth.currentUser else { return }
        
        // Get the current users email and check that it isn't nil
        guard let email = user.email else { return }
        
        // Create a credential from the users email and the password they typed in
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        // Reauthenticate the user
        user.reauthenticate(with: credential, completion: { (authResult, error) in
            
            // Check if the authentication is successful
            guard authResult != nil, error == nil else {
                completion(error)
                return
            }
            
            // Attempt to delete all the users images
            for item in Stored.userItems {
                if URL(string: item.imageURL) != nil {
                    ImageService.deleteImage(itemName: item.name)
                }
            }
            
            // Get a reference to the path containg the user in firestore
            let userDocRef = db.collection(Constants.Key.User.users).document(Stored.user!.id)
            
            // Attempt to delete the user from the firestore page
            userDocRef.delete(completion: { (error) in
                
                // Check if there were any errors
                guard error == nil else {
                    completion(error)
                    return
                }
                
                // Attempt to delete the users account
                user.delete(completion: { (error) in
                    
                    // Check if there is an error
                    guard error == nil else {
                        completion(error)
                        return
                    }
                    
                    completion(nil)
                    
                })
                
            })
            
        })
        
    }
    
}
