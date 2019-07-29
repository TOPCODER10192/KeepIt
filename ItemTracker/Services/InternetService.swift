//
//  InternetService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-28.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import Reachability

final class InternetService {
    
    static func checkForConnection() -> Bool {
        
        guard let reachability = Reachability() else { return false }
        
        switch reachability.connection {
            
        case .wifi, .cellular:
            return true
        
        case .none:
            return false
        }
        
    }
    
}
