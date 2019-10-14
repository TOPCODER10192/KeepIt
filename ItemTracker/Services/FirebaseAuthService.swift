//
//  FirebaseAuthService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-09-08.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    
    private static let firebaseAuth = Auth.auth()
    
    static func attemptUserLogin(email: String, password: String, completion: @escaping (Error?) -> Void) {
        
        // Attempt to sign the user in
        firebaseAuth.signIn(withEmail: email, password: password) { (dataResult, error) in
            
            // Check if there was an error
            guard error == nil else {
                completion(error)
                return
            }
            
            // Try to read all the users items
            FirestoreService.listItems(completion: { (error, items) in
                
                // Check if there was an error
                guard error == nil else {
                    completion(error)
                    return
                }
                
                // Write the items locally
                Stored.userItems = items
                
                for item in items {
                    LocalStorageService.createItem(item: item)
                }
                
                // Call the completion parameter
                completion(error)
            })
            
        }
        
    }
    
    static func attemptSignUp(email: String, password: String, completion: @escaping (Error?) -> Void) {
        
        // Attempt to sign the user up
        firebaseAuth.createUser(withEmail: email, password: password) { (dataResult, error) in
            
            // Check if there is an error
            guard error == nil else {
                completion(error)
                return
            }
            
            // Write the user into the database
            FirestoreService.writeUser(id: Auth.auth().currentUser!.uid, completion: { (error) in
                
                // Check if there is an error
                guard error == nil else {
                    completion(error)
                    return
                }
                
                // List the user as having 0 items
                Stored.userItems = []
                
                // Call the completion parameter
                completion(error)
                
            })
            
        }
        
    }
    
    static func attemptAnonymousSignUp(completion: @escaping (Error?) -> Void) {
        
        // Attempt to anonymously sign the user in
        firebaseAuth.signInAnonymously { (dataResult, error) in
            
            // Check if there was an error
            guard error == nil else {
                completion(error)
                return
            }
            
            // Attempt to write a document for the user
            FirestoreService.writeUser(id: dataResult!.user.uid, completion: { (error) in
                
                // Check if there was an error
                guard error == nil else {
                    completion(error)
                    return
                }
                
                // List the user as having 0 items
                Stored.userItems = []
                
                // Call the completion parameter
                completion(error)
                
            })
        }
        
    }
    
    static func attemptResetPassword(email: String, completion: @escaping (Error?) -> Void) {
        
        // Attempt to reset the users password with the provided email
        firebaseAuth.sendPasswordReset(withEmail: email) { (error) in
            
            // Call the completion parameter
            completion(error)
            
        }
        
    }
    
}
