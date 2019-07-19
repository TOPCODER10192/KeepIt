//
//  WelcomeViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-18.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

protocol WelcomeProtocol {
    
    func goToInApp()
    
}

class WelcomeViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    var delegate: WelcomeProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the floating view
        floatingView.layer.cornerRadius = Constants.View.CornerRadius.standard
        
        // Setup the collection view
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let locationsCell = UINib(nibName: "LocationsCollectionViewCell", bundle: .main)
        collectionView.register(locationsCell, forCellWithReuseIdentifier: "LocationsCell")
        
        let notificationCell = UINib(nibName: "NotificationsCollectionViewCell", bundle: .main)
        collectionView.register(notificationCell, forCellWithReuseIdentifier: "NotificationsCell")
        
    }
    
}

// MARK: - Button Methods
extension WelcomeViewController {
    
    @IBAction func setupLaterButtonTapped(_ sender: UIButton) {
        
        // Dismiss the current view
        self.dismiss(animated: true) {
            
            // Go into the app
            self.delegate?.goToInApp()
            
        }
        
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        
        if pageControl.currentPage == 0 {
            
            // Move to the next page
            pageControl.currentPage = 1
            collectionView.scrollToItem(at: IndexPath(row: pageControl.currentPage, section: 0), at: .left, animated: true)
            
        }
        else {
            
            // Dismiss the current view
            self.dismiss(animated: true) {
                
                // Go into the app
                self.delegate?.goToInApp()
                
            }
        }
        
    }
    
    
}

// MARK: - Collection View Methods
extension WelcomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // The collection view will only have 2 pages
        return 2
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Page 0 is the locations page
        if indexPath.row == 0 {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationsCell", for: indexPath)
            return cell
            
        }
        // Page 1 is the notifications page
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NotificationsCell", for: indexPath)
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
