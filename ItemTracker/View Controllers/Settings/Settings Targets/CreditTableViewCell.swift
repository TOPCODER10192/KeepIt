//
//  CreditTableViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-23.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

class CreditTableViewCell: UITableViewCell {
    
    @IBOutlet weak var linkTextView: UITextView!
    
    override func awakeFromNib() {
        
        self.tintColor = Constants.Color.primary
        
    }
    
}


// MARK: - Extension of NSAttributed String to make hyperlinks
extension NSAttributedString {
    
    static func makeHyperlink(for path: String, in string: String, as substring: String) -> NSAttributedString {
        
        // Get the range of the string and the substring
        let nsString = NSString(string: string)
        let stringRange    = nsString.range(of: string)
        let substringRange = nsString.range(of: substring)
        
        // Add attributes to the string
        let attributedString = NSMutableAttributedString(string: string)
        attributedString.addAttribute(.font, value: UIFont(name: "SF Pro Text", size: 16)!, range: stringRange)
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: stringRange)
        
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 18, weight: .semibold), range: substringRange)
        attributedString.addAttribute(.foregroundColor, value: Constants.Color.primary, range: substringRange)
        attributedString.addAttribute(.link, value: path, range: substringRange)
        
        return attributedString
        
    }
    
}
