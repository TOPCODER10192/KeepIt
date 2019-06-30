//
//  Item.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation

struct Item {
    
    // MARK: - Item Properties
    var name: String
    var mostRecentLocation: [Double]
    var lastUpdateDate: String
    var isMovedOften: Bool
    var imageURL: String

    init(withName: String, withLocation: [Double], withLastUpdateDate: String, withMovement: Bool, withImageURL: String) {
        
        name               = withName
        mostRecentLocation = withLocation
        lastUpdateDate     = withLastUpdateDate
        isMovedOften       = withMovement
        imageURL           = withImageURL
        
    }
    
    
}
