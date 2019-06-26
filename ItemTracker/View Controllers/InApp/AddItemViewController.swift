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
    @IBOutlet weak var addImageButton: UIButton!
    
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
    var delegate: AddItemProtocol?
    
    var itemName: String?
    var itemCoordinates: [Double]?
    var itemMoves: Bool = true
    var itemImage: UIImage?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the dimView
        dimView.backgroundColor = UIColor.clear
        
        // Setup the FloatingView
        floatingView.backgroundColor     = Constants.Color.floatingView
        floatingView.layer.cornerRadius  = Constants.View.CornerRadius.standard
        floatingViewWidth.constant       = Constants.View.Width.standard
        floatingViewHeight.constant      = Constants.View.Height.addItem
        floatingViewYConstraint.constant = UIScreen.main.bounds.height
        
        // Setup the navigationBar
        navigationBar.layer.cornerRadius = Constants.View.CornerRadius.standard
        navigationBar.clipsToBounds      = true
        
        // Setup the itemNameTextField
        itemNameTextField.delegate = self
        
        // Setup the addImageButton
        addImageButton.clipsToBounds      = true
        addImageButton.layer.cornerRadius = addImageButton.frame.width / 2
        addImageButton.layer.borderColor  = Constants.Color.primary.cgColor
        addImageButton.layer.borderWidth  = 1

        // Setup the mapView
        mapViewHeight.constant    = 0
        mapView.layer.borderColor = Constants.Color.primary.cgColor
        mapView.layer.borderWidth = 1
        mapView.delegate          = self
        checkLocationServices()
        readUserCoordinates()
        
        // Setup the button
        addItemButton.layer.cornerRadius = Constants.View.CornerRadius.button
        addItemButton.backgroundColor    = Constants.Color.primary
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Slide in the floating view
        slideViewIn()
        
    }
    
    // MARK: - IBAction Properties
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Make the dimViewClear and then dismiss the view
        slideViewOut()
        
    }
    
    @IBAction func itemNameTextFieldEditing(_ sender: UITextField) {
        
        // Get the text in the field
        itemName = itemNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        checkToActivateButton()
        
    }
    
    @IBAction func addItemImageTapped(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "Add Item Image", message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                self.showImagePicker(type: .camera)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
                self.showImagePicker(type: .photoLibrary)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func movementSegmentChanged(_ sender: UISegmentedControl) {
        
        // Lower the keyboard
        itemNameTextField.resignFirstResponder()
        
        // Set the value based on the segment that is selected
        if movementSegmentedDisplay.selectedSegmentIndex == 0 {
            itemMoves = true
        }
        else if movementSegmentedDisplay.selectedSegmentIndex == 1 {
            itemMoves = false
        }
        
    }
    
    @IBAction func locationSegmentChanged(_ sender: UISegmentedControl) {
        
        // Lower the keyboard
        itemNameTextField.resignFirstResponder()

        if locationSegmentedDisplay.selectedSegmentIndex == 0 {
            
            // Animate the mapView to dissapear
            UIView.animate(withDuration: 0.3) {
                
                // Decrease the view height by 200, set map height to 0
                self.floatingViewHeight.constant -= 200
                self.mapViewHeight.constant = 0
                self.view.layoutIfNeeded()
                
            }
            
            // Read the users coordinates
            readUserCoordinates()
            
        }
            // If the segmentSelected is 1 then show the map
        else if locationSegmentedDisplay.selectedSegmentIndex == 1 {
            
            UIView.animate(withDuration: 0.3) {
                
                // Increase the view height by 200, set map height to 200
                self.floatingViewHeight.constant += 200
                self.mapViewHeight.constant = 200
                self.view.layoutIfNeeded()
                
            }
            
        }
        
        checkToActivateButton()
        
    }
    
    @IBAction func addItemButtonTapped(_ sender: UIButton) {
        let item = Item(name: itemName!,
                        mostRecentLocation: itemCoordinates!,
                        isMovedOften: itemMoves,
                        image: itemImage)
        
        // Append the item the usersItems array and locally store it
        Stored.userItems.append(item)
        LocalStorageService.saveUserItem(item: item)
        
        // Generate a random key
        let itemID = UUID.init().uuidString
        
        // Get a reference to the users items
        let itemRef = db.collection(Constants.Key.User.users).document(Auth.auth().currentUser!.email!).collection(Constants.Key.Item.items).document(itemID)
        
        itemRef.setData([Constants.Key.Item.name: item.name,
                         Constants.Key.Item.movement: item.isMovedOften,
                         Constants.Key.Item.location: item.mostRecentLocation])
        
        if item.image != nil {
            ImageService.storeImage(image: item.image!, itemRef: itemRef)
        }
        
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
        itemCoordinates = [coordinate.latitude, coordinate.longitude] as [Double]?
        
        // Create an annotation
        let annotation        = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title      = "Item"
        
        // Remove all previous annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        checkToActivateButton()
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
    
    func checkToActivateButton() {
        
        // Check that the itemName isn't nil
        guard itemName != nil && itemName!.count > 0  else {
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Check that the user has entered coordinates
        guard itemCoordinates != nil else {
            activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate button
        activateButton(isActivated: true, color: Constants.Color.primary)
        
        
    }
    
    func showImagePicker(type: UIImagePickerController.SourceType) {
        
        let imagePicker        = UIImagePickerController()
        imagePicker.sourceType = type
        imagePicker.delegate   = self
        present(imagePicker, animated: true, completion: nil)
        
    }
    
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
                                                 latitudinalMeters: 1000,
                                                 longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }
        
    }
    
    func activateButton (isActivated: Bool, color: UIColor) {
        
        addItemButton.isEnabled       = isActivated
        addItemButton.backgroundColor = color
        
    }
    
    func readUserCoordinates() {
        
        // Check that location services are on
        guard CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways else {
                
                activateButton(isActivated: false, color: Constants.Color.inactiveButton)
                return
                
        }
        
        // Check the users location
        itemCoordinates = [locationManager.location!.coordinate.latitude,
                           locationManager.location!.coordinate.longitude] as [Double]?
        
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

extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        itemImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        guard itemImage != nil else { return }
            
        addImageButton.setBackgroundImage(itemImage!, for: .normal)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
