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

// MARK: - Add Item Protocol
protocol AddItemProtocol {
    
    func itemAdded(item: Item)
    
}

final class AddItemViewController: UIViewController {

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
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var mapViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addItemButton: UIButton!
    
    // MARK: - AddItemViewController Properties
    let db = Firestore.firestore()
    let locationManager = CLLocationManager()
    var delegate: AddItemProtocol?
    var sameNameError: Bool = false
    
    var itemName: String?
    var itemCoordinates: [Double]?
    var itemMoves: Bool = true
    var itemImage: UIImage?
    var time: String?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the dimView
        dimView.backgroundColor           = UIColor.clear
        
        // Setup the FloatingView
        floatingView.backgroundColor      = Constants.Color.floatingView
        floatingView.layer.cornerRadius   = Constants.View.CornerRadius.standard
        floatingViewWidth.constant        = Constants.View.Width.standard
        floatingViewHeight.constant       = Constants.View.Height.addItem
        floatingViewYConstraint.constant  = UIScreen.main.bounds.height
        
        // Setup the navigationBar
        navigationBar.layer.cornerRadius  = Constants.View.CornerRadius.standard
        navigationBar.clipsToBounds       = true
        
        // Setup the itemNameTextField
        itemNameTextField.delegate        = self
        
        // Setup the addImageButton
        addImageButton.clipsToBounds      = true
        addImageButton.layer.cornerRadius = addImageButton.frame.width / 2
        addImageButton.layer.borderColor  = Constants.Color.primary.cgColor
        addImageButton.layer.borderWidth  = 1

        // Setup the searchBar
        mapSearchBar.alpha                = 0
        mapSearchBar.delegate             = self
        mapSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        // Setup the mapView
        mapViewHeight.constant            = 0
        mapView.layer.borderColor         = Constants.Color.primary.cgColor
        mapView.layer.borderWidth         = 1
        mapView.delegate                  = self
        checkLocationServices()
        readUserCoordinates()
        
