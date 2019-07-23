//
//  SingleItemViewController.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-09.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit

import FirebaseFirestore

// MARK: - Add Item Protocol
protocol SingleItemProtocol {
    
    func itemSaved(item: Item)
    func itemDeleted()
    
}

class SingleItemViewController: UIViewController {
    
    // MARK: - IBOutlet Properties
    @IBOutlet var dimView: UIView!
    
    @IBOutlet weak var floatingView: UIView!
    @IBOutlet weak var floatingViewWidth: NSLayoutConstraint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var floatingViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBOutlet weak var itemImageContainerView: UIView!
    @IBOutlet weak var imagePrompt: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    
    @IBOutlet weak var locationPrompt: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapSearchBar: UISearchBar!
    @IBOutlet weak var nearMeButton: UIButton!
    
    @IBOutlet weak var saveItemButton: RoundedButton!
    
    @IBOutlet var imageTapGesture: UITapGestureRecognizer!
    @IBOutlet var mapHoldGesture: UILongPressGestureRecognizer!
    
    // MARK: - Properties
    var delegate: SingleItemProtocol?
    var locationManager = CLLocationManager()
    var inEditMode: Bool   = false
    var imageChanged: Bool = false
    
    var existingItem: Item?
    var existingItemIndex: Int?
    
    var itemName: String?
    var itemCoordinates: [Double]?
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Check the users location services
        checkLocationServices()
        
        // Setup the Dim View
        dimView.backgroundColor                   = UIColor.clear

        // Setup the Floating View
        floatingViewHeight.constant               = Constants.View.Height.singleItem
        floatingViewWidth.constant                = Constants.View.Width.standard
        floatingViewYConstraint.constant          = UIScreen.main.bounds.height
        
        // Setup the Navigation Bar
        navigationBarTitle.title                  = "Add an Item"
        closeButton.tintColor                     = Constants.Color.primary
        editButton.tintColor                      = Constants.Color.primary
        
        // Setup the Item Image Container View
        itemImageContainerView.layer.cornerRadius = (floatingViewHeight.constant - 65) * 0.21505376 / 2
        itemImageContainerView.layer.borderWidth  = 3
        itemImageContainerView.layer.borderColor  = Constants.Color.primary.cgColor
        itemImageContainerView.clipsToBounds      = true
        
        // Setup the Image Prompt
        imagePrompt.adjustsFontSizeToFitWidth     = true
        imagePrompt.text                          = "Tap to Add Image"
        imagePrompt.textColor                     = Constants.Color.primary
        
        // Setup the Item Name Text Field
        itemNameTextField.delegate                = self
        itemNameTextField.tintColor               = Constants.Color.primary
        
        // Setup the Location Prompt
        locationPrompt.text                       = "Place a pin on your items location"
        locationPrompt.adjustsFontSizeToFitWidth  = true
        
        // Setup the Map View
        mapView.delegate                          = self
        mapView.showsUserLocation                 = true
        mapView.layer.borderWidth                 = 1
        mapView.layer.borderColor                 = Constants.Color.primary.cgColor
        mapView.tintColor                         = Constants.Color.primary
        
        // Setup the Map Search Bar
        mapSearchBar.delegate                     = self
        mapSearchBar.layer.borderWidth            = 1
        mapSearchBar.layer.borderColor            = Constants.Color.primary.cgColor
        mapSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        // Setup the Near Me Button
        nearMeButton.backgroundColor              = Constants.Color.primary
        
        // Setup the Save Item Button
        saveItemButton.backgroundColor            = Constants.Color.primary
        saveItemButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
        if existingItem == nil {
            saveItemButton.setTitle("Save Item", for: .disabled)
            saveItemButton.setTitle("Save Item", for: .normal)
        }
        else if existingItem == nil {
            saveItemButton.setTitle("Delete Item", for: .normal)
            saveItemButton.setTitle("Save Changes", for: .disabled)
        }
        
        // Show the items properties
        showItemProperties()
        
        // Set for the edit state
        setEditState()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Slide the view in
        slideViewIn()
        
    }
    
}

// MARK: - Navigation Bar Methods
extension SingleItemViewController {
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        
        // Slide the view out
        slideViewOut()
        
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
        inEditMode = !inEditMode
        
        setEditState()
        
    }
    
}

// MARK: - Image Methods
extension SingleItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func imageViewTapped(_ sender: Any) {
        
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
        
        // If there is an image, add an option to take away the image
        if itemImageView.image != nil {
            
            // Add an action that will clear the image
            actionSheet.addAction(UIAlertAction(title: "No Image", style: .default, handler: { (action) in
                
                // Clear the image
                self.itemImageView.image = nil
                self.imageChanged = true
                
            }))
            
        }
        
