//
//  UpdateLocationTableViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-04.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit 
import SDWebImage

protocol UpdateLocationCellProtocol {
   
    func itemSelected(index: Int, state: Bool)
    
}

class UpdateLocationTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    // MARK: - UpdateLocationTableViewCell Properties
    var cellIndex: Int?
    var checkBoxState: Bool = false
    var delegate: UpdateLocationCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the image
        itemImage.layer.cornerRadius = itemImage.bounds.width / 2
        itemImage.layer.borderWidth  = 1
        itemImage.layer.borderColor  = Constants.Color.primary.cgColor
        itemImage.clipsToBounds      = true
        
        // Setup the check button
        checkBoxButton.backgroundColor    = UIColor.clear
        checkBoxButton.layer.cornerRadius = checkBoxButton.bounds.width / 2
        checkBoxButton.layer.borderColor  = Constants.Color.primary.cgColor
        checkBoxButton.layer.borderWidth  = 2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPhoto(url: URL) {
        
        // Create a loading indicator
        itemImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        // Set the image for the item
        itemImage.sd_setImage(with: url) { (image, error, cacheType, url) in
            
            self.itemImage.image = image
            
        }
        
    }

    @IBAction func checkBoxButtonTapped(_ sender: UIButton) {
        
        if checkBoxState == false {
            checkBoxButton.backgroundColor = Constants.Color.primary
        }
        else {
            checkBoxButton.backgroundColor = UIColor.clear
        }
        
        checkBoxState = !checkBoxState
        delegate!.itemSelected(index: cellIndex!, state: checkBoxState)
    }
    
}
