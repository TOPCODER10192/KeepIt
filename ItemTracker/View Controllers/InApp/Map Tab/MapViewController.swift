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
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    
    @IBOutlet weak var addHotSpotButton: RoundedButton!
    
    @IBOutlet weak var zoomToUserButton: RoundedButton!
    @IBOutlet weak var prevAnnotationButton: UIButton!
    @IBOutlet weak var nextAnnotationButton: UIButton!
    
    // MARK: - AddItemViewController Properties
    let locationManager = CLLocationManager()
    var itemIndex: Int = -1
    
    // MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the navigationBar
        navigationBar.tintColor = Constants.Color.primary
        
        // Setup the mapView
        mapView.delegate                        = self
        mapView.tintColor                       = Constants.Color.primary
        
        // Setup the map search bar
        mapSearchBar.layer.borderWidth          = 1
        mapSearchBar.layer.borderColor          = Constants.Color.primary.cgColor
        mapSearchBar.delegate                   = self
        mapSearchBar.tintColor                  = Constants.Color.primary
        mapSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        // Setup the addHotSpot button
        addHotSpotButton.activateButton(isActivated: true, color: Constants.Color.primary)
        addHotSpotButton.isHidden = Stored.geoFences.count >= 20
        
        // Setup the zoom to user button
        zoomToUserButton.layer.borderWidth      = 1
        zoomToUserButton.layer.borderColor      = Constants.Color.primary.cgColor
        zoomToUserButton.tintColor              = Constants.Color.primary
        
        // Setup the prev and next annotation buttons
        prevAnnotationButton.layer.borderWidth  = 1
        prevAnnotationButton.layer.borderColor  = Constants.Color.primary.cgColor
        prevAnnotationButton.tintColor          = Constants.Color.primary
        
        nextAnnotationButton.layer.borderWidth  = 1
        nextAnnotationButton.layer.borderColor  = Constants.Color.primary.cgColor
        nextAnnotationButton.tintColor          = Constants.Color.primary
        
        // Check the location services
        setupLocationManager()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the maps annotations
        reloadAnnotations()
        
        // Set the maps geofences
        reloadGeoFences()
        
    }
    
    // MARK: - IBAction Methods
    @IBAction func zoomToUserButtonTapped(_ sender: RoundedButton) {
        
        centerMapOnUser(span: Constants.Map.defaultSpan)
    
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the add item vc
        loadVC(ID: Constants.ID.VC.singleItem,
                       sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                       animate:  false)
        
    }
    
    @IBAction func updateLocationButtonTapped(_ sender: UIBarButtonItem) {
        
        guard Stored.userItems.count > 0 else {
            presentNoItemsAlert()
            return
        }
        
        // Load the update location vc
        loadVC(ID: Constants.ID.VC.updateLocation,
                       sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                       animate: false)
        
    }
    
    @IBAction func addHotSpotButtonTapped(_ sender: RoundedButton) {
        
        loadVC(ID: Constants.ID.VC.addHotSpot,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animate: false)
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the settings VC
        loadVC(ID: Constants.ID.VC.settings,
                       sb: UIStoryboard(name: Constants.ID.Storyboard.settings, bundle: .main),
                       animate: true)
        
        
    }
    
    @IBAction func prevButtonTapped(_ sender: UIButton) {
        
        // If no items then return
        guard Stored.userItems.count != 0 else {
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
            
            if itemIndex < 0 {
                itemIndex = mapView.annotations.count - 1
            }
            
        }
        
        // Center the map over the item
        centerMapOnItem(annotation: mapView.annotations[itemIndex], span: mapView.region.span)
        
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
        // If no items, then return
        guard Stored.userItems.count != 0 else {
            return
        }
        
        // Increment the index
        itemIndex = (itemIndex + 1) % mapView.annotations.count
        
        // If the annotation is an MKUserLocation then skip over it
        if mapView.annotations[itemIndex] is MKUserLocation {
            itemIndex = (itemIndex + 1) % mapView.annotations.count
        }
        
        // Center the map over the item
        centerMapOnItem(annotation: mapView.annotations[itemIndex], span: mapView.region.span)
        
    }
    
}

