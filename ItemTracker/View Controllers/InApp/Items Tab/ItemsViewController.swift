//
//  ProfileViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-20.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import SDWebImage
import GoogleMobileAds

final class ItemsViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    var bannerView: GADBannerView!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collectionView
        itemsCollectionView.delegate            = self
        itemsCollectionView.dataSource          = self
        itemsCollectionView.layer.masksToBounds = false
        itemsCollectionView.clipsToBounds       = true
        
        // Setup the navigation bar
        navigationBar.tintColor = Constants.Color.primary
        
        // Setup the Banner View
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        addBannerViewToView(bannerView)
        
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
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
        
        // Check if its the users first time being logged in
        if UserDefaults.standard.value(forKey: Constants.Key.firstLogin) == nil {
            WalkthroughService.showCTHelp(vc: self)
        }
        
        
        UserDefaults.standard.set(false, forKey: Constants.Key.firstLogin)
        
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
        if Stored.userItems.count > 0 {
            loadVC(ID: Constants.ID.VC.updateLocation,
                           sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                           animated: false)
        }
        // Otherwise, show the user an alert that they need to add items
        else {
            
            presentNoItemsAlert()
            
        }
        
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

// MARK: - Single Item Protocol Methods
extension ItemsViewController: SingleItemProtocol {
    
    func itemDeleted() {
        
        // Refresh the collectionView
        itemsCollectionView.reloadData()
        
    }
    
    func itemSaved(item: Item) {
        
        // Refresh the collectionView
        itemsCollectionView.reloadData()
        
    }
    
}

// MARK: - Collection View Methods
extension ItemsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let numItems = Stored.userItems.count
        
        if numItems > 0 {
            collectionView.eraseEmptyMessage()
        }
        else {
            collectionView.setEmptyMessage("You're not tracking any items\nPress the \"+\" to add an item")
        }
        
        // Return the number of items that the user has stored
        return numItems
        
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
        else {
            cell.itemImage.image = UIImage(named: "DefaultImage")
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

// MARK: - Custom Protocol Methods
extension ItemsViewController: SettingsProtocol {
    
    func settingsClosed() {
        
        // Reload the collection view
        itemsCollectionView.reloadData()
        
    }
    
    func showWalkthrough() {
        
        // Show the walkthrough
        WalkthroughService.showCTHelp(vc: self)
        
    }
    
}

// MARK: - Helper Functions
extension ItemsViewController  {
    
    func presentNoItemsAlert() {
        
        let noItemsAlert = UIAlertController(title: "No Items",
                                             message: "You're not keeping track of any of your items yet",
                                             preferredStyle: .alert)
        
        noItemsAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        noItemsAlert.addAction(UIAlertAction(title: "Add an Item", style: .default, handler: { (action) in
            
            // Load the Single Item VC
            self.loadVC(ID: Constants.ID.VC.singleItem,
                        sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                        animated: false)
            
        }))
        
        present(noItemsAlert, animated: true, completion: nil)
        
    }
    
    func loadVC(ID: String, sb: UIStoryboard, animated: Bool) {
        
        let vc = sb.instantiateViewController(withIdentifier: ID)
        
        if let vc = vc as? SingleItemViewController{
            
            let indexPaths = itemsCollectionView.indexPathsForSelectedItems
            
            if indexPaths != nil, indexPaths!.count > 0, let index = indexPaths?[0].row {
                itemsCollectionView.selectItem(at: nil,
                                               animated: false,
                                               scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
                
                vc.existingItem = Stored.userItems[index]
                vc.existingItemIndex = index
            }
            
            vc.delegate = self
        }
        else if let vc = vc as? UINavigationController {
            
            if let rootVC = vc.viewControllers[0] as? SettingsTableViewController {
                rootVC.delegate = self
            }
            
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: animated, completion: nil)
        
    }

}

// MARK: - Additional Collection View Methods
extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        
        // Create a background message label
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0,
                                   width: self.bounds.size.width,
                                   height: self.bounds.size.height))
        
        // Set the text for the label
        messageLabel.text = message
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 22)
        messageLabel.sizeToFit()
        
        // Set the background view of the collection view
        self.backgroundView = messageLabel
        
    }
    
    func eraseEmptyMessage() {
        
        // Get rid of the collection view background
        self.backgroundView = nil
        
    }
    
}

// MARK: - Advertisement Methods
extension ItemsViewController: GADBannerViewDelegate {
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
        
    }
    
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        
        // Add Constraints to stick it to the bottom of the view and equal width to the screen
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0))
    }
    
    
}