        // Add a cancel action to the action sheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // Present the actionSheet
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        // Dismiss the image picker controller
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // Attempt to get the image and check that it isn't nil
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        // Set the background image for the Item Image View and dismiss the picker
        itemImageView.image = image
        imageChanged = true
        picker.dismiss(animated: true, completion: nil)
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

}

// MARK: - Item Name Methods
extension SingleItemViewController: UITextFieldDelegate {
    
    @IBAction func itemNameTextFieldEditing(_ sender: UITextField) {
        
        // Get the text in the field
        itemName = itemNameTextField.text?.trimmingCharacters(in: .whitespaces)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Lower the keyboard
        textField.resignFirstResponder()
        return true
        
    }
    
}

// MARK: - Map Search Button Methods
extension SingleItemViewController: UISearchBarDelegate {
        
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
            
            // Get the coordinates of the location searched
            let latitude = response?.boundingRegion.center.latitude
            let longitude = response?.boundingRegion.center.longitude
            
            // Check that the coordinates are not nil
            guard latitude != nil && longitude != nil else { return }
            let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
            
            // Create the annotation for the item
            self.createAnnotation(coordinate: coordinates, willCenterView: true)

            // Check to see if the item should be activated
            self.checkToActivateButton()
            
        }
        
    }
    
}


// MARK: - Map Methods
extension SingleItemViewController: MKMapViewDelegate {
    
    @IBAction func mapViewHeld(_ sender: UILongPressGestureRecognizer) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Get the location of the touch in the mapView and convert it to a coordinate
        let location = sender.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        itemCoordinates = [coordinate.latitude, coordinate.longitude]
        
        // Add the annotation to the map
        createAnnotation(coordinate: coordinate, willCenterView: false)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    @IBAction func nearMeButtonTapped(_ sender: UIButton) {
        
        // Lower the keyboard
        lowerKeyboard()
        
        // Get the location of the touch in the mapView and convert it to a coordinate
        let coordinate  = locationManager.location!.coordinate
        itemCoordinates = [coordinate.latitude, coordinate.longitude] as [Double]?
        
        // Create an annotation and center the map on it
        createAnnotation(coordinate: coordinate, willCenterView: true)
        
        // Check to see if the button should be activated
        checkToActivateButton()
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Check that the annotation can be cast to type MKPointAnnotation
        guard annotation is MKPointAnnotation else { return nil }
        
        // Deque a reusable Annotation View
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.ID.Annotation.item)
        
        // If the annotation view is nil, then create it
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation,
                                              reuseIdentifier: Constants.ID.Annotation.item)
        }
        
        // Set the image, draggability, and ability to show a callout for the annotation
        annotationView?.image          = UIImage(named: "ItemAnnotation")
        annotationView?.tintColor      = Constants.Color.primary
        annotationView?.canShowCallout = false
        
        if inEditMode == true {
             annotationView?.isDraggable = true
        }
        else {
            annotationView?.isDraggable = false
        }
        
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
            
            itemCoordinates = [view.annotation!.coordinate.latitude, view.annotation!.coordinate.longitude]
            
        }
        
    }
    
    func createAnnotation(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil, willCenterView: Bool) {
        
        // Initialize an annotation
        let annotation = MKPointAnnotation()
        
        // Set properties for the annotation
        annotation.coordinate = coordinate
        annotation.title      = title
        annotation.subtitle   = subtitle
        
        // Add the annotation to the map
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        
        if willCenterView == true {
            centerMapOnAnnotation(annotation: annotation, span: Constants.Map.defaultSpan)
        }
        
        // Update the coordinates
        itemCoordinates = [coordinate.latitude, coordinate.longitude]
        
    }
    
    func centerMapOnAnnotation(annotation: MKAnnotation, span: MKCoordinateSpan) {
        
        // Declare the center
        let center: CLLocationCoordinate2D?
        
        // If user location, then use the user coordinates
        if annotation is MKUserLocation {
            center = locationManager.location?.coordinate
        }
        // Otherwise, it is an item annotation
        else {
            center = annotation.coordinate
        }
        
        // Check that the coordinate isn't nil
        guard center != nil else { return }
        
        // Set the region for the map and center the map on it
        let region = MKCoordinateRegion.init(center: center!, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
}

// MARK: - Location Methods
extension SingleItemViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        
        // Set the delegate and desired accuracy for the location messenger
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationAuthorization() {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways, .authorizedWhenInUse:
            
            if inEditMode == true {
            nearMeButton.isHidden = false
            }
            
            if existingItem == nil {
                centerMapOnAnnotation(annotation: mapView.userLocation, span: Constants.Map.defaultSpan)
            }
            
        case .restricted, .denied, .notDetermined:
            nearMeButton.isHidden = true
            
        @unknown default:
            print("Unknown Authoriztion Status")
        }
        
    }
    
    func checkLocationServices() {
        
        // If the user has location services on then setup the location manager and check the level of authorization
        if CLLocationManager.locationServicesEnabled() {
            
            // Setup the location manager and check the level of authorization the user has given
            setupLocationManager()
            checkLocationAuthorization()
            
        }
        else {
            
            // Hide the Near Me Button
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check the new authorization state
        checkLocationAuthorization()
        
    }
    
}


