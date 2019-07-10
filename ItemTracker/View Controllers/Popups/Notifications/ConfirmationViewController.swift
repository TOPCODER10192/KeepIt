//
//  ConfirmationViewController.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-10.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

protocol ConfirmationProtocol {
    
    func deleteItem()
    
}

class ConfirmationViewController: UIViewController {

    @IBOutlet weak var floatingView: UIView!
    
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    var item: Item?
    var delegate: ConfirmationProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the Floating View
        floatingView.layer.cornerRadius = Constants.View.CornerRadius.standard
        floatingView.backgroundColor    = Constants.Color.notificationView
        floatingView.layer.borderColor  = UIColor.black.cgColor
        floatingView.layer.borderWidth  = 1
        
        // Setup the noButton
        noButton.backgroundColor  = Constants.Color.success
        noButton.layer.cornerRadius = Constants.View.CornerRadius.button
        
        // Setup the yesButton
        yesButton.backgroundColor = Constants.Color.error
        yesButton.layer.cornerRadius = Constants.View.CornerRadius.button
    }
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        
        delegate?.deleteItem()
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
