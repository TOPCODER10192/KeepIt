//
//  AddItemCollectionReusableView.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-02.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

protocol AddItemReusableViewProtocol {
    
    func loadAddItemVC()
    
}

final class AddItemCollectionReusableView: UICollectionReusableView {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var addItemButton: UIButton!
    
    // MARK: - AddItemCollectionReusableView Properties
    var delegate: AddItemReusableViewProtocol?
    
    // MARK: - View Methods
    override func awakeFromNib() {
        
        // Setup the button
        addItemButton.layer.cornerRadius = Constants.View.CornerRadius.button * 2
        addItemButton.backgroundColor    = Constants.Color.primary
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func addItemButtonTapped(_ sender: UIButton) {
        
        // Tell the delegate to load the addItemVC
        delegate?.loadAddItemVC()
        
    }
    
}
