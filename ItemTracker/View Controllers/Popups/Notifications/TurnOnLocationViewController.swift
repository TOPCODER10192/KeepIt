//
//  TurnOnLocationViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-05.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import CoreLocation

class TurnOnLocationViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet var dimView: UIView!
    
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var goToSettingsButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    
    // MARK: - Properties
    let locationManger = CLLocationManager()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup location manager
        locationManger.delegate = self

        // Setup the dim view
        dimView.backgroundColor = UIColor.clear
        
        // Setup the floating view
        floatingView.backgroundColor     = Constants.Color.notificationView
        floatingView.layer.cornerRadius  = Constants.View.CornerRadius.standard
        floatingViewYConstraint.constant = UIScreen.main.bounds.height
        
        // Setup the goToSettingsButton
        goToSettingsButton.layer.cornerRadius = Constants.View.CornerRadius.button
        goToSettingsButton.backgroundColor    = Constants.Color.settings
        
        // Setup the dismissButton
        dismissButton.layer.cornerRadius = Constants.View.CornerRadius.button
        dismissButton.backgroundColor    = Constants.Color.primary
        
        
        let formattedString = NSMutableAttributedString()
        formattedString
            .normal("1. Click the")
            .bold(" \"Go to Settings\" ")
            .normal("button\r")
            .normal("2. Click on ")
            .bold("\"Location\"\r")
            .normal("3. Allow access to location")

        promptLabel.attributedText = formattedString
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Slide the view in
        slideViewIn()
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func goToSettingsButtonTapped(_ sender: UIButton) {
        
        // Go to the settings app
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        
    }
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        
        // Slide the view out
        slideViewOut()
        
    }
    

}

extension TurnOnLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check the location authorization
        checkLocationAuthorization()
        
    }
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            slideViewOut()
            
        // Case if no authorization
        case .restricted, .denied, .notDetermined:
            break
            
        @unknown default:
            break
        }
        
    }
    
    
}

// MARK: - Animation Methods
extension TurnOnLocationViewController {
    
    func slideViewIn() {
        
        // Slide the view in from the botton
        UIView.animate(withDuration: 0.2, animations: {
            
            // First, fade in the dimView
            self.dimView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 180/255)
            
        }) { (true) in
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                // Second, slide in the Floating View
                self.floatingViewYConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
    }
    
    func slideViewOut() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            // First, slide out the Floating View
            self.floatingViewYConstraint.constant = UIScreen.main.bounds.height
            self.view.layoutIfNeeded()
            
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                
                // Second, fade out the Dim View
                self.dimView.backgroundColor = UIColor.clear
                
            }, completion: { (true) in
                
                // Third, dismiss the VC
                self.dismiss(animated: false, completion: nil)
                
            })
        }
        
    }
    
    
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "SFProText-Semibold", size: 16)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "SF Pro Text", size: 16)!]
        let normal = NSMutableAttributedString(string: text, attributes: attrs)
        
        append(normal)
        
        return self
    }
}
