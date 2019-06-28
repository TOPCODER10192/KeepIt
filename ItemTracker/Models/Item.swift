//
//  Item.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import UIKit

struct Item {
    
    // MARK: - Item Properties
    var name: String
    var mostRecentLocation: [Double]
    var isMovedOften: Bool
    var imageURL: String
    var image: UIImage?
    
    init(withName: String, withLocation: [Double], withMovement: Bool, withImageURL: String, withImage: UIImage? = nil) {
        
        name               = withName
        mostRecentLocation = withLocation
        isMovedOften       = withMovement
        imageURL           = withImageURL
        image              = withImage
        
    }
    
    
}
