//
//  InitialCollectionViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-09-02.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit

struct InitialPage {
    
    var text: String
    var image: UIImage
    
}

class InitialCollectionViewCell: UICollectionViewCell {
    
    // MARK: IBOutlet Properties
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var pageNum: Int?
    var pageInfo = [InitialPage(text: "Welcome to KeepIt!\rThe Easiest Way to Keep Your Stuff", image: UIImage(named: "PurpleKey")!),
                    InitialPage(text: "Track your wallet, keys,\rand anything else", image: UIImage()),
                    InitialPage(text: "Find everything where\ryou had it last", image: UIImage())]
    
    // MARK: - Initialization Methods
    func setAttributedText() {
        
        // Cheack that the pageNum isn't nil
        guard let index = pageNum else { return }
        
        // Create an attributed string
        let attributedText = NSMutableAttributedString(string: pageInfo[index].text)
        let nsString = NSString(string: attributedText.string)
        
        // Switch over the pageNum to set the properties
        switch index {
        case 0:
            
            // Set the attributes of the string for the 0th page
            let line1Range = nsString.range(of: "Welcome to KeepIt!")
            let line2Range = nsString.range(of: "The Easiest Way to Keep Your Stuff")
            
            attributedText.addAttribute(.font, value: UIFont(name: "SFProText-Medium", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .medium), range: line1Range)
            attributedText.addAttribute(.foregroundColor, value: Constants.Color.primary.cgColor, range: line1Range)
            attributedText.addAttribute(.font, value: UIFont(name: "SFProText-Italic", size: 16) ?? UIFont.italicSystemFont(ofSize: 16), range: line2Range)
            attributedText.addAttribute(.foregroundColor, value: UIColor.gray.cgColor, range: line2Range)
            
        case 1:
            
            // Set the attributes of the string for the 1st page
            let range = nsString.range(of: "Track your wallet, keys,\rand anything else")
            
            attributedText.addAttribute(.font, value: UIFont(name: "TrebuchetMS", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .medium), range: range)
            attributedText.addAttribute(.foregroundColor, value: UIColor.darkGray, range: range)
            
            
        default:
            
            // Set the attributes of the string for the 2nd page
            let range = nsString.range(of: "Find everything where\ryou had it last")
            
            attributedText.addAttribute(.font, value: UIFont(name: "TrebuchetMS", size: 24) ?? UIFont.systemFont(ofSize: 24, weight: .medium), range: range)
            attributedText.addAttribute(.foregroundColor, value: UIColor.darkGray, range: range)
        
        }
        
        // Set the top label to be the attributed text
        topLabel.attributedText = attributedText
        topLabel.adjustsFontSizeToFitWidth = true
        
    }

}
