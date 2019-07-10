//
//  SelectedItemViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-07.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

class SelectedItemViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var itemImageButton: UIButton!
    
    @IBOutlet weak var itemNameTextField: UITextField!
    
    // MARK: - Properties
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard item != nil else { return }

        // Setup the map view
        mapView.delegate = self
        mapView.showsUserLocation = false
        addItemAnnotation()
        
        
        // Setup the image button
        if let url = URL(string: item!.imageURL) {
            setImage(url: url)
        }
        
        itemImageButton.isEnabled          = false
        itemImageButton.clipsToBounds      = true
        itemImageButton.layer.cornerRadius = itemImageButton.bounds.width / 2
        itemImageButton.layer.borderWidth  = 3
        itemImageButton.layer.borderColor  = Constants.Color.primary.cgColor
        itemImageButton.contentMode        = .scaleAspectFill
        
        // Setup the item label
        itemNameTextField.text = item!.name
        
    }

}

// MARK: - Methods used to setup the view
extension SelectedItemViewController {
    
    func setImage(url: URL) {
        
        itemImageButton.sd_setImage(with: url, for: UIControl.State.disabled) { (image, error, cacheType, url) in
            
            
        }
        
    }
    
}

// MARK: - Map Methods
extension SelectedItemViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check that the annotation can be cast to type MKPointAnnotation
        guard annotation is MKPointAnnotation else { return nil }
        
        // Deque a reusable Annotation View
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.ID.Annotation.item)
        
        // If the annotation view is nil, then create it
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.ID.Annotation.item)
        }
        
        // Set the image, draggability, and ability to show a callout for the annotation
        annotationView?.image          = UIImage(named: "ItemAnnotation")
        annotationView?.isDraggable    = true
        annotationView?.canShowCallout = false
        
        // Return the annotation
        return annotationView
        
    }
    
    func addItemAnnotation() {
        
        let annotation = MKPointAnnotation()
        
        // Set the properties of the annotation
        annotation.coordinate.latitude = item!.mostRecentLocation[0] as CLLocationDegrees
        annotation.coordinate.longitude = item!.mostRecentLocation[1] as CLLocationDegrees
        
        mapView.addAnnotation(annotation)
        
        centerMapOnItem(annotation: annotation)
        
    }
    
    func centerMapOnItem(annotation: MKPointAnnotation) {
        
        let center = annotation.coordinate
        let region = MKCoordinateRegion.init(center: center, span: Constants.Map.defaultSpan)
        mapView.setRegion(region, animated: true)
        
    }
    
}