// MARK: - Animation Methods
extension SingleItemViewController {
    
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
    
    func lowerKeyboard() {
        
        // Resign first responder from both of the text fields
        itemNameTextField.resignFirstResponder()
        mapSearchBar.resignFirstResponder()
        
    }
    
}

// MARK: - Helper Methods
extension SingleItemViewController {
    
    func showItemProperties() {
        
        // If no item exists then exit
        guard existingItem != nil else { return }
        
        // Set the Item Image View
        if let url = URL(string: existingItem!.imageURL) {
            itemImageView.sd_setImage(with: url, completed: nil)
        }
        
        // Set the Item Name Text Field
        itemNameTextField.text = existingItem!.name
        itemName               = existingItem!.name
        
        // Set the Item Location
        var coordinate        = CLLocationCoordinate2D()
        coordinate.latitude   = existingItem!.mostRecentLocation[0]
        coordinate.longitude  = existingItem!.mostRecentLocation[1]
        createAnnotation(coordinate: coordinate, willCenterView: true)
        
    }
    
    func checkToActivateButton() {
        
        // Check that the required properties have been filled
        guard itemName != nil, itemName!.count > 0, itemCoordinates != nil else {
            saveItemButton.activateButton(isActivated: false, color: Constants.Color.inactiveButton)
            return
        }
        
        // Activate the button
        saveItemButton.activateButton(isActivated: true, color: Constants.Color.primary)
        
    }
    
    func setEditState() {
        
        guard existingItem != nil else {
            editButton.isEnabled = false
            editButton.title     = ""
            return
        }
        
        navigationBarTitle.title = existingItem!.name
        
        if inEditMode == true {
            
            editButton.title                  = "Reset"
            
            imageTapGesture.isEnabled         = true
            imagePrompt.text                  = "Tap to Add Image"
            itemNameTextField.isEnabled       = true
            itemNameTextField.borderStyle     = .roundedRect
            itemNameTextField.backgroundColor = UIColor.white
            
            locationPrompt.text               = "Place a pin on your items location"
            
            mapSearchBar.isHidden             = false
            mapHoldGesture.isEnabled          = true
            
            saveItemButton.activateButton(isActivated: true, color: Constants.Color.primary)
            saveItemButton.setTitle("Save Item", for: .normal)
            
            checkLocationAuthorization()
        
        }
        else {
            
            editButton.title                  = "Edit"
            
            imageTapGesture.isEnabled         = false
            imagePrompt.text                  = "No Image"
            itemNameTextField.isEnabled       = false
            itemNameTextField.borderStyle     = .none
            itemNameTextField.backgroundColor = UIColor.clear
            
            locationPrompt.text               = "Your items location is shown below"
            
            mapSearchBar.isHidden             = true
            mapHoldGesture.isEnabled          = false
            nearMeButton.isHidden             = true
            
            saveItemButton.activateButton(isActivated: true, color: Constants.Color.deleteButton)
            saveItemButton.setTitle("Delete Item", for: .normal)
            
            showItemProperties()
            
        }
        
    }
    
    func getTheDate() -> String{
        
        // Create a date formatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        // Extract the string for the current time
        return dateFormatter.string(from: Date())
        
    }
    
}

// MARK: - Save Item Button Methods
extension SingleItemViewController {
    
