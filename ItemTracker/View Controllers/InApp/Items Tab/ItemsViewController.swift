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
    
    // MARK: Properties

    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collectionView
        itemsCollectionView.delegate            = self
        itemsCollectionView.dataSource          = self
        itemsCollectionView.layer.masksToBounds = false
        itemsCollectionView.clipsToBounds       = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload the collection view
        itemsCollectionView.reloadData()
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
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
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = itemsCollectionView.bounds.width * 0.45
        let height = width
        
        return CGSize(width: width, height: height)
        
    }
    
}

