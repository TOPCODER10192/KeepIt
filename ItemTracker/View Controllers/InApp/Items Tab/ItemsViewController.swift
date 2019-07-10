//
//  ProfileViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-20.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import SDWebImage

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
        
        // Add a refresh control for the collection view
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
            loadVC(ID: Constants.ID.VC.singleItem,
                   sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                   animated: false)
        }
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the Add Item VC
        loadVC(ID: Constants.ID.VC.singleItem,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animated: false)
        
    }
    
    @IBAction func updateButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the Update Location VC
        loadVC(ID: Constants.ID.VC.updateLocation,
                       sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                       animated: false )
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the Settings VC
        loadVC(ID: Constants.ID.VC.settings,
               sb: UIStoryboard(name: Constants.ID.Storyboard.settings, bundle: .main),
               animated: true)
        
    }
    
}

// MARK: - Refresh Control Methods
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
extension ItemsViewController: SingleItemProtocol {
    
    func itemSaved(item: Item) {
        
        // Refresh the collectionView
        itemsCollectionView.reloadData()
        
    }
    
}

// MARK: - Collection View Methods
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
        
        // Set the width and height 
        let width = itemsCollectionView.bounds.width * 0.45
        let height = width
        
        return CGSize(width: width, height: height)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Present the selected item VC
        loadVC(ID: Constants.ID.VC.singleItem,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animated: false)
        
    }
    
}

// MARK: - Helper Functions
extension ItemsViewController  {
    
    func loadVC(ID: String, sb: UIStoryboard, animated: Bool) {
        
        let vc = sb.instantiateViewController(withIdentifier: ID)
        
        if let vc = vc as? SingleItemViewController{
            
            let indexPaths = itemsCollectionView.indexPathsForSelectedItems
            
            if indexPaths != nil, indexPaths!.count > 0, let index = indexPaths?[0].row {
                itemsCollectionView.selectItem(at: nil, animated: false, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                vc.existingItem = Stored.userItems[index]
                vc.existingItemIndex = index
            }
            
            vc.delegate = self
        }
        else if let vc = vc as? UpdateLocationViewController {
            
        }

        
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: animated, completion: nil)
        
        
    }

}

