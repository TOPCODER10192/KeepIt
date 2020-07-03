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
    var id: String
    var name: String
    var mostRecentLocation: [Double]
    var lastUpdateDate: String
    var imageURL: String

    init(withID: String, withName: String, withLocation: [Double], withLastUpdateDate: String, withImageURL: String) {
        id                 = withID
        name               = withName
        mostRecentLocation = withLocation
        lastUpdateDate     = withLastUpdateDate
        imageURL           = withImageURL
    }
    
    
}
