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
import GoogleMobileAds

final class MapViewController: UIViewController {

    // MARK: - IBOutlet Properties
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapViewToBottom: NSLayoutConstraint!
    
    @IBOutlet weak var mapSearchBar: UISearchBar!
    
    @IBOutlet weak var addGeoFenceButton: RoundedButton!
    
    @IBOutlet weak var zoomToUserButton: RoundedButton!
    @IBOutlet weak var prevAnnotationButton: UIButton!
    @IBOutlet weak var nextAnnotationButton: UIButton!
    
    var bannerView: GADBannerView!
    
    // MARK: - Properties
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
        mapView.showsUserLocation               = true
        
        // Setup the map search bar
        mapSearchBar.layer.borderWidth          = 1
        mapSearchBar.layer.borderColor          = Constants.Color.primary.cgColor
        mapSearchBar.delegate                   = self
        mapSearchBar.tintColor                  = Constants.Color.primary
        mapSearchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        // Setup the add geo fence button
        addGeoFenceButton.activateButton(isActivated: true, color: Constants.Color.primary)
        addGeoFenceButton.isHidden = Stored.geoFences.count >= 20
        
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
        
        // Setup the ad View
        /*
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.delegate = self
        
        bannerView.adUnitID = "ca-app-pub-1584397833153899/1844990630"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
         */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set the maps annotations
        reloadAnnotations()
        
        // Set the maps geofences
        reloadGeoFences()
        
        // Check location services
        checkLocationServices()
        
    }
    
}

// MARK: - Navigation Bar Methods
extension MapViewController {
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the add item vc
        loadVC(ID: Constants.ID.VC.singleItem,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animate:  false)
        
    }
    
    @IBAction func updateLocationButtonTapped(_ sender: UIBarButtonItem) {
        
        // Check if the user has any items
        guard Stored.userItems.count > 0 else {
            presentNoItemsAlert()
            return
        }
        
        // Load the update location vc
        loadVC(ID: Constants.ID.VC.updateLocation,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animate: false)
        
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIBarButtonItem) {
        
        // Load the settings VC
        loadVC(ID: Constants.ID.VC.settings,
               sb: UIStoryboard(name: Constants.ID.Storyboard.settings, bundle: .main),
               animate: true)
        
        
    }
    
}

// MARK: - Map Button Methods
extension MapViewController {
    
    @IBAction func addGeoFenceButtonTapped(_ sender: RoundedButton) {
        
        // Load the add geoFenceVC
        loadVC(ID: Constants.ID.VC.addGeoFence,
               sb: UIStoryboard(name: Constants.ID.Storyboard.popups, bundle: .main),
               animate: false)
        
    }
    
    @IBAction func zoomToUserButtonTapped(_ sender: RoundedButton) {
        
        // Center the map on the user
        centerMapOnUser(span: Constants.Map.defaultSpan)
        
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
        
        // Check if the search text is empty
        guard let searchText = searchBar.text, searchBar.text!.count > 0 else { return }
        
        // Iterate through all the annotations
        for i in 0 ..< mapView.annotations.count {
            
            // Skip annotation if its user location
            if mapView.annotations[i] is MKUserLocation { continue }
            
            // If the text matches the annotation, then center the map on that annotation
            if searchText.uppercased() == mapView.annotations[i].title!?.uppercased() {
                self.itemIndex = i
                centerMapOnItem(annotation: mapView.annotations[i], span: Constants.Map.defaultSpan)
                return
            }
            
        }
        
        // Show an error if the item couldn't be found
        ProgressService.errorAnimation(text: "You have no item named \"\(searchText)\"")
        
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
        guard let location = locationManager.location?.coordinate else { return }
        
        // Get the center and the region
        let center = location
        let region = MKCoordinateRegion.init(center: center, span: span)
        
        // Set the region
        mapView.setRegion(region, animated: true)
        
    }
    
    func drawGeoFence(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
        
        // Create a circle overlay for the geoFence
        let circle = MKCircle(center: center, radius: radius)
        mapView.addOverlay(circle)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Check if the overlay can be cast as an MKCircle
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
        // Create a circle renderer and set properties for it
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        circleRenderer.strokeColor = Constants.Color.primary
        circleRenderer.lineWidth   = 5
        circleRenderer.fillColor   = Constants.Color.softPrimary
        circleRenderer.alpha       = 0.5
        
        // Return the circle renderer
        return circleRenderer
        
    }
    
    func reloadGeoFences() {
        
        // Remove all the geofences
        mapView.removeOverlays(mapView.overlays)
        
        // Iterate through all the stored geoFences
        for geofence in Stored.geoFences {
            
            geoFenceAdded(geoFence: geofence)
            
        }
        
    }
    
}

// MARK: - Location Methods
extension MapViewController: CLLocationManagerDelegate, AddGeoFenceProtocol {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Check that the location isn't nil
        guard let locations = locations.last else { return }
        
