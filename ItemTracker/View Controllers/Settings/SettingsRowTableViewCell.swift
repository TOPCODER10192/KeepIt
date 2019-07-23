//
//  SettingsRowTableViewCell.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class SettingsRowTableViewCell: UITableViewCell {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
