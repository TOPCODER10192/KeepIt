//
//  MapViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - AddItemViewController Properties
    let locationManager = CLLocationManager()
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check the user's location services
        checkLocationServices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Setup the mapView
        mapViewBottomConstraint.constant = self.tabBarController!.tabBar.frame.height
        mapView.delegate = self
        
        for item in Stored.userItems {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = item.mostRecentLocation[0] as CLLocationDegrees
            annotation.coordinate.longitude = item.mostRecentLocation[1] as CLLocationDegrees
            annotation.title = item.name
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
    
    
}

// MARK: - Helper Methods
extension MapViewController {
    
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
                                                 latitudinalMeters: 10000,
                                                 longitudinalMeters: 10000)
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
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
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
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        guard annotation.title != "My Location" else { return annotationView }
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
    
        for item in Stored.userItems {
            
            if annotation.title == item.name {
                
                let frame = CGRect(x: -Constants.View.Width.annotation / 2,
                                   y: -Constants.View.Width.annotation / 2,
                                   width: Constants.View.Width.annotation,
                                   height: Constants.View.Height.annotation)
                
                if item.image != nil {
                    let imageView = UIImageView(frame: frame)
                    imageView.image = item.image
                    imageView.layer.cornerRadius = imageView.layer.frame.size.width / 2
                    imageView.layer.borderWidth = 2
                    imageView.layer.borderColor = Constants.Color.primary.cgColor
                    imageView.layer.masksToBounds = true
                    imageView.contentMode = .scaleAspectFill
                    annotationView!.addSubview(imageView)
                }
                else {
                    let basicView = UIView(frame: frame)
                    basicView.backgroundColor = UIColor.white
                    basicView.layer.cornerRadius = basicView.layer.frame.size.width / 2
                    basicView.layer.borderWidth = 10
                    basicView.layer.borderColor = Constants.Color.primary.cgColor
                    basicView.layer.masksToBounds = true
                    annotationView!.addSubview(basicView)
                    
                }
                
            }
            
        }
        
        annotationView!.canShowCallout = true
        
    
        //view.calloutOffset = CGPoint(x:  16, y: 16)
        //view.layer.anchorPoint = CGPointMake(16 , 16)
       // view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as! UIView
        
        annotationView?.isDraggable        = false
        annotationView?.canShowCallout     = true
        
        return annotationView
        
    }
    
}

extension MapViewController: AddItemProtocol {
    
    func itemAdded(item: Item) {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude  = item.mostRecentLocation[0] as CLLocationDegrees
        annotation.coordinate.longitude = item.mostRecentLocation[1] as CLLocationDegrees
        annotation.title                = item.name
        mapView.addAnnotation(annotation)
        
    }
    
}