// MARK: - Map Methods
extension MapViewController: UISearchBarDelegate, MKMapViewDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Lower the keyboard
        searchBar.resignFirstResponder()
        
        // Iterate through all the annotations
        for annotation in mapView.annotations {
            
            // Skip over annotation if it is the user location
            if annotation is MKUserLocation { continue }
            
            // If the text matches the annotation, then center the map on that annotation
            if searchBar.text?.uppercased() == annotation.title!?.uppercased() {
                centerMapOnItem(annotation: annotation, span: Constants.Map.defaultSpan)
            }
            
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Chack that the annotation is an MKPointAnnotation
        guard annotation is MKPointAnnotation else { return nil }
        
        // Deque an annotation view for an item
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: Constants.ID.Annotation.item) as? ItemAnnotationView ??
                             ItemAnnotationView(annotation: annotation, reuseIdentifier: Constants.ID.Annotation.item)
        
        
        // Iterate through all the items
        for item in Stored.userItems {
            
            // If the annotation title matches the item name then set the sublayer for the annotation to match the item
            if annotation.title == item.name {
                
                annotationView.setSublayer(item: item)
                
            }
            
        }
        
        // Sets the callout for the annotationView
        annotationView.setCallout()
        
        // Return the annotationView
        return annotationView
        
        
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        // Iterate through all the annotation views
        for annotationView in views {
            
            // If the annotation is of type MKUserLocation then disable the callout
            if annotationView.annotation is MKUserLocation {
                annotationView.canShowCallout = false
                return
            }
            
        }
    }
    
    func centerMapOnItem(annotation: MKAnnotation, span: MKCoordinateSpan) {
        
        // Get the region
        let region = MKCoordinateRegion.init(center: annotation.coordinate, span: span)
        
        // Set the region
        mapView.setRegion(region, animated: true)
        
        // Select the annotation
        mapView.selectAnnotation(annotation, animated: true)
        
    }
    
    func centerMapOnUser(span: MKCoordinateSpan) {
        
        // Get the users location
        let location = locationManager.location?.coordinate
        guard location != nil else { return }
        
        // Get the center and the region
        let center = location!
        let region = MKCoordinateRegion.init(center: center, span: span)
        
        // Set the region
        mapView.setRegion(region, animated: true)
        
    }
    
    func drawGeoFence(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        
        let circle = MKCircle(center: center, radius: radius)
        mapView.addOverlay(circle)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Check if the overlay can be cast as an MKCircle
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        circleRenderer.strokeColor = Constants.Color.primary
        circleRenderer.lineWidth   = 5
        circleRenderer.fillColor   = Constants.Color.primary
        circleRenderer.alpha       = 0.5
        
        return circleRenderer
    }
    
    func reloadGeoFences() {
        
        for geofence in Stored.geoFences {
            
            geoFenceAdded(geofence: geofence)
            
        }
        
    }
    
    func region(with geoFence: GeoFence) -> CLCircularRegion {
        
        // Set the region for the geofence
        let latitude = geoFence.centreCoordinate[0] as CLLocationDegrees
        let longitude = geoFence.centreCoordinate[1] as CLLocationDegrees
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = CLCircularRegion(center: center,
                                      radius: geoFence.radius,
                                      identifier: geoFence.name)
        
        // Get the notification conditions for the geofence
        region.notifyOnEntry = geoFence.triggerOnEntrance
        region.notifyOnExit = geoFence.triggerOnExit
        
        return region
    }
    
}