        // Setup the addItemButton
        addItemButton.layer.cornerRadius  = Constants.View.CornerRadius.button
        addItemButton.backgroundColor     = Constants.Color.primary
        activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Slide in the floating view
        slideViewIn()
        
    }
    
    // MARK: - IBAction Properties
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Make the dimViewClear and then dismiss the view
        slideViewOut()
        
    }
    
    @IBAction func itemNameTextFieldBeganEditing(_ sender: UITextField) {
        
        if sameNameError == true {
            
            // Reset the error to false
            sameNameError = false
            
            // Change the text field back to its default state
            itemNameTextField.backgroundColor = UIColor.white
            itemNameTextField.text            = ""
            
        }
        
    }
    
    @IBAction func itemNameTextFieldEditing(_ sender: UITextField) {
        
        // Get the text in the field
        itemName = itemNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func addItemImageTapped(_ sender: UIButton) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Initialize an action sheet for the image picker
        let actionSheet = UIAlertController(title: "Add Item Image", message: nil, preferredStyle: .actionSheet)
        
        // If the camera is available then add it to the action sheet
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
                
                // If the action is tapped then go to the users camera
                self.showImagePicker(type: .camera)
                
            }))
            
        }
        
        // If the photo library is available then add it to the action sheet
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            actionSheet.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
                
                // If the action is tapped then go to the users photo library
                self.showImagePicker(type: .photoLibrary)
                
            }))
            
        }
        
        // Add a cancel action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the actionSheet
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    @IBAction func locationSegmentChanged(_ sender: UISegmentedControl) {
        
        // Lower the keyboard
        lowerKeyboard()

        // If the first segment is selected, then the user has selected the "Near Me" Option
        if locationSegmentedDisplay.selectedSegmentIndex == 0 {
            
            UIView.animate(withDuration: 0.3) {
                
                // Decrease the view height by 200, set map height to 0
                self.floatingViewHeight.constant -= Constants.View.Height.smallMap
                self.mapViewHeight.constant       = 0
                self.mapSearchBar.alpha           = 0
                self.view.layoutIfNeeded()
                
            }
            
            // Read the users coordinates
            readUserCoordinates()
            
        }
        // If the second segment is selected, then the user has selected the "Custom Location" Option
        else if locationSegmentedDisplay.selectedSegmentIndex == 1 {
            
            UIView.animate(withDuration: 0.3) {
                
                // Increase the view height by 200, set map height to 200
                self.floatingViewHeight.constant += Constants.View.Height.smallMap
                self.mapViewHeight.constant       = Constants.View.Height.smallMap
                self.mapSearchBar.alpha           = 1
                self.view.layoutIfNeeded()
                
            }
            
            // Update the coordinated of the to the annotation
            updateItemCoordinates()
            
        }
        
        // Check to activate the add item button
        checkToActivateButton()
        
    }
    
    @IBAction func mapViewHeld(_ sender: UILongPressGestureRecognizer) {
        
        // Lower the keyboard
        lowerKeyboard()
        
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
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func movementSegmentChanged(_ sender: UISegmentedControl) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // If the first segment is selected, then the user has selected the "Yes" option
        if movementSegmentedDisplay.selectedSegmentIndex == 0 {
            itemMoves = true
        }
        // If the second segment is selected, then the user has selected the "Yes" option
        else if movementSegmentedDisplay.selectedSegmentIndex == 1 {
            itemMoves = false
        }
        
    }
    
    @IBAction func addItemButtonTapped(_ sender: UIButton) {
        
        // Disable the button
        addItemButton.isEnabled = false
        
        // Check that this item hasn't already been created
        for item in Stored.userItems {
            
            guard itemName!.uppercased() != item.name.uppercased() else {
                
                // Reactivate the button
                addItemButton.isEnabled = true
                
                // Set the same name error to true
                sameNameError = true
                
                // Give the user a reason for the error
                itemNameTextField.backgroundColor = Constants.Color.softError
                itemNameTextField.text            = "\(itemName!) already exists!"
        
                return
            }
            
        }
        
        // Get a string for the date
        getTheDate()
        
        // Get a reference to the users items
        let itemRef = db.collection(Constants.Key.User.users).document(Stored.user!.email).collection(Constants.Key.Item.items).document(itemName!)
        
        // Initialize the item
        var item = Item.init(withName: self.itemName!,
                             withLocation: self.itemCoordinates!,
                             withLastUpdateDate: self.time!,
                             withMovement: self.itemMoves,
                             withImageURL: "")
    
        // If the user took a photo
        if itemImage != nil {
            
            // Store the image in the cloud and then get a download url for it
            ImageService.storeImage(image: itemImage!) { (url) in
                
                // Update the item
                item.imageURL = url.absoluteString
                
                // Append the item the usersItems array and locally store it
                Stored.userItems.append(item)
                LocalStorageService.saveUserItem(item: item, isNew: true)
                UserService.writeItem(item: item, ref: itemRef)
                
                // Tell the delegate that an item was added
                self.delegate?.itemAdded(item: item)
                
                // Slide out the FloatingView
                self.slideViewOut()
                
            }
            
        }
            
        // Otherwise keep the default item
        else {
            
            // Append the item the usersItems array and locally store it
            Stored.userItems.append(item)
            LocalStorageService.saveUserItem(item: item, isNew: true)
            UserService.writeItem(item: item, ref: itemRef)
            
            // Tell the delegate that an item was added
            delegate?.itemAdded(item: item)
            
            // Slide out the FloatingView
            slideViewOut()
            
        }
        
    }
    
}

// MARK: - Animation Methods
extension AddItemViewController {
    
    func slideViewIn() {
        
        // Slide the view in from the botton
        UIView.animate(withDuration: 0.2, animations: {
            
            // First, fade in the dimView
            self.dimView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 180/255)
            
        }) { (true) in
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                
                // Second, slide in the Floating View
                self.floatingViewYConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
    }
    
    func slideViewOut() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            
            // First, slide out the Floating View
            self.floatingViewYConstraint.constant = UIScreen.main.bounds.height
            self.view.layoutIfNeeded()
            
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                
                // Second, fade out the Dim View
                self.dimView.backgroundColor = UIColor.clear
                
            }, completion: { (true) in
                
                // Third, dismiss the VC
                self.dismiss(animated: false, completion: nil)
                
            })
        }
        
    }
    
}

// MARK: - Helper Methods
extension AddItemViewController {
    
    func lowerKeyboard() {
        
        // Resign first responder from both of the text fields
        itemNameTextField.resignFirstResponder()
        mapSearchBar.resignFirstResponder()
        
    }
    