        // Get the region
        let region = MKCoordinateRegion(center: locations.coordinate, span: mapView.region.span)
        
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
            
            // Hides the zoom to user button and add geofence button
            zoomToUserButton.isHidden = true
            
        }
        
    }
    
    func checkLocationAuthorization() {
        
        // Determine the level of authorization the user has given you
        switch CLLocationManager.authorizationStatus() {
            
        // Case if its authorized
        case .authorizedAlways, .authorizedWhenInUse:
            zoomToUserButton.isHidden = false
            centerMapOnUser(span: Constants.Map.defaultSpan)
            
        // Case if its not determined
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
            
        // Case if no authorization
        case .restricted, .denied:
            // Let the user know that they have to turn location services on
            present(AlertService.createSettingsAlert(title: "Locations Off",
                                                     message: "Go to settings to turn your location on",
                                                     cancelAction: nil),
                    animated: true,
                    completion: nil)
            
            // Hide the zoom to user button
            zoomToUserButton.isHidden = true
            
            // If the user has at least 1 item, center the map over the first one
            guard mapView.annotations.count > 0 else { return }
            centerMapOnItem(annotation: mapView.annotations[0], span: Constants.Map.defaultSpan)
            
        @unknown default:
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        
        present(AlertService.createGeneralAlert(description: "Monitoring for GeoFence Failed"), animated: true, completion: nil)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        present(AlertService.createGeneralAlert(description: "Monitoring for GeoFence Failed"), animated: true, completion: nil)
        
    }
    
    func geoFenceAdded(geoFence: GeoFence) {
        
        // Get the latitude and longitude of the geofence center
        let latitude  = geoFence.centreCoordinate[0] as CLLocationDegrees
        let longitude = geoFence.centreCoordinate[1] as CLLocationDegrees
        
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radius = geoFence.radius as CLLocationDistance
        
        // Draw the geofence on the map
        drawGeoFence(center: center, radius: radius)
        
    }

    
}

// MARK: - Custom Protocol Methods
extension MapViewController: SingleItemProtocol, UpdateLocationProtocol, SettingsProtocol {
    
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
    
    func settingsClosed() {
        
        // Reload all the geoFences
        reloadGeoFences()
        
    }
    
    func showWalkthrough() {
        
        // Show the walkthrough
        WalkthroughService.showCTHelp(vc: self)
        
    }
    
}

// MARK: - Helper Methods
extension MapViewController {
    
    func presentNoItemsAlert() {
        
        // Create an alert notifying the user that they have no items
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
        
        // Create a general view control
        let vc = sb.instantiateViewController(withIdentifier: ID)
        
        // See if the view controller can be type cast and set properties if it can
        if let vc = vc as? SingleItemViewController {
            vc.delegate = self
        }
        else if let vc = vc as? UpdateLocationViewController {
            vc.delegate = self
        }
        else if let vc = vc as? AddGeoFenceViewController {
            vc.delegate = self
        }
        else if let vc = vc as? UINavigationController {
            
            if let rootVC = vc.viewControllers[0] as? SettingsTableViewController {
                rootVC.delegate = self
            }
            
        }
        
        // Setup the vc and present it
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: animate, completion: nil)
        
        
    }
    
}

// MARK: - Advertisement Methods
extension MapViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        // Add the banner view to the view
        addBannerViewToView(bannerView)
        
        // Shift the buttons at the bottom of the screen to be relative to the ad
        shiftMapUp()
        
    }
    
    func shiftMapUp() {
        
        // Shift the map bottom to equal the top of the banner view
        self.mapViewToBottom.constant = self.bannerView.bounds.height
        
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        
        if #available(iOS 11.0, *) {
            // In iOS 11, we need to constrain the view to the safe area.
            positionBannerViewFullWidthAtBottomOfSafeArea(bannerView)
        }
        else {
            // In lower iOS versions, safe area is not available so we use
            // bottom layout guide and view edges.
            positionBannerViewFullWidthAtBottomOfView(bannerView)
        }
        
    }
    
    @available (iOS 11, *)
    func positionBannerViewFullWidthAtBottomOfSafeArea(_ bannerView: UIView) {
        // Position the banner. Stick it to the bottom of the Safe Area.
        // Make it constrained to the edges of the safe area.
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            guide.leftAnchor.constraint(equalTo: bannerView.leftAnchor),
            guide.rightAnchor.constraint(equalTo: bannerView.rightAnchor),
            guide.bottomAnchor.constraint(equalTo: bannerView.bottomAnchor)
            ])
    }
    
    func positionBannerViewFullWidthAtBottomOfView(_ bannerView: UIView) {
        
        // Add Constraints to stick it to the bottom of the view and equal width to the screen
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: bannerView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: view.safeAreaLayoutGuide,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0))
    }
    
    
}
