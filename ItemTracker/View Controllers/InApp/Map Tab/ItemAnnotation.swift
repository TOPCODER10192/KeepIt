//
//  ItemAnnotation.swift
//  ItemTracker
//
//  Created by Bree Chelle on 2019-07-05.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit

class ItemAnnotationView: MKAnnotationView {
    
    func setSublayer(item: Item) {
        
        // Set the frame for the annotation view
        let annotationFrame = CGRect(x: -Constants.View.Width.annotation / 2, y: -Constants.View.Height.annotation / 2,
                                     width: Constants.View.Width.annotation, height: Constants.View.Height.annotation)
            
        // Initialize an image view
        let imageView = UIImageView(frame: annotationFrame)
        
        // Set properties of the image view
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius  = Constants.View.Width.annotation / 2
        imageView.layer.borderColor   = Constants.Color.primary.cgColor
        imageView.layer.borderWidth   = 2
        imageView.layer.masksToBounds = true
            
        // If the item has a URL but the image hasn't been downloaded
        if let url = URL(string: item.imageURL) {
            // Download the image
            imageView.sd_setImage(with: url)
        }
                // Otherwise use a default image
        else {
            imageView.image = UIImage(named: "Key Icon")
        }
            
        // Add the subview to the annotation view
        self.addSubview(imageView)
            
    }
    
    func setCallout() {
        
        // Offset the callout to point to the top of the annotation
        self.calloutOffset = CGPoint(x: 0, y: -Constants.View.Height.annotation / 2)
        
        // Allow the annotationView to show a callout if tapped
        self.canShowCallout = true
        
    }

}
