//
//  AddItemViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-06-22.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

protocol AddItemProtocol {
    
    func itemAdded(item: Item)
    
}

class AddItemViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet var dimView: UIView!
    
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var movementLabel: UILabel!
    @IBOutlet weak var movementSegmentedDisplay: UISegmentedControl!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationSegmentedDisplay: UISegmentedControl!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    // MARK: - AddItemViewController Properties
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var newItem = Item()
    var itemCoordinates: [Double]?
    var delegate: AddItemProtocol?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the dimView
        dimView.backgroundColor = UIColor.clear
        
        // Setup the FloatingView
        floatingView.backgroundColor     = Constants.FLOATING_VIEW_COLOR
        floatingView.layer.cornerRadius  = Constants.GENERAL_CORNER_RADIUS
        floatingViewWidth.constant       = Constants.ADD_ITEM_VIEW_WIDTH
        floatingViewHeight.constant      = Constants.ADD_ITEM_VIEW_HEIGHT
        floatingViewYConstraint.constant = UIScreen.main.bounds.height
        
        // Setup the navigationBar
        navigationBar.layer.cornerRadius = Constants.GENERAL_CORNER_RADIUS
        navigationBar.clipsToBounds      = true
        
        // Setup the itemNameTextField
        itemNameTextField.delegate = self

        // Setup the mapView
        mapViewHeight.constant    = 0
        mapView.layer.borderColor = Constants.PRIMARY_COLOR.cgColor
        mapView.layer.borderWidth = 1
        mapView.delegate          = self
        checkLocationServices()
        
        // Setup the button
        addItemButton.layer.cornerRadius = Constants.BUTTON_CORNER_RADIUS
        addItemButton.backgroundColor    = Constants.PRIMARY_COLOR
        activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Slide in the floating view
        slideViewIn()
        
    }
    
    // MARK: - IBAction Properties
    @IBAction func movementSegmentChanged(_ sender: UISegmentedControl) {
        
        // Lower the keyboard
        itemNameTextField.resignFirstResponder()
        
        // Retrieve the item info
        retrieveItemInfo()
    }
    
    @IBAction func locationSegmentChanged(_ sender: UISegmentedControl) {
        
        // Lower the keyboard
        itemNameTextField.resignFirstResponder()
        
        if locationSegmentedDisplay.selectedSegmentIndex == 0 {
            
            UIView.animate(withDuration: 0.3) {
                self.floatingViewHeight.constant -= 200
                self.mapViewHeight.constant = 0
                self.view.layoutIfNeeded()
            }
            
        }
        else {
            
            UIView.animate(withDuration: 0.3) {
                self.floatingViewHeight.constant += 200
                self.mapViewHeight.constant = 200
                self.view.layoutIfNeeded()
            }
            
        }
        
        // Pull the users information
        retrieveItemInfo()
        
    }
    
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Make the dimViewClear and then dismiss the view
        slideViewOut()
        
    }
    
    @IBAction func itemNameTextFieldEditing(_ sender: UITextField) {
        
        // Check to see if the button should be activated
        retrieveItemInfo()
        
    }
    
    @IBAction func addItemButtonTapped(_ sender: UIButton) {
        
        let item = Item(name: newItem.name!,
                        mostRecentLocation: newItem.mostRecentLocation!,
                        isMovedOften: newItem.isMovedOften!)
        
        // Append the item the usersItems array
        Shared.userItems.append(item)
        
        // Get a reference to the users items
        db.collection(Constants.USERS_KEY).document(Auth.auth().currentUser!.email!).collection(Constants.ITEMS_KEY).addDocument(data:
            [Constants.ITEM_NAME_KEY: newItem.name!,
             Constants.ITEM_MOVEMENT_KEY: newItem.isMovedOften!,
             Constants.ITEM_LOCATION_KEY: newItem.mostRecentLocation!])
        
        // Tell the delegate that an item was added
        delegate?.itemAdded(item: item)
        
        // Slide out the FloatingView
        slideViewOut()
        
    }
    
    @IBAction func mapViewHeld(_ sender: UILongPressGestureRecognizer) {
        
        // Lower the keyboard
        itemNameTextField.resignFirstResponder()
        
        // Get the location of the touch in the mapView and convert it to a coordinate
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        
        // Create an annotation
        let annotation        = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title      = "Item"
        
        // Remova all previous annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        itemCoordinates = [annotation.coordinate.latitude, annotation.coordinate.longitude] as [Double]?
        
        // Check to see if the button should be activated
        retrieveItemInfo()
    }
}