    func getTheDate() {
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Extract the string for the current time
        time = dateFormatter.string(from: Date())
        
    }
    
    
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
        
        // Create an image picker
        let imagePicker        = UIImagePickerController()
        
        // Set the source type and delegate
        imagePicker.sourceType = type
        imagePicker.delegate   = self
        
        // Present the image picker
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func checkLocationAuthorization() {
        
        // Switch over all the options for location authorization
        switch CLLocationManager.authorizationStatus() {
        
        // Case if the user has made there location available
        case .authorizedAlways, .authorizedWhenInUse:
            // Show the users location on the map
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            
        // Case if the user has not selected a permission level
        case .notDetermined:
            // Show a request for location
            locationManager.requestAlwaysAuthorization()
            break
            
        // Case if the user has denied permission
        case .restricted, .denied:
            // Show an alert that says the user won't have access to the near me option
            break
            
        @unknown default:
            break
        }
        
    }
    
    func setupLocationManager() {
        
        // Set the delegate and desired accuracy for the location messenger
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationServices() {
        
        // If the user has location services on then setup the location manager and check the level of authorization
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            // Let the user know that they have to turn location services on
        }
        
    }
    
    func centerViewOnUserLocation() {
        
        // Get the users location
        if let location = locationManager.location?.coordinate {
            
            // Get a region for the map to show
            let region = MKCoordinateRegion.init(center: location,
                                                 latitudinalMeters: 1000,
                                                 longitudinalMeters: 1000)
            
            // Set the region for the map
            mapView.setRegion(region, animated: false)
            
        }
        
    }
    
    func activateButton (isActivated: Bool, color: UIColor) {
        
        // Activate the add item button and change its color
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
    
    func updateItemCoordinates() {
        
        // Iterate through the annotations on the map
        for annotation in mapView.annotations {
            
            // If the annotation can be cast an mkPoint annotation then get the coordinates of the annotation
            if annotation as? MKPointAnnotation != nil {
                itemCoordinates = [annotation.coordinate.latitude, annotation.coordinate.longitude]
                return
            }
            
        }
        
        // If no MKPointAnnotations were found then return nil
        itemCoordinates = nil
        
        
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
        
        // Check the new authorization state
        checkLocationAuthorization()
        
    }
    
}

// MARK: - MKMapViewDelegateMethods
extension AddItemViewController: MKMapViewDelegate {
    
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
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        // Iterate through all the annotation views
        for annotationView in views {
            
            // If the annotation is of type MKUserLocation then disable the callout
            if annotationView.annotation is MKUserLocation {
                annotationView.canShowCallout = false
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        
        // If ending then update the coordinates for the item
        if newState == .ending {
            itemCoordinates = [view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude] as [Double]?
        }
        
    }
    
}

// MARK: - UITextFieldDelegate Methods
extension AddItemViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Lower the keyboard
        textField.resignFirstResponder()
        return true
        
    }
}

// MARK: - UISearchBarDelegate Methods
extension AddItemViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Lower the keyboard
        searchBar.resignFirstResponder()
        
        // Create the search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        // Create an active search based off the search request and start the search
        let activeSearch = MKLocalSearch(request: searchRequest)
        activeSearch.start { (response, error) in
            
            // If the search was unsuccessful then present an error message
            guard response != nil && error == nil else { return }
            
            // Remove annotations on map
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            // Get the coordinates of the location searched
            let latitude = response?.boundingRegion.center.latitude
            let longitude = response?.boundingRegion.center.longitude
            
            // Check that the coordinates are not nil
            guard latitude != nil && longitude != nil else { return }
            
            // Create an annotation for the coordinates found and add it
            let annotation = MKPointAnnotation()
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            annotation.coordinate = CLLocationCoordinate2DMake(coordinates.latitude, coordinates.longitude)
            self.mapView.addAnnotation(annotation)
            
            // Get the region based off the coordinates and set the map
            let region = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
            
            // Update the coordinates of the itemnand then check to activate the button
            self.updateItemCoordinates()
            self.checkToActivateButton()
            
        }
        
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate Methods
extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the image picker controller
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Attempt to get the image and check that it isn't nil
        itemImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard itemImage != nil else { return }
        
        addImageButton.setBackgroundImage(itemImage!, for: .normal)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
