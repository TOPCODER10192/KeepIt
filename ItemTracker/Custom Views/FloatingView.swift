//
//  FloatingView.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

@IBDesignable
class FloatingView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

}