// MARK: - Animation Methods
extension AddItemViewController {
    
    func slideViewIn() {
        
        UIView.animate(withDuration: 0.2, animations: {
            
            // Fade in the dimView
            self.dimView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 180/255)
            
        }) { (true) in
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                // Slide in the FloatingView
                self.floatingViewYConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
    }
    
    func slideViewOut() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            // Slide out the FloatingView
            self.floatingViewYConstraint.constant = UIScreen.main.bounds.height
            self.view.layoutIfNeeded()
            
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                
                // Fade out the dimView
                self.dimView.backgroundColor = UIColor.clear
                
            }, completion: { (true) in
                
                // Dismiss the viewController
                self.dismiss(animated: false, completion: nil)
                
            })
        }
        
    }
    
}

// MARK: - Helper Methods
extension AddItemViewController {
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            break
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            break
        case .restricted:
            // Show an alert
            break
        case .denied:
            // Show alert that tells how to turn on location services
            break
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
                                                 latitudinalMeters: Constants.REGION_IN_METERS / 10,
                                                 longitudinalMeters: Constants.REGION_IN_METERS / 10)
            mapView.setRegion(region, animated: false)
        }
        
    }
    
    func activateButton (isActivated: Bool, color: UIColor) {
        
        addItemButton.isEnabled       = isActivated
        addItemButton.backgroundColor = color
        
    }
    
    func retrieveItemInfo() {
        
        // Pull the items information
        newItem.name = itemNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check that the text field isn't empty
        guard newItem.name != nil && newItem.name!.count > 0 else {
            activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
            return
        }
        
        if locationSegmentedDisplay.selectedSegmentIndex == 0 {
            
            // Check that location services are on
            guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == .authorizedAlways else {
                    
                    // TODO: Show a message saying that the user must activate location services
                    
                    activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
                    return
            }
            
            // Check the users location
            newItem.mostRecentLocation = [locationManager.location!.coordinate.latitude,
                                          locationManager.location!.coordinate.longitude] as [Double]?
            
        }
        else {
            
            // Check that the user has placed an annotation
            guard itemCoordinates != nil else {
                activateButton(isActivated: false, color: Constants.INACTIVE_BUTTON_COLOR)
                return
            }
            
            // Get the coordinate of an annotation that the user placed
            newItem.mostRecentLocation = itemCoordinates
            
        }
        
        // Get information about how often the item is moved
        if movementSegmentedDisplay.selectedSegmentIndex == 0 {
            newItem.isMovedOften = true
        }
        else {
            newItem.isMovedOften = false
        }
        
        activateButton(isActivated: true, color: Constants.PRIMARY_COLOR)
        
    }
    
}

// MARK: - Methods Conforming to CLLocationManagerDelegate
extension AddItemViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Check that the location isn't nil
        guard let locations = locations.last else { return }
        
        // Get the center and the region
        let center = CLLocationCoordinate2D(latitude: locations.coordinate.latitude, longitude: locations.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        // Set the mapview
        mapView.setRegion(region, animated: false)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

extension AddItemViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        
        guard annotation.title != "My Location" else { return annotationView }
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        annotationView?.image          = UIImage(named: "ItemAnnotation")
        annotationView?.isDraggable    = true
        annotationView?.canShowCallout = false
        
        return annotationView
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        // If ending then update the coordinates
        if newState == .ending {
            itemCoordinates = [view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude] as [Double]?
        }
        
    }
    
}

extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Lower the keyboard
        textField.resignFirstResponder()
        return true
        
    }
}
