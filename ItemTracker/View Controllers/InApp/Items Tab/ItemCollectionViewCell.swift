//
//  ItemCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-21.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemLabel: UILabel!
    
    // MARK: - ItemCOllectionViewCell Properties
    
    override func awakeFromNib() {
        
        // Setup the cell
        self.layer.shadowColor   = UIColor.darkGray.cgColor
        self.layer.shadowOffset  = CGSize(width: 1, height: 1)
        self.layer.shadowRadius  = 1
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.cornerRadius  = Constants.GENERAL_CORNER_RADIUS
        
        // Setup the itemLabel
        itemLabel.adjustsFontSizeToFitWidth = true
        
        
    }
}
