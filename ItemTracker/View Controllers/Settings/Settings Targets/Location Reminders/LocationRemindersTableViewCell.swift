//
//  LocationRemindersTableViewCell.swift
//  ItemTracker
//
//  Created by Brock Chelle on 2019-07-26.
//  Copyright © 2019 Brock Chelle. All rights reserved.
//

import UIKit
import MapKit

class LocationRemindersTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet Properties
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var entryNotificationLabel: UILabel!
    @IBOutlet weak var exitNotificationLabel: UILabel!

    // MARK: - View Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Setup the map view
        mapView.delegate = self
        mapView.layer.cornerRadius = mapView.bounds.width / 2
        mapView.layer.borderWidth  = 1
        mapView.layer.borderColor  = Constants.Color.primary.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: - Map View Methods
extension LocationRemindersTableViewCell: MKMapViewDelegate {
    
    func centerMapViewOnGeoFence(coordinate: [Double], radius: Double) {
        
        let latitude = coordinate[0] as CLLocationDegrees
        let longitude = coordinate[1] as CLLocationDegrees
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: radius * 4, longitudinalMeters: radius * 4)
        mapView.setRegion(region, animated: false)
        
        drawGeoFence(center: center, radius: radius)
        
    }
    
    func drawGeoFence(center: CLLocationCoordinate2D, radius: CLLocationDistance) {
    
        let circle = MKCircle(center: center, radius: radius)
        mapView.addOverlay(circle)
        
    }
    
    func clearMapOverlays() {
        
        // Clear all the overlays on the map
        self.mapView.removeOverlays(mapView.overlays)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Check if the overlay can be cast as an MKCircle
        guard let circleOverlay = overlay as? MKCircle else { return MKOverlayRenderer() }
        
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
        
        circleRenderer.strokeColor = Constants.Color.primary
        circleRenderer.lineWidth   = 5
        circleRenderer.fillColor   = Constants.Color.softPrimary
        circleRenderer.alpha       = 0.5
        
        return circleRenderer
        
    }
    
}

extension LocationRemindersTableViewCell {
    
    
}
