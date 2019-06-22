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
    
    static func getUserProfile(userID: String, completion: @escaping (UserInfo?)  -> Void) {
        
        // Get a database reference
        let reference = Firestore.firestore().collection("Users").document(userID)
        
        // Attach a listener to the database
        reference.getDocument { (docSnapshot, error) in
            guard docSnapshot != nil, docSnapshot!.exists, error == nil else { return }
            
            // Get data from the snapshot, check that the data isn't nil
            let data = docSnapshot!.data()
            guard data != nil else { return }
            
            // Create an instance of the user info class
            var userInfo = UserInfo()
            
            // Get all the associated information
            userInfo.firstName = data![Constants.FIRST_NAME_KEY]! as? String
            userInfo.lastName = data![Constants.LAST_NAME_KEY]! as? String
            userInfo.email = data![Constants.EMAIL_KEY]! as? String
            
            completion(userInfo)
        }
        
    }
    
    static func createUserProfile(profile: UserInfo) {
        
        // Check that none of userID, email, first name and last name are nil
        guard profile.userID != nil && profile.email != nil && profile.firstName != nil && profile.lastName != nil else { return }
        
        // Get a reference to the document containing the users info
        let reference = Firestore.firestore().collection(Constants.USERS_KEY).document(profile.email!)
        
        // Collect the data that will be stored
        let dataToSave: [String: Any] = [Constants.USER_ID_KEY: profile.userID!,
                                         Constants.FIRST_NAME_KEY: profile.firstName!,
                                         Constants.LAST_NAME_KEY: profile.lastName!]
        
        // Send the data to the database
        reference.setData(dataToSave, completion: { (error) in
            
            // Exit if the data could not be set
            guard error != nil else { return }
            
        })
    }
    
}
