//
//  MapViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

final class MapViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var prevAnnotationButton: UIButton!
    @IBOutlet weak var nextAnnotationButton: UIButton!
    
    // MARK: - AddItemViewController Properties
    let locationManager = CLLocationManager()
    var itemIndex: Int = -1
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check the user's location services
        checkLocationServices()
        
        // Setup the map search bar
        mapSearchBar.layer.borderWidth = 1
        mapSearchBar.layer.borderColor = Constants.Color.primary.cgColor
        mapSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        mapSearchBar.layer.cornerRadius = Constants.View.CornerRadius.standard
        
        mapSearchBar.delegate = self
        
        // Setup the prev and next annotation buttons
        prevAnnotationButton.layer.cornerRadius = Constants.View.CornerRadius.button
        prevAnnotationButton.layer.borderWidth  = 1
        prevAnnotationButton.layer.borderColor  = Constants.Color.primary.cgColor
        
        nextAnnotationButton.layer.cornerRadius = Constants.View.CornerRadius.button
        nextAnnotationButton.layer.borderWidth  = 1
        nextAnnotationButton.layer.borderColor  = Constants.Color.primary.cgColor
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Remove all mapView Annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // Setup the mapView
        mapViewBottomConstraint.constant = self.tabBarController!.tabBar.frame.height
        mapView.delegate = self
        
        // Iterate through all the items to create annotations
        for item in Stored.userItems {
            
            // Initialize an MKPoint Annotation
            let annotation = MKPointAnnotation()
            
            // Set the properties of the annotation
            annotation.coordinate.latitude = item.mostRecentLocation[0] as CLLocationDegrees
            annotation.coordinate.longitude = item.mostRecentLocation[1] as CLLocationDegrees
            annotation.title = item.name
            annotation.subtitle = item.lastUpdateDate
            
            // Add the annotation to the app
            mapView.addAnnotation(annotation)
        }
        
    }
    
    // MARK: - IBAction Methods:
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        // Instantiate a view controller and check that it isn't nil
        let addItemVC = storyboard?.instantiateViewController(withIdentifier: Constants.ID.VC.addItem) as? AddItemViewController
        guard addItemVC != nil else { return }
        
        // Set self as delegate
        addItemVC?.delegate = self
        
        // Set the presentation style and present
        addItemVC!.modalPresentationStyle = .overCurrentContext
        present(addItemVC!, animated: false, completion: nil)
        
    }
    
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        
        // If no items then return
        guard Stored.userItems.count != 0 else {
            return
        }
        
        // If only 1 item then center over it
        guard Stored.userItems.count != 1 || mapView.selectedAnnotations.count != 1 else {
            centerMapOnItem(annotation: <#T##MKAnnotation#>)
            return
        }
        
        // Decrement the item index
        itemIndex -= 1
        
        // If the index is negative then loop it to the end of the array
        if itemIndex < 0 {
            itemIndex = mapView.annotations.count - 1
        }
        
        // If the annotation is an MKUserLocation then skip over it
        if mapView.annotations[itemIndex] is MKUserLocation {
            itemIndex -= 1
        }
        
        // Center the map over the item
        centerMapOnItem(annotation: mapView.annotations[itemIndex])
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        // If only one item and its selected or 0 items, then return
        guard (Stored.userItems.count != 1 || mapView.selectedAnnotations.count != 1) && Stored.userItems.count != 0 else {
            return
        }
        
        // Increment the index
        itemIndex = (itemIndex + 1) % mapView.annotations.count
        
        // If the annotation is an MKUserLocation then skip over it
        if mapView.annotations[itemIndex] is MKUserLocation {
            itemIndex = (itemIndex + 1) % mapView.annotations.count
        }
        
        // Center the map over the item
        centerMapOnItem(annotation: mapView.annotations[itemIndex])
        
    }
    
    
}

// MARK: - Helper Methods
extension MapViewController {
    
