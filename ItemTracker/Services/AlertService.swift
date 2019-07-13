//
//  ErrorService.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-12.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import FirebaseAuth

class AlertService {
    
    static func createErrorAlert(error: NSError) -> UIAlertController {
        
        var alertTitle = "Something went Wrong"
        
        // Retrieve the error code and then switch between possible errors
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            switch errorCode {
            
            case .accountExistsWithDifferentCredential:
                alertTitle = "This Account Already Exists With a Different Credential"
                
            case .appNotAuthorized:
                alertTitle = "App is not Authorized"
                
            case .appNotVerified:
                alertTitle = "App Could Not Be Verified By the Server"
                
            case .appVerificationUserInteractionFailure:
                alertTitle = "App Verification Failure"
                
            case .emailAlreadyInUse:
                alertTitle = "Email is Already Registered"
                
            case .wrongPassword:
                alertTitle = "Incorrect Password"
                
            case .invalidEmail:
                alertTitle = "Invalid Email Address"
                
            case .userNotFound:
                alertTitle = "Email Not Registered"
                
            case .missingEmail:
                alertTitle = "No Email Was Provided"
                
            case .networkError:
                alertTitle = "Unable to Reach Server, Check Your Wifi Connection"
                
            case .userDisabled:
                alertTitle = "This Account has Been Disabled"
                
            default:
                alertTitle =  "Unknown Error"
            }
            
        }
        
        let errorAlert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        
        return errorAlert
        
    }
    
    static func createSuccessAlert(description: String) -> UIAlertController {
        
        let successAlert = UIAlertController(title: description, message: nil, preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        return successAlert
        
    }
    
}
