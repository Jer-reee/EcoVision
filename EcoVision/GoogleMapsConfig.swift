//
//  GoogleMapsConfig.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation
import GoogleMaps
import GooglePlaces

struct GoogleMapsConfig {
    // MARK: - Configuration
    
    /// Google Maps API Key
    /// Replace this with your actual Google Maps API key
    /// Get one from: https://console.cloud.google.com/apis/credentials
    static let apiKey = "key"
    
    // MARK: - Initialization
    
    /// Initialize Google Maps services
    /// Call this method in your app's initialization
    static func initialize() {
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
        print("Google Maps initialized successfully")
    }
    
    // MARK: - Default Map Configuration
    
    /// Default camera position (Ballarat, Victoria, Australia)
    static let defaultLatitude = -37.5622
    static let defaultLongitude = 143.8503
    static let defaultZoom: Float = 11.0
    
    // MARK: - Custom Map Style (Optional)
    
    /// Custom map style JSON for a more eco-friendly appearance
    static let mapStyleJSON = """
    [
      {
        "featureType": "landscape",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#f5f5f2"
          }
        ]
      },
      {
        "featureType": "poi.park",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#c5e8b3"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#a2daf2"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#ffffff"
          }
        ]
      },
      {
        "featureType": "poi.business",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#e8f4d9"
          }
        ]
      }
    ]
    """
}
