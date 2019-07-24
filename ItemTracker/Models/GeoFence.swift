//
//  GeoFence.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-24.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation

struct GeoFence {
    
    let name: String
    let centreCoordinate: [Double]
    let radius: Double
    let triggerOnEntrance: Bool
    let triggerOnExit: Bool
    
}
