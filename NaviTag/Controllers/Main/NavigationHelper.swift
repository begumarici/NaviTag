//
//  NavigationHelper.swift
//  NaviTag
//
//  Created by Begüm Arıcı on 13.02.2025.
//

import UIKit
import MapKit

class NavigationHelper {
    static func openGoogleMaps(latitude: Double, longitude: Double) {
        let googleMapsURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        if let url = URL(string: googleMapsURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    static func openAppleMaps(latitude: Double, longitude: Double) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
