//
//  WalkthroughService.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-27.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import Foundation
import CTHelp

class WalkthroughService {
    
    static func showCTHelp(vc: UIViewController) {
        
        let ctHelp = CTHelp()
        
        ctHelp.ctBgViewColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 255/255)
        
        ctHelp.new(CTHelpItem(title:"Lets Get Started!",
                              helpText: "KeepIt was designed to help you keep track of all your important things without the use of tracking devices and do so in a way that will take less than a minute a day",
                              imageName:"KeyImagePurple"))
        
        ctHelp.new(CTHelpItem(title: "Updating Item Locations",
                              helpText: "At the top-left of the screen is the reload icon, tap this when you want to update the location of any of your items", imageName: "ReloadImage"))
        
        ctHelp.new(CTHelpItem(title: "Adding Items",
                              helpText: "Right next to the reload icon is the '+' Icon, tap this when you want to add another item to keep track of",
                              imageName: "PlusImage"))
        
        ctHelp.new(CTHelpItem(title: "GeoFences",
                              helpText: "Using GeoFences we can remind you to update your item locations wherever you want. All you have to do is add a GeoFence and place it wherever you would like to be reminded",
                              imageName: "GeoFenceImage"))
        
        ctHelp.presentHelp(from: vc)
        
    }
    
}
