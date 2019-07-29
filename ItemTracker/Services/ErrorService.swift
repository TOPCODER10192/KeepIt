//
//  ErrorService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-17.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import FirebaseAuth

final class ErrorService {
    
    static func firebaseAuthError(error: Error) -> String {
        
        // Cast the error as type NSError
        let error = error as NSError
        
        // Retrieve the error code and then switch between possible errors
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
                
            case .accountExistsWithDifferentCredential:
                return "This Account Already Exists With a Different Credential"
                
            case .appNotAuthorized:
                return "App is not Authorized"
                
            case .appNotVerified:
                return "App Could Not Be Verified By the Server"
                
            case .appVerificationUserInteractionFailure:
                return "App Verification Failure"
                
            case .emailAlreadyInUse:
                return "Email is Already Registered"
                
            case .wrongPassword:
                return "Incorrect Password"
                
            case .invalidEmail:
                return "Invalid Email Address"
                
            case .userNotFound:
                return "Email Not Registered"
                
            case .missingEmail:
                return "No Email Was Provided"
                
            case .networkError:
                return "No Internet Connection"
                
            case .userDisabled:
                return "This Account has Been Disabled"
                
            case .invalidSender:
                return "Sender email is invalid"
            case .weakPassword:
                return "Passwords Must Be 6 Characters Long"
                
            default:
                return "Unknown Error"
            } // End of Switch
            
        } // End of If
        
        return "Unknown Error"
    
    } // End of func

} // End of class
