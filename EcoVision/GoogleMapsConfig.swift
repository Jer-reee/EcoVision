//
//  GoogleMapsConfig.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation

struct GoogleMapsConfig {
    // MARK: - Configuration
    
    /// Google Maps API Key
    /// Replace this with your actual Google Maps API key
    /// Get one from: https://console.cloud.google.com/apis/credentials
    static let apiKey = "AIzaSyCU2mgyuv8m41vA9uJWQc0YMMxcG-qF63s"
    
    // MARK: - Initialization
    
    /// Initialize Google Maps services
    /// Call this method in your app's initialization
    static func initialize() {
        // This will be called when we add Google Maps via SPM
        // For now, we'll use a placeholder
        print("Google Maps initialization - will be implemented with SPM")
    }
    
    // MARK: - Default Map Configuration
    
    /// Default camera position (Melbourne, Australia)
    static let defaultLatitude = -37.8136
    static let defaultLongitude = 144.9631
    static let defaultZoom: Float = 10.0
    
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
      }
    ]
    """
}
