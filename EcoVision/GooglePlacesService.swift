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
        
        print("🔍 GOOGLE PLACES SEARCH STARTED:")
        print("📝 Query: \(query)")
        if let location = location {
            print("📍 Location: \(location.latitude), \(location.longitude)")
        } else {
            print("📍 Location: Default Ballarat")
        }
        
        isLoading = true
        errorMessage = nil
        
        // Set place properties to focus on addresses with more details for residential filtering
        let placeProperties: [String] = [
            "name",
            "formattedAddress",
            "coordinate",
            "placeID",
            "addressComponents",
            "types"
        ]
        
        let request = GMSPlaceSearchByTextRequest(textQuery: query, placeProperties: placeProperties)
        
        // Set location bias to Ballarat area (defaults to Ballarat, Victoria)
        if let location = location {
            request.locationBias = GMSPlaceCircularLocationOption(location, 30000.0) // 30km radius
        } else {
            // Default to Ballarat, Victoria, Australia
            let ballaratLocation = CLLocationCoordinate2D(latitude: -37.5622, longitude: 143.8503)
            request.locationBias = GMSPlaceCircularLocationOption(ballaratLocation, 30000.0)
        }
        
        // Remove location restriction for now to avoid API issues
        // request.locationRestriction = GMSPlaceRectangularLocationOption(
        //     CLLocationCoordinate2D(latitude: -38.5, longitude: 140.0), // Southwest corner
        //     CLLocationCoordinate2D(latitude: -36.0, longitude: 150.0)  // Northeast corner
        // )
        
        placesClient.searchByText(with: request) { [weak self] results, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = "Search failed: \(error.localizedDescription)"
                    print("❌ Google Places search error: \(error)")
                    print("❌ Error details: \(error)")
                    if let nsError = error as NSError? {
                        print("❌ Error domain: \(nsError.domain)")
                        print("❌ Error code: \(nsError.code)")
                        print("❌ Error userInfo: \(nsError.userInfo)")
                    }
                    return
                }
                
                guard let results = results else {
                    print("❌ No results returned from Google Places API")
                    self?.searchResults = []
                    return
                }
                
                print("📊 Raw results count: \(results.count)")
                
                // Filter and format results for residential addresses in Ballarat area
                let filteredResults = results.compactMap { place -> PlaceResult? in
                    guard let formattedAddress = place.formattedAddress,
                          let addressComponents = place.addressComponents,
                          let types = place.types else {
                        return nil
                    }
                    
                    // Filter for residential addresses only
                    let isResidential = types.contains("street_address") || 
                                       types.contains("premise") || 
                                       types.contains("subpremise")
                    
                    // Check if it's in Ballarat area
                    let isInBallarat = addressComponents.contains { component in
                        component.name.lowercased().contains("ballarat") ||
                        (component.shortName?.lowercased().contains("ballarat") ?? false)
                    }
                    
                    let addressContainsBallarat = formattedAddress.lowercased().contains("ballarat")
                    
                    guard isResidential && (isInBallarat || addressContainsBallarat) else {
                        print("🚫 Filtered out: \(formattedAddress) - Residential: \(isResidential), InBallarat: \(isInBallarat)")
                        return nil
                    }
                    
                    // Expand abbreviations in the address
                    let expandedAddress = self.expandAddressAbbreviations(formattedAddress)
                    
                    print("✅ Accepted: \(expandedAddress)")
                    
                    return PlaceResult(
                        placeID: place.placeID ?? "",
                        name: place.name ?? "",
                        address: expandedAddress,
                        coordinate: place.coordinate
                    )
                }
                
                // If no results after filtering, try with less restrictive filtering
                if filteredResults.isEmpty && !results.isEmpty {
                    print("⚠️ No results after filtering, trying less restrictive approach...")
                    
                    let fallbackResults = results.prefix(5).compactMap { place -> PlaceResult? in
                        guard let formattedAddress = place.formattedAddress else { return nil }
                        
                        // Just check if address contains "Ballarat" or is in Victoria
                        let isRelevant = formattedAddress.lowercased().contains("ballarat") ||
                                       formattedAddress.lowercased().contains("victoria") ||
                                       formattedAddress.lowercased().contains("vic")
                        
                        guard isRelevant else { return nil }
                        
                        // Expand abbreviations in fallback results too
                        let expandedAddress = self.expandAddressAbbreviations(formattedAddress)
                        
                        return PlaceResult(
                            placeID: place.placeID ?? "",
                            name: place.name ?? "",
                            address: expandedAddress,
                            coordinate: place.coordinate
                        )
                    }
                    
                    self?.searchResults = Array(fallbackResults)
                    print("✅ Fallback found \(self?.searchResults.count ?? 0) address results")
                } else {
                    self?.searchResults = filteredResults
                    print("✅ Found \(self?.searchResults.count ?? 0) address results")
                }
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
    
    // MARK: - Address Formatting
    
    private func expandAddressAbbreviations(_ address: String) -> String {
        var expandedAddress = address
        
        // Common Australian address abbreviations to expand
        let abbreviations: [String: String] = [
            "St": "Street",
            "Ave": "Avenue", 
            "Rd": "Road",
            "Dr": "Drive",
            "Ct": "Court",
            "Pl": "Place",
            "Cres": "Crescent",
            "Pde": "Parade",
            "Tce": "Terrace",
            "Cl": "Close",
            "Way": "Way",
            "Ln": "Lane",
            "Blvd": "Boulevard",
            "Hwy": "Highway",
            "Fwy": "Freeway",
            "Pkwy": "Parkway",
            "Sq": "Square",
            "Cct": "Circuit",
            "Vw": "View",
            "Hts": "Heights",
            "Gdn": "Garden",
            "Pk": "Park",
            "Est": "Estate",
            "Vlg": "Village",
            "Mews": "Mews",
            "Grn": "Green",
            "Cmn": "Common",
            "Rise": "Rise",
            "Hill": "Hill",
            "Vale": "Vale",
            "Grove": "Grove",
            "Walk": "Walk",
            "Path": "Path",
            "Track": "Track",
            "Trail": "Trail",
            "VIC": "Victoria",
            "Vic": "Victoria",
            "NSW": "New South Wales",
            "QLD": "Queensland",
            "SA": "South Australia",
            "WA": "Western Australia",
            "TAS": "Tasmania",
            "NT": "Northern Territory",
            "ACT": "Australian Capital Territory"
        ]
        
        // Replace abbreviations with full words
        for (abbrev, full) in abbreviations {
            // Use word boundaries to avoid partial matches
            let pattern = "\\b\(abbrev)\\b"
            expandedAddress = expandedAddress.replacingOccurrences(
                of: pattern,
                with: full,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return expandedAddress
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
