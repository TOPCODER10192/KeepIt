//
//  ProfileViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-20.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

final class ItemsViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    // MARK: Properties

    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collectionView
        itemsCollectionView.delegate            = self
        itemsCollectionView.dataSource          = self
        itemsCollectionView.layer.masksToBounds = false
        itemsCollectionView.clipsToBounds       = true
        
        addRefreshControl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload the collection view
        itemsCollectionView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If the user has no items then bring up the Add Item VC
        if Stored.userItems.count == 0 {
            loadAddItemVC()
        }
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        loadAddItemVC()
        
    }
    
}

// MARK: - Helper Methods
extension ItemsViewController {
    
    func addRefreshControl() {
        
        let refreshControl = UIRefreshControl()
        itemsCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshInitiated(refreshControl:)), for: .valueChanged)
        
    }
    
    @objc func refreshInitiated(refreshControl: UIRefreshControl) {
        
        itemsCollectionView.reloadData()
        refreshControl.endRefreshing()
        
    }
    
}

// MARK: - Methods that conform to AddItemProtocol
extension ItemsViewController: AddItemProtocol {
    
    func itemAdded(item: Item) {
        
        // Refresh the collectionView
        itemsCollectionView.reloadData()
        
    }
    
}

// MARK: - Methods that conform to UICollectionView
extension ItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return the number of items that the user has stored
        return Stored.userItems.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Create the cell and set the label accordingly
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ID.Cell.item, for: indexPath) as! ItemCollectionViewCell
        
        cell.itemLabel.text = Stored.userItems[indexPath.row].name
        
        let cellWidth  = itemsCollectionView.bounds.width * 0.45
        let imageWidth = cellWidth * 0.65
        cell.itemImage.layer.cornerRadius = imageWidth / 2
        cell.itemImage.layer.borderColor = Constants.Color.primary.cgColor
        cell.itemImage.layer.borderWidth = 2
        
        if let url = URL(string: Stored.userItems[indexPath.row].imageURL) {
            cell.setPhoto(url: url)
        }
            
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = itemsCollectionView.bounds.width * 0.45
        let height = width
        
        return CGSize(width: width, height: height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        var cell: UICollectionReusableView!
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: Constants.ID.Cell.itemHeader,
                                                                   for: indexPath)
            
        }
        else  {
            
            cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: Constants.ID.Cell.itemFooter,
                                                                   for: indexPath)
            
            if let cell = cell as? AddItemCollectionReusableView {
                cell.delegate = self
            }
            
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        // If the user has items then don't show the header
        if Stored.userItems.count != 0 {
            return CGSize(width: 0, height: 0)
        }
        // Otherwise, show the view
        else {
            return CGSize(width: collectionView.bounds.width, height: Constants.View.Height.itemHeader)
        }
        
    }
    
}

extension ItemsViewController: AddItemReusableViewProtocol {
    
    func loadAddItemVC() {
        
        // Instantiate a view controller and check that it isn't nil
        let addItemVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.ID.VC.addItem) as? AddItemViewController
        guard addItemVC != nil else { return }
        
        // Set self as delegate
        addItemVC?.delegate = self
        
        // Set the presentation style and present
        addItemVC!.modalPresentationStyle = .overCurrentContext
        self.present(addItemVC!, animated: false, completion: nil)
        
    }

}

