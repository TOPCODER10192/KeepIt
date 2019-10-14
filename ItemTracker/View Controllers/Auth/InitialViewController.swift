//
//  InitialViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-09-01.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var skipButton: UIButton!
    
    @IBOutlet weak var pagedCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var getStartedButton: RoundedButton!
    @IBOutlet weak var loginButton: RoundedButton!
    
    // MARK: - Initialization Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the skip button
        skipButton.tintColor = Constants.Color.primary
        
        // Setup the collection view
        pagedCollectionView.backgroundColor = UIColor.clear
        pagedCollectionView.delegate = self
        pagedCollectionView.dataSource = self
        
        // Setup the get started button
        getStartedButton.backgroundColor = Constants.Color.primary
        
        // Setup the login button
        loginButton.backgroundColor = UIColor.white
        loginButton.layer.borderColor = Constants.Color.primary.cgColor
        loginButton.layer.borderWidth = 3
        
        // This code will later be removed
        pageControl.isHidden = true
        pagedCollectionView.isScrollEnabled = false
        
    }
    
}

// MARK: - Button Methods
extension InitialViewController {
    
    @IBAction func skipButtonTapped(_ sender: UIButton) {
        
        // Disable the UI
        self.view.isUserInteractionEnabled = false
        
        // Show a progress indicator
        ProgressService.progressAnimation(text: nil)
        
        // Attempt to create an anonymous account for the user
        FirebaseAuthService.attemptAnonymousSignUp { (error) in
            
            // Check if there is an error
            guard error == nil else {
                self.view.isUserInteractionEnabled = true
                ProgressService.errorAnimation(text: nil)
                return
            }
            
            // Show that the process was successful
            ProgressService.successAnimation(text: nil)
            
            // Go into the app
            self.goIntoApp()
            
        }
        
    }
    
    @IBAction func getStartedButtonTapped(_ sender: RoundedButton) {
        
        // Create a sign up vc
        guard let signUpVC = storyboard?.instantiateViewController(withIdentifier: Constants.ID.VC.signUp) as? SignUpViewController else {
            return
        }
        
        // Present the sign up vc
        present(signUpVC, animated: true, completion: nil)
        
    }
    
    @IBAction func loginButtonTapped(_ sender: RoundedButton) {
        
        // Present the login vc
        guard let userLoginVC = storyboard?.instantiateViewController(withIdentifier: Constants.ID.VC.userLogin) as? UserLoginViewController else {
            return
        }
        
        // Present the login vc
        present(userLoginVC, animated: true, completion: nil)
        
    }
    
}

// MARK: - Collection View Methods
extension InitialViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Return 3, since that is the number of pages we have
        return 3
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Try to create a cell
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ID.Cell.initial, for: indexPath) as? InitialCollectionViewCell
        else { return UICollectionViewCell() }
        
        // Set the page number for the cell, then set the appropriate attributed text
        cell.pageNum = indexPath.row
        cell.setAttributedText()
        
        // Return the cell
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Set the cell size to be the same as the collection view size
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // Get the page width to calculate the current page
        let pageWidth = pagedCollectionView.frame.size.width;
        let currentPage = pagedCollectionView.contentOffset.x / pageWidth;
        
        // Change the page indicator to match the page
        pageControl.currentPage = Int(currentPage)
        
    }
    
}

// MARK: - Helper Methods
extension InitialViewController {
    
    func goIntoApp() {
        
        // Create a tab bar vc adn present it
        let tabBarVC = UIStoryboard(name: Constants.ID.Storyboard.tabBar, bundle: .main)
            .instantiateViewController(withIdentifier: Constants.ID.VC.tabBar)
        
        present(tabBarVC, animated: true, completion: nil)
        
        
    }
    
}
