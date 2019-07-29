//
//  WelcomeViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var continueButton: UIButton!
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register the nibs as cells for the collection view
        let locationsCell = UINib(nibName: "LocationsCollectionViewCell", bundle: .main)
        collectionView.register(locationsCell, forCellWithReuseIdentifier: "LocationsCell")
        
        let notificationCell = UINib(nibName: "NotificationsCollectionViewCell", bundle: .main)
        collectionView.register(notificationCell, forCellWithReuseIdentifier: "NotificationsCell")
        
        // Setup the pageControl
        pageControl.pageIndicatorTintColor = Constants.Color.softPrimary
        pageControl.currentPageIndicatorTintColor = Constants.Color.primary
        
        // Setup the continue button
        continueButton.tintColor = Constants.Color.primary
        
    }
    
}

// MARK: - Button Methods
extension WelcomeViewController {
    
    @IBAction func setupLaterButtonTapped(_ sender: UIButton) {
        
        // Acknowledge that the user has seen the welcome view and dismiss it
        UserDefaults.standard.set(false, forKey: Constants.Key.firstLaunch)
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        if pageControl.currentPage == 0 {
            
            // Move to the next page
            pageControl.currentPage = 1
            collectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0), at: .left, animated: true)
            
        }
        else {
            
            // Acknowledge that the user has seen the welcome view and dismiss it
            UserDefaults.standard.set(false, forKey: Constants.Key.firstLaunch)
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
}

// MARK: - Collection View Methods
extension WelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // 1 page for location and 1 page for Notifications
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Page 0 is the locations page
        if indexPath.row == 0 {

            // Create the locations cell, set the delegate and return
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationsCell", for: indexPath) as? LocationsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.delegate = self
            return cell
            
        }
        // Page 1 is the notifications page
        else {
            
            // Create the notifications cell and return
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationsCell", for: indexPath) as? NotificationsCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            return cell
            
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Make the cells the same size as the collection view
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // Change the page indicator to match the page
        let pageWidth = collectionView.frame.size.width;
        let currentPage = collectionView.contentOffset.x / pageWidth;
        
        pageControl.currentPage = Int(currentPage)
        
    }
    
}

// MARK: - Custom Protocol Methods
extension WelcomeViewController: LocationProtocol {
    
    func locationTapped() {
        
        // Move to the next page of the welcome form
        self.pageControl.currentPage = 1
        self.collectionView.scrollToItem(at: IndexPath(row: self.pageControl.currentPage, section: 0), at: .left, animated: true)

    }
    
}
