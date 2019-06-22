//
//  ProfileViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-20.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collectionView
        itemsCollectionView.delegate            = self
        itemsCollectionView.dataSource          = self
        itemsCollectionView.layer.masksToBounds = false
        
    }

}

extension ItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 20
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ITEM_CELL_ID, for: indexPath) as! ItemCollectionViewCell
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let footerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.ADD_ITEM_CELL_ID, for: indexPath) as! AddItemCollectionReusableView
        
        return footerCell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = itemsCollectionView.bounds.width * 0.45
        let height = width
        
        return CGSize(width: width, height: height)
        
    }
    
    
    
}
