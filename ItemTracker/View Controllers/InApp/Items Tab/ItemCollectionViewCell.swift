//
//  ItemCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-21.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import SDWebImage
import UICircularProgressRing

class ItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var circularProgressRing: UIView!
    
    // MARK: - ItemCollectionViewCell Properties
    
    override func awakeFromNib() {
        
        // Setup the cell
        self.layer.shadowColor   = UIColor.darkGray.cgColor
        self.layer.shadowOffset  = CGSize(width: 1, height: 1)
        self.layer.shadowRadius  = 1
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        self.layer.cornerRadius  = Constants.View.CornerRadius.standard
        
        // Setup the itemLabel
        itemLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    func setPhoto(url: URL, index: Int) {
        
        
        itemImage.sd_setImage(with: url) { (image, error, cacheType, url) in
            
            self.itemImage.image = image
            Stored.userItems[index].image = image
            
            
        }
        
    }
    
}
