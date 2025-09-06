//
//  GooglePlacesService.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation
import GooglePlaces
import CoreLocation

// MARK: - Google Places Service

class GooglePlacesService: ObservableObject {
    @Published var searchResults: [PlaceResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let placesClient = GMSPlacesClient.shared()
    
    // MARK: - Search Methods
    
    func searchAddresses(query: String, location: CLLocationCoordinate2D? = nil) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // For now, return mock data to avoid API issues
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.searchResults = [
                PlaceResult(
                    placeID: "mock1",
                    name: "123 Main Street",
                    address: "123 Main Street, Ballarat VIC 3350",
                    coordinate: CLLocationCoordinate2D(latitude: -37.5622, longitude: 143.8503)
                ),
                PlaceResult(
                    placeID: "mock2", 
                    name: "456 Collins Street",
                    address: "456 Collins Street, Ballarat VIC 3350",
                    coordinate: CLLocationCoordinate2D(latitude: -37.5622, longitude: 143.8503)
                )
            ]
        }
    }
    
    func clearResults() {
        searchResults = []
        errorMessage = nil
    }
    
    func cancelRequests() {
        isLoading = false
        searchResults = []
        errorMessage = nil
    }
    
    // MARK: - Cleanup
    
    deinit {
        // Clean up when service is deallocated
        isLoading = false
        searchResults = []
        errorMessage = nil
    }
}

// MARK: - Place Result Model

struct PlaceResult: Identifiable, Hashable {
    let id = UUID()
    let placeID: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(placeID)
    }
    
    static func == (lhs: PlaceResult, rhs: PlaceResult) -> Bool {
        return lhs.placeID == rhs.placeID
    }
}
