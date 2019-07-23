//
//  ItemCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-21.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import SDWebImage

@IBDesignable
final class ItemCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemImage: UIImageView!
    
    // MARK: - ItemCollectionViewCell Properties
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib() {
        
        // Setup the cell
        self.layer.shadowColor   = UIColor.darkGray.cgColor
        self.layer.shadowOffset  = CGSize(width: 1, height: 1)
        self.layer.shadowRadius  = 1
        self.layer.shadowOpacity = 0.5
        self.layer.masksToBounds = false
        
        // Setup the itemLabel
        itemLabel.adjustsFontSizeToFitWidth = true
        
    }
    
    func setPhoto(url: URL) {
        
        // Create a loading indicator
        itemImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        // Set the image for the item
        itemImage.sd_setImage(with: url) { (image, error, cacheType, url) in
            
            self.itemImage.image = image
            
        }
        
    }
    
}