    func centerMapOnItem(annotation: MKAnnotation) {
        
        // Get the region
        let region = MKCoordinateRegion.init(center: annotation.coordinate,
                                             latitudinalMeters: Constants.Map.regionInMeters,
                                             longitudinalMeters: Constants.Map.regionInMeters)
        
        // Set the region
        mapView.setRegion(region, animated: true)
        
        // Select the annotation
        mapView.selectAnnotation(annotation, animated: true)
        
        
        
    }
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            
        // Case if its not determined
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            
        // Case if no authorization
        case .restricted, .denied:
            mapView.showsUserLocation = false
            
        @unknown default:
            break
        }
        
    }
    
    func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationServices() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            // Let the user know that they have to turn location services on
        }
        
    }
    
    func centerViewOnUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: Constants.Map.regionInMeters,
                                                 longitudinalMeters: Constants.Map.regionInMeters)
            mapView.setRegion(region, animated: false)
        }
        
    }
    
}

// MARK: Methods Conforming to CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Check that the location isn't nil
        guard let locations = locations.last else { return }
        
        // Get the center and the region
        let center = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center,
                                             latitudinalMeters: Constants.Map.regionInMeters,
                                             longitudinalMeters: Constants.Map.regionInMeters)
        
        // Set the mapview
        mapView.setRegion(region, animated: false)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

// MARK: - Methods that conform to MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Chack that the annotation is an MKPointAnnotation
        guard annotation is MKPointAnnotation else { return nil }
        
        // Deque an annotation view for an item
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.ID.Annotation.item)
        
        // Create an annotation view for the item if none exist
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: Constants.ID.Annotation.item)
        }
        
        // Set the frame for the annotation view
        let annotationFrame = CGRect(x: -Constants.View.Width.annotation / 2, y: -Constants.View.Height.annotation / 2,
                                     width: Constants.View.Width.annotation, height: Constants.View.Height.annotation)
        
        // Iterate through all the items
        for item in Stored.userItems {
            
            // If the annotation title matches the item name then set the image
            if annotation.title == item.name {
                
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
                    imageView.sd_setImage(with: url) { (image, error, cacheType, url) in
                        
                        // Set the image
                        imageView.image = image
                        
                    }
                    
                }
                // Otherwise use a default image
                else {
                    imageView.image = UIImage(named: "Key Icon")
                }
                
                // Add the subview to the annotation view
                annotationView?.addSubview(imageView)
                annotationView?.calloutOffset = CGPoint(x: 0, y: -Constants.View.Height.annotation / 2)
                
            }
            
        }
        
        // Allow the annotationView to show a callout if tapped
        annotationView?.canShowCallout = true
        
        // Return the annotationView
        return annotationView
            
        
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        // Iterate through all the annotation views
        for annotationView in views {
            
            // If the annotation is of type MKUserLocation then disable the callout
            if annotationView.annotation is MKUserLocation {
                annotationView.canShowCallout = false
            }
        }
    }
    
}

// MARK: - UISearchBarDelegate Methods
extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Lower the keyboard
        searchBar.resignFirstResponder()
        
        // Iterate through all the annotations
        for annotation in mapView.annotations {
        
            // Skip over annotation if it is the user location
            if annotation is MKUserLocation { continue }
            
            // If the text matches the annotation, then center the map on that annotation
            if searchBar.text?.uppercased() == annotation.title!?.uppercased() {
                centerMapOnItem(annotation: annotation)
            }
            
        }
        
    }
    
}

// MARK: - AddItemProtocol Methods
extension MapViewController: AddItemProtocol {
    
    func itemAdded(item: Item) {
        
        // Initialize an annotation
        let annotation = MKPointAnnotation()
        
        // Setup the annotation
        annotation.coordinate.latitude  = item.mostRecentLocation[0] as CLLocationDegrees
        annotation.coordinate.longitude = item.mostRecentLocation[1] as CLLocationDegrees
        annotation.title                = item.name
        annotation.subtitle             = item.lastUpdateDate
        
        // Add the annotation to the map
        mapView.addAnnotation(annotation)
        
    }
    
}
