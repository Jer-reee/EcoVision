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
        
        // Set place properties to focus on addresses
        let placeProperties: [String] = [
            "name",
            "formattedAddress",
            "coordinate",
            "placeID"
        ]
        
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: placeProperties)
        
        // Set location bias if provided (defaults to Melbourne, Australia)
        if let location = location {
            request.locationBias = GMSPlaceCircularLocationOption(location, 50000.0) // 50km radius
        } else {
            // Default to Melbourne, Australia
            let melbourneLocation = CLLocationCoordinate2D(latitude: -37.8136, longitude: 144.9631)
            request.locationBias = GMSPlaceCircularLocationOption(melbourneLocation, 50000.0)
        }
        
        placesClient.searchByText(with: request) { [weak self] results, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Search failed: \(error.localizedDescription)"
                    print("❌ Google Places search error: \(error)")
                    return
                }
                
                guard let results = results else {
                    self?.searchResults = []
                    return
                }
                
                self?.searchResults = results.map { place in
                    PlaceResult(
                        placeID: place.placeID ?? "",
                        name: place.name ?? "",
                        address: place.formattedAddress ?? "",
                        coordinate: place.coordinate
                    )
                }
                
                print("✅ Found \(self?.searchResults.count ?? 0) address results")
            }
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