    @IBAction func saveItemButtonTapped(_ sender: UIButton) {
        
        // Disable the save item button
        saveItemButton.isEnabled = false
        
        // Determine if the user is attempting to delete an item
        if inEditMode == false && existingItem != nil {
            
            // Send a "Are you sure" prompt
            showConfirmationsAlert()
            saveItemButton.isEnabled = true
            return
            
        }
        
        // Delete an image from storge if an item was edited and it had a valid url and the image was changed
        if let item = existingItem {
            if URL(string: item.imageURL) != nil {
                if imageChanged == true {
                    ImageService.deleteImage(itemName: item.name)
                }
            }
        }
        
        // Get the current date and time
        let timeStamp = getTheDate()
        
        // Initialize the item
        var item = Item(withID            : "",
                        withName          : itemName!,
                        withLocation      : itemCoordinates!,
                        withLastUpdateDate: timeStamp,
                        withImageURL      : "")
        
        // If the item existed then maintain its id
        if existingItem != nil {
            item.id = existingItem!.id
        }
        
        // If the image is not nil
        if let image = itemImageView.image {
            
            // Check if the image was changed
            if imageChanged == true {
            
                // Store the new image in firebase storage
                ImageService.storeImage(image: image, itemName: itemName!) { (url) in
                    
                    // Set the items image url and store the item in firestore
                    item.imageURL = url.absoluteString
                    self.storeItem(item: item)
                    
                }
            }
            else {
                
                // Use the existing image url and store the item in firestore
                item.imageURL = existingItem!.imageURL
                self.storeItem(item: item)
                
            }
            
        }
        else {
            
            // The item has no image, so store in firestore
            storeItem(item: item)
            
        }
        
    }
    
    func storeItem(item: Item) {
        
        // Check if the item is new or not
        if existingItem == nil {
            
            // Show a progress animation
            ProgressService.progressAnimation(text: "Trying to Create \(itemName!)")
            
            // Attempt to write a new item to firestore
            FirestoreService.createItem(item: item) { (id, error) in
                
                // Check if the item was successfully added
                guard error == nil else {
                    self.saveItemButton.isEnabled = true
                    ProgressService.errorAnimation(text: "Unable to Create \(self.itemName!)")
                    return
                }
                
                // Show that the process was successful
                ProgressService.successAnimation(text: "Successfully Created \(self.itemName!)")
                
                // Create a replica item and change its id
                var newItem = item
                newItem.id  = id
                
                // Store the item locally
                LocalStorageService.createItem(item: newItem)
                Stored.userItems.append(newItem)
                
                // Tell the delegate the item was written and lower the view
                self.delegate?.itemSaved(item: newItem)
                self.slideViewOut()
                
            }
        }
        else {
            
            // Show a progress animation
            ProgressService.progressAnimation(text: "Trying to Update \(existingItem!.name)")
            
            // Attempt to update the item in firestore
            FirestoreService.updateItem(item: item) { (error) in
                
                // Check that the item was updated successfully
                guard error == nil else {
                    self.saveItemButton.isEnabled = true
                    ProgressService.errorAnimation(text: "Unable to Update \(self.itemName!)")
                    return
                }
                
                // Show that the process was successful
                ProgressService.successAnimation(text: "Successfully Updated \(self.itemName!)")
                
                // Store the item locally
                LocalStorageService.updateItem(item: item, index: self.existingItemIndex!)
                Stored.userItems[self.existingItemIndex!] = item
                
                // Tell the delegate the item was updated and lower the view
                self.delegate?.itemSaved(item: item)
                self.slideViewOut()
                
            }
            
        }
        
    }
    
}

extension SingleItemViewController {
    
    func showConfirmationsAlert() {
        
        // Create an alert for deleting an item
        let areYouSureAlert = UIAlertController(title: "Delete \(existingItem!.name)?", message: nil, preferredStyle: .alert)
        
        // Add actions to the alert
        areYouSureAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        areYouSureAlert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            
            // Start a Progress Animation
            ProgressService.progressAnimation(text: "Trying to Delete \(self.existingItem!.name)")
            
            // Attempt to delete the item from firestore
            FirestoreService.deleteItem(item: self.existingItem!, completion: { (error) in
                
                // Check that the item was deleted successfully
                guard error == nil else {
                    self.saveItemButton.isEnabled = true
                    ProgressService.errorAnimation(text: "Unable to Delete \(self.existingItem!.name)")
                    return
                }
                
                // If the item had an image, then remove it from storage
                if URL(string: self.existingItem!.imageURL) != nil {
                    ImageService.deleteImage(itemName: self.existingItem!.name)
                }
                
                // Show that the process was successful
                ProgressService.successAnimation(text: "Successfully Deleted \(self.existingItem!.name)")
                
                // Save the changes locally
                Stored.userItems.remove(at: self.existingItemIndex!)
                LocalStorageService.deleteItem(index: self.existingItemIndex!)
                
                // Tell the delgate that an item was deleted and slide the view out
                self.delegate?.itemDeleted()
                self.slideViewOut()
                
            })
            
        }))
        
        // Present the alert
        present(areYouSureAlert, animated: true, completion: nil)
        
    }
    
}


