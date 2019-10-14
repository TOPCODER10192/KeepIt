//
//  ProfileViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-20.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import GoogleMobileAds

final class ItemsViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var itemsTableViewToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    var bannerView: GADBannerView!
    
    // MARK: - Properties
    let topItemRGB: [CGFloat] = [175, 82, 222]
    let bottomItemRGB: [CGFloat] = [233, 207, 246]
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collectionView
        itemsTableView.delegate            = self
        itemsTableView.dataSource          = self
        itemsTableView.layer.masksToBounds = false
        itemsTableView.clipsToBounds       = true
        
        // Setup the navigation bar
        navigationBar.tintColor = Constants.Color.primary
        
        // Setup the Banner View
        /*
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.delegate = self
        
        bannerView.adUnitID = "ca-app-pub-1584397833153899/1844990630"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload the collection view
        itemsTableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Check if its the users first time being logged in
        if UserDefaults.standard.value(forKey: Constants.Key.firstLogin) == nil {
            loadVC(ID: Constants.ID.VC.welcome, sb: UIStoryboard(name: Constants.ID.Storyboard.tabBar, bundle: .main), animated: true)
            WalkthroughService.showCTHelp(vc: self)
        }
        
        
        // Mark that the user has seen the walkthrough
        UserDefaults.standard.set(false, forKey: Constants.Key.firstLogin)
        
    }
    
}

// MARK: - Navigiation Bar Methods
extension ItemsViewController {
    
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

// MARK: - Table View Methods
extension ItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let numItems = Stored.userItems.count
        
        if numItems > 0 {
            
            // Erase the message that tells the user they have no items
            tableView.eraseEmptyMessage()
            
        }
        else {
            
            // Write a message that tells the user they have no items
            tableView.setEmptyMessage("You're not tracking any items\nPress the \"+\" to add an item")
            
        }
        
        // Return the number of items that the user has stored
        return numItems
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create the cell and set the label accordingly
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ID.Cell.item, for: indexPath) as! ItemTableViewCell
        
        // Calculate the cells color based on its vertical position in the table view
        let red = topItemRGB[0] + (CGFloat(indexPath.row) * (bottomItemRGB[0] - topItemRGB[0]) / CGFloat(tableView.numberOfRows(inSection: 0)))
        let green = topItemRGB[1] + (CGFloat(indexPath.row) * (bottomItemRGB[1] - topItemRGB[1]) / CGFloat(tableView.numberOfRows(inSection: 0)))
        let blue = topItemRGB[2] + (CGFloat(indexPath.row) * (bottomItemRGB[2] - topItemRGB[2]) / CGFloat(tableView.numberOfRows(inSection: 0)))
        cell.floatingView.backgroundColor = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 255/255)
        
        // Set the cell label
        cell.itemTitleLabel.text = Stored.userItems[indexPath.row].name
        cell.itemUpdateDateLabel.text = "Last Updated: \(Stored.userItems[indexPath.row].lastUpdateDate)"
        
        if let url = URL(string: Stored.userItems[indexPath.row].imageURL) {
            cell.setPhoto(url: url)
        }
        else {
            cell.itemImageView.image = UIImage(named: "DefaultImage")
        }
        
        // Return the cell
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Present the selected item VC
        loadVC(ID: Constants.ID.VC.singleItem,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animated: false)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return (UIScreen.main.bounds.width * 0.853333333 / 4) * 1.25
        
    }
    
}

// MARK: - Cell Protocol Methods
extension ItemsViewController: SingleItemProtocol {
    
    func itemDeleted() {
        
        // Refresh the collectionView
        itemsTableView.reloadData()
        
    }
    
    func itemSaved(item: Item) {
        
        // Refresh the collectionView
        itemsTableView.reloadData()
        
    }
    
}

// MARK: - Custom Protocol Methods
extension ItemsViewController: SettingsProtocol {
    
    func settingsClosed() {
        
        // Reload the collection view
        itemsTableView.reloadData()
        
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
        
        // Create a general vc
        let vc = sb.instantiateViewController(withIdentifier: ID)
        
        // Check if it can be type cast and setup the vc if it can be
        if let vc = vc as? SingleItemViewController{
            
            let indexPath = itemsTableView.indexPathForSelectedRow
            
            if indexPath != nil, indexPath!.count > 0, let index = indexPath?.row {
                
                itemsTableView.selectRow(at: nil, animated: false, scrollPosition: UITableView.ScrollPosition.middle)
                
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
        
        // Setup the vc and present it
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: animated, completion: nil)
        
    }

}

// MARK: - Additional Collection View Methods
extension UITableView {
    
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
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        // Add the banner view to the view
        addBannerViewToView(bannerView)
        
        // Shift the buttons at the bottom of the screen to be relative to the ad
        shiftCollectionViewUp()
        
    }
    
    func shiftCollectionViewUp() {
        
        // Shift the map bottom to equal the top of the banner view
        self.itemsTableViewToBottom.constant = self.bannerView.bounds.height
        
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        
        // Add the bannerView to the view
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
