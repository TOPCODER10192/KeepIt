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

final class UpdateLocationTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var checkBoxButton: UIButton!
    
    // MARK: - Properties
    var cellIndex: Int?
    var checkBoxState: Bool = false
    var delegate: UpdateLocationCellProtocol?
    
    // MARK: - View Methods
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
    
    func setPhoto(url: URL) {
        
        // Create a loading indicator
        itemImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        
        // Set the image for the item
        itemImage.sd_setImage(with: url) { (image, error, cacheType, url) in
            
            self.itemImage.image = image
            
        }
        
    }

    @IBAction func checkBoxButtonTapped(_ sender: UIButton) {
        
        // Set the color of the box based on the state
        if checkBoxState == false {
            checkBoxButton.backgroundColor = Constants.Color.primary
        }
        else {
            checkBoxButton.backgroundColor = UIColor.clear
        }
        
        // Invert the state
        checkBoxState = !checkBoxState
        
        // Tell the delegate that a box was clicked
        delegate?.itemSelected(index: cellIndex!, state: checkBoxState)
    }
    
}