// MARK: - Location Methods
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Check that the location isn't nil
        guard let locations = locations.last else { return }
        
        // Get the region
        let region = MKCoordinateRegion.init(center: locations.coordinate, span: mapView.region.span)
        
        // Set the mapview
        mapView.setRegion(region, animated: false)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        // Check the location authorization
        checkLocationServices()
        
    }
    
    func setupLocationManager() {
        
        // Set the delegate for the location manager and give it high accuracy
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
    }
    
    func checkLocationServices() {
        
        // If the user has location services enabled then setup the location manager and check authorization
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        }
        else {
            
            // Hides the zoom to user button and add hot spot button
            zoomToUserButton.isHidden = true
            addHotSpotButton.isHidden = true
            
            // Let the user know that they have to turn location services on
            present(AlertService.createSettingsAlert(title: "Locations Off", message: "Go to settings to turn your location on", cancelAction: nil),
                    animated: true,
                    completion: nil)
        }
        
    }
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            zoomToUserButton.isHidden = false
            mapView.showsUserLocation = true
            centerMapOnUser(span: Constants.Map.defaultSpan)
            
        // Case if its not determined
        case .notDetermined:
            break
            
        // Case if no authorization
        case .restricted, .denied:
            // Let the user know that they have to turn location services on
            present(AlertService.createSettingsAlert(title: "Locations Off", message: "Go to settings to turn your location on",            cancelAction: nil),
                    animated: true,
                    completion: nil)
            
            addHotSpotButton.isHidden = true
            zoomToUserButton.isHidden = true
            mapView.showsUserLocation = false
            
            // If the user has at least 1 item, center the map over the first one
            guard mapView.annotations.count > 0 else { return }
            centerMapOnItem(annotation: mapView.annotations[0], span: Constants.Map.defaultSpan)
            
        @unknown default:
            break
        }
        
    }
    
    func startMonitoring(geoFence: GeoFence) {
        
        // Check if the device supports geofencing
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) == false {
            present(AlertService.createGeneralAlert(description: "Geofencing Not Available On This Device"),
                    animated: true, completion: nil)
            return
        }
        
        // Check if the user always allows location access
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            
            present(AlertService.createGeneralAlert(description: "Your GeoFence Has Been Saved But Won't Be Activated Until You Turn On Location Access To Always"), animated: true, completion: nil)
            
        }
        
        // Get the fence region for the geofence
        let fenceRegion = region(with: geoFence)
        
        // Start monitoring for the geofence
        locationManager.startMonitoring(for: fenceRegion)
    }
    
    func stopMonitoring(geoFence: GeoFence) {
        
        for region in locationManager.monitoredRegions {
            
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geoFence.name else { continue }
            locationManager.stopMonitoring(for: circularRegion)
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        
        present(AlertService.createGeneralAlert(description: "Monitoring for GeoFence Failed"), animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        present(AlertService.createGeneralAlert(description: "Monitoring for GeoFence Failed"), animated: true, completion: nil)
        
    }

    
}

// MARK: - Custom Protocol Methods
extension MapViewController: SingleItemProtocol, UpdateLocationProtocol, AddGeoFenceProtocol {
    
    func itemSaved(item: Item) {
        
        // Initialize an annotation
        let annotation = MKPointAnnotation()
        
        // Setup the annotation
        annotation.coordinate.latitude  = item.mostRecentLocation[0] as CLLocationDegrees
        annotation.coordinate.longitude = item.mostRecentLocation[1] as CLLocationDegrees
        annotation.title                = item.name
        annotation.subtitle             = item.lastUpdateDate
        
        // Add the annotation to the map and center over it
        mapView.addAnnotation(annotation)
        centerMapOnItem(annotation: annotation, span: Constants.Map.defaultSpan)
        
    }
    
    func itemDeleted() {
        
        // Reload all the annotations on the map
        reloadAnnotations()
        
    }
    
    func reloadAnnotations() {
        // Remove all mapView Annotations
        mapView.removeAnnotations(mapView.annotations)
        
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
    
    func geoFenceAdded(geofence: GeoFence) {
        
        let latitude  = geofence.centreCoordinate[0] as CLLocationDegrees
        let longitude = geofence.centreCoordinate[1] as CLLocationDegrees
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius = geofence.radius as CLLocationDistance
        
        drawGeoFence(center: center, radius: radius)
        startMonitoring(geoFence: geofence)
        
    }
    
}

// MARK: - Helper Methods
extension MapViewController {
    
    func presentNoItemsAlert() {
        
        let noItemsAlert = UIAlertController(title: "No Items",
                                             message: "You're not keeping track of any of your items yet",
                                             preferredStyle: .alert)
        
        noItemsAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        noItemsAlert.addAction(UIAlertAction(title: "Add an Item", style: .default, handler: { (action) in
            
            // Load the Single Item VC
            self.loadVC(ID: Constants.ID.VC.singleItem,
                        sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
                        animate: false)
            
        }))
        
        // Present the noItems alert controller
        present(noItemsAlert, animated: true, completion: nil)
        
    }
    
    func loadVC(ID: String, sb: UIStoryboard, animate: Bool) {
        
        let vc = sb.instantiateViewController(withIdentifier: ID)
        
        if let vc = vc as? SingleItemViewController {
            vc.delegate = self
        }
        else if let vc = vc as? UpdateLocationViewController {
            vc.delegate = self
        }
        else if let vc = vc as? AddHotSpotViewController {
            vc.delegate = self
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: animate, completion: nil)
        
        
    }
    
}
