//
//  ItemTableViewCell.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-09-13.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import SDWebImage

class ItemTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var floatingView: FloatingView!
    
    @IBOutlet weak var itemImageView: UIImageView!
    
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemUpdateDateLabel: UILabel!
    
    // MARK: - Initializeation Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = false
        
        let floatingViewWidth = UIScreen.main.bounds.width * 0.8533333
        let floatingViewHeight = floatingViewWidth * 0.25
        let imageViewLength = floatingViewHeight * 0.75
        
        // Set the background
        floatingView.layer.shadowColor = UIColor.lightGray.cgColor
        floatingView.layer.shadowOpacity = 0.5
        floatingView.layer.shadowOffset = CGSize(width: 0, height: 5)
        floatingView.layer.shadowRadius = 2
        
        // Setup the title label
        itemTitleLabel.adjustsFontSizeToFitWidth = true
        
        // Setup the date label
        itemUpdateDateLabel.adjustsFontSizeToFitWidth = true
        
        // Setup the cell image
        itemImageView.layer.cornerRadius = imageViewLength / 2
        itemImageView.layer.borderColor = UIColor.white.cgColor
        itemImageView.layer.borderWidth = 1
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setPhoto(url: URL) {
        
        // Create a loading indicator
        itemImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        // Set the image for the item
        itemImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
            
            self.itemImageView.image = image
            
        }
        
    }

}
