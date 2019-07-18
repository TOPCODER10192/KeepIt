//
//  PasswordTextField.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-17.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

@IBDesignable
class CustomTextField: UITextField {
    
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateLeftView()
        }
    }
    
    func updateLeftView() {
        
        if let image = leftImage {
            leftViewMode = .always
            
            let imageView = UIImageView(frame: CGRect(x: 5, y: 0, width: 20, height: 20))
            imageView.image = image
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 20))
            view.addSubview(imageView)
            
            leftView = view
            
        }
        else {
            leftViewMode = .never
        }
        
    }
    
}
