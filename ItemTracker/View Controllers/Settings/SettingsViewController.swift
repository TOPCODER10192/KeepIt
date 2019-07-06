//
//  SettingsViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-06.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK: - IBOutlet Properties
    
    // MARK: - Properties
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBAction Methods
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    

}
