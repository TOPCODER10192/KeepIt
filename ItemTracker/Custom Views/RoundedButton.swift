//
//  RoundedButton.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-21.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
        
    }
    
    func activateButton(isActivated: Bool, color: UIColor) {
        
        self.isEnabled = isActivated
        self.backgroundColor = color
        
    }
    
}
