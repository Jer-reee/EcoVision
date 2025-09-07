//
//  ResultViews.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import MessageUI
import GoogleMaps

// MARK: - AI Recognition Result View

public struct AIResultView: View {
    let aiResult: AIService.WasteClassificationResult
    let selectedImage: UIImage?
    @Binding var showingResult: Bool
    @Binding var showingReportError: Bool
    @Binding var showingManualSearch: Bool
    @State private var selectedLocation: Location? = nil
    @State private var showingMapDetail: Bool = false
    
    private var binColor: Color {
        switch aiResult.binType {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .purple: return .purple
        case .ewaste: return .gray
        case .other: return .black
        }
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollableViewWithFloatingBack(backAction: {
                        showingResult = false
                    }) {
                VStack(spacing: 0) {
                    // Captured Image Display - Full width at top
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: min(geometry.size.height * 0.3, 250))
                    .clipped()
            } else {
                Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(maxWidth: .infinity, maxHeight: min(geometry.size.height * 0.3, 250))
                    .overlay(
                        Image(systemName: "photo")
                                .font(.system(size: min(geometry.size.width * 0.12, 50)))
                                .foregroundColor(.gray.opacity(0.6))
                        )
                    }
                    
                    // Content Section
                    VStack(alignment: .center, spacing: min(geometry.size.height * 0.03, 22)) {
                    // Item Name and Bin Type Row
                     VStack(spacing: min(geometry.size.height * 0.02, 16)) {
                         // Item Name - Centered with safe margins
                         VStack(alignment: .center, spacing: min(geometry.size.height * 0.01, 9)) {
                Text(aiResult.itemName)
                                 .font(.system(size: min(geometry.size.width * 0.08, 28), weight: .bold))
                    .foregroundColor(Color.brandVeryDarkBlue)
                                 .lineLimit(2)
                                 .minimumScaleFactor(0.7)
                                 .multilineTextAlignment(.center)
                                 .padding(.horizontal, min(geometry.size.width * 0.15, 60))
                         }
                         
                         // Bin Icon - Positioned below with proper spacing
                         VStack(alignment: .center, spacing: min(geometry.size.height * 0.008, 6)) {
                             // ALL bin types use the same image display logic
                             let iconSize = min(geometry.size.width * 0.12, 50)
                             if let image = UIImage(named: aiResult.binImageName) {
                                 Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                                      .frame(width: iconSize, height: iconSize)
                             } else {
                                 // ALL bin types use the same fallback
                                 Image(systemName: "trash.fill")
                                     .font(.system(size: iconSize * 0.6))
                                     .foregroundColor(binColor)
                                     .frame(width: iconSize, height: iconSize)
                             }
                             
                        Text(aiResult.binType.rawValue)
                                      .font(.system(size: min(geometry.size.width * 0.03, 12), weight: .medium))
                                      .foregroundColor(binColor)
                                      .lineLimit(1)
                                      .minimumScaleFactor(0.6)
                                      .multilineTextAlignment(.center)
                         }
                     }
                    
                    // Description Section
                    VStack(alignment: .center, spacing: min(geometry.size.height * 0.01, 8)) {
                        Text("Description:")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .medium))
                            .foregroundColor(Color.brandVeryDarkBlue)
                            .multilineTextAlignment(.center)
                
                Text(aiResult.description)
                            .font(.system(size: min(geometry.size.width * 0.04, 16)))
                            .foregroundColor(Color.brandVeryDarkBlue)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
                            .padding(min(geometry.size.width * 0.03, 12))
                            .background(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.03, 12))
                                    .fill(Color.brandWhite)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.03, 12))
                                    .stroke(Color.brandMutedBlue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Disposal Instructions Section
                    VStack(alignment: .center, spacing: min(geometry.size.height * 0.01, 8)) {
                        Text("Disposal instructions:")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .medium))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                
                Text(aiResult.instructions)
                            .font(.system(size: min(geometry.size.width * 0.04, 16)))
                    .foregroundColor(Color.brandVeryDarkBlue)
                            .lineLimit(nil)
                    .multilineTextAlignment(.center)
                            .padding(min(geometry.size.width * 0.03, 12))
                            .background(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.03, 12))
                                    .fill(Color.brandWhite)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    .overlay(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.03, 12))
                                    .stroke(Color.brandMutedBlue.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Action Buttons
                    HStack(spacing: min(geometry.size.width * 0.03, 12)) {
                        // Manual Search Button
                        Button(action: {
                            showingResult = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingManualSearch = true
                            }
                        }) {
                            HStack(spacing: min(geometry.size.width * 0.01, 4)) {
                                Text("Not correct?")
                                    .font(.system(size: min(geometry.size.width * 0.032, 13)))
                                Text("Try searching manually")
                                    .font(.system(size: min(geometry.size.width * 0.032, 13), weight: .medium))
                            }
                            .foregroundColor(Color.brandSkyBlue)
                            .padding(.horizontal, min(geometry.size.width * 0.03, 12))
                            .padding(.vertical, min(geometry.size.height * 0.01, 8))
                            .background(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                    .fill(Color.brandSkyBlue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                            .stroke(Color.brandSkyBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                
                // Report Error Button
                Button(action: {
                    showingResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
                            HStack(spacing: min(geometry.size.width * 0.01, 4)) {
                        Text("Report Error")
                                    .font(.system(size: min(geometry.size.width * 0.032, 13)))
                        Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: min(geometry.size.width * 0.03, 12)))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, min(geometry.size.width * 0.03, 12))
                            .padding(.vertical, min(geometry.size.height * 0.01, 8))
                            .background(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.top, min(geometry.size.height * 0.02, 16))
                    
                    // Map Section for specific bin types
                    if aiResult.binType == .ewaste || aiResult.binType == .purple || aiResult.binType == .other {
                        VStack(alignment: .leading, spacing: min(geometry.size.height * 0.015, 12)) {
                            Text("Collection Points")
                                .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                .foregroundColor(Color.brandVeryDarkBlue)
                            
                            let mapLocations = getMapLocations(for: aiResult.binType)
                            SimpleMapView(
                                selectedLocation: $selectedLocation,
                                locations: mapLocations
                            )
                            .frame(height: min(geometry.size.height * 0.25, 200))
                            .cornerRadius(min(geometry.size.width * 0.02, 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                    .stroke(Color.brandMutedBlue.opacity(0.2), lineWidth: 1)
                            )
                            .onChange(of: selectedLocation) { oldValue, newValue in
                                if newValue != nil {
                                    showingMapDetail = true
                                }
                            }
                        }
                        .padding(.top, min(geometry.size.height * 0.02, 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, min(geometry.size.width * 0.03, 12))
                .padding(.top, min(geometry.size.height * 0.02, 16))
                .padding(.bottom, min(geometry.size.height * 0.12, 100))
            }
        }
        }
        .background(Color.brandWhite)
        .sheet(isPresented: $showingMapDetail) {
            if let location = selectedLocation {
                MapDetailView(showingMapDetail: $showingMapDetail, location: location)
            }
        }
    }
    
    
    // Helper function to get map locations based on bin type
    private func getMapLocations(for binType: AIService.BinType) -> [Location] {
        // Real Ballarat waste dropoff locations
        let allLocations: [Location] = [
            // E-Waste Locations
            Location(
                name: "Ballarat Transfer Station",
                address: "119 Gillies Street South, Alfredton VIC 3350",
                latitude: -37.566762,
                longitude: 143.816442,
                type: .ewaste,
                openingHours: "Mon-Fri: 8:00am-4:00pm; Sat-Sun: 10:00am-4:00pm",
                website: "https://ballarat.vic.gov.au/property/waste-and-recycling/transfer-station",
                acceptedItems: [
                    "Electronic waste and appliances",
                    "Computers, TVs, and mobile devices",
                    "Small household electronics"
                ]
            ),
            Location(
                name: "Garden Recycling Centre",
                address: "154 Learmonth Street, Alfredton VIC 3350",
                latitude: -37.567207,
                longitude: 143.808512,
                type: .ewaste,
                openingHours: "Mon-Sat: 7:30am-4:30pm; Sun: Closed",
                website: "https://gardenrecyclingcentre.com.au",
                acceptedItems: [
                    "Electronic waste collection",
                    "Garden waste and organics",
                    "Recyclable materials"
                ]
            ),
            Location(
                name: "Officeworks Ballarat",
                address: "118-122 Creswick Rd, Ballarat Central VIC 3350",
                latitude: -37.554527,
                longitude: 143.854601,
                type: .ewaste,
                openingHours: "Mon-Fri: 7:00am-7:00pm; Sat: 8:00am-6:00pm; Sun: 9:00am-6:00pm",
                website: "https://www.officeworks.com.au/shop/officeworks/storepage/W364/VIC/Ballarat",
                acceptedItems: [
                    "Computers and laptops",
                    "Printers and ink cartridges",
                    "Mobile phones and accessories",
                    "Small electronic devices"
                ]
            ),
            
            // Glass Recycling Locations
            Location(
                name: "Eastwood Street Shopping Centre",
                address: "7/25 Eastwood Street, Ballarat Central VIC 3350",
                latitude: -37.563391,
                longitude: 143.8612,
                type: .glass,
                openingHours: "24/7 (street bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "Wine and beer bottles",
                    "Food containers (glass only)"
                ]
            ),
            Location(
                name: "Bradlys Lane",
                address: "Bradlys Lane, Bakery Hill VIC 3350",
                latitude: -37.5639932,
                longitude: 143.866433,
                type: .glass,
                openingHours: "24/7 (street bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "All colors of glass accepted",
                    "Clean glass containers only"
                ]
            ),
            Location(
                name: "Midvale Shopping Centre",
                address: "Shop 2, 1174 Geelong Road, Mount Clear VIC 3350",
                latitude: -37.60459137,
                longitude: 143.8668936,
                type: .glass,
                openingHours: "24/7 (shopping centre bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "Wine and spirit bottles",
                    "Food jars and containers"
                ]
            ),
            Location(
                name: "Buninyong Recreation Reserve",
                address: "401 Cornish St, Buninyong VIC 3357",
                latitude: -37.6489583,
                longitude: 143.8901109,
                type: .glass,
                openingHours: "24/7 (park bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "Beverage containers",
                    "Food storage jars"
                ]
            ),
            Location(
                name: "Ballarat Greyhound Racing Club",
                address: "605 Rubicon Street, Sebastopol VIC 3356",
                latitude: -37.5853,
                longitude: 143.8395,
                type: .glass,
                openingHours: "24/7 (club grounds bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "All glass beverage containers",
                    "Clean glass only"
                ]
            ),
            Location(
                name: "Miners Rest General Store",
                address: "200 Howe St, Miners Rest VIC 3352",
                latitude: -37.4836794,
                longitude: 143.8025531,
                type: .glass,
                openingHours: "24/7 (store bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "Wine and beer bottles",
                    "Food containers"
                ]
            ),
            Location(
                name: "Stockland Wendouree Centre",
                address: "330 Gillies Street North, Wendouree VIC 3355",
                latitude: -37.532681,
                longitude: 143.8238531,
                type: .glass,
                openingHours: "24/7 (shopping centre bin)",
                website: "https://ballarat.vic.gov.au/glass-recycling",
                acceptedItems: [
                    "Glass bottles and jars",
                    "Beverage containers",
                    "Food storage containers"
                ]
            )
        ]
        
        switch binType {
        case .ewaste:
            return allLocations.filter { $0.type == .ewaste }
        case .purple:
            // For glass, filter out the most distant locations to keep the map centered on Ballarat
            let glassLocations = allLocations.filter { $0.type == .glass }
            // Filter out locations that are too far from central Ballarat
            return glassLocations.filter { location in
                // Keep locations within reasonable distance of central Ballarat
                let centralBallaratLat = -37.5634
                let centralBallaratLng = 143.8500
                let latDiff = abs(location.latitude - centralBallaratLat)
                let lngDiff = abs(location.longitude - centralBallaratLng)
                // Keep locations within ~0.1 degrees (about 11km) of central Ballarat
                return latDiff < 0.1 && lngDiff < 0.1
            }
        case .other:
            // For "other" bin type, show only the transfer station
            return allLocations.filter { $0.name == "Ballarat Transfer Station" }
        default:
            return []
        }
    }
}



// MARK: - Simple Map View (for result pages)

struct SimpleMapView: UIViewRepresentable {
    @Binding var selectedLocation: Location?
    let locations: [Location]
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView()
        mapView.delegate = context.coordinator
        
        // Apply custom map style
        do {
            if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                // Fallback to inline style
                mapView.mapStyle = try GMSMapStyle(jsonString: GoogleMapsConfig.mapStyleJSON)
            }
        } catch {
            print("Error applying map style: \(error)")
        }
        
        // Add markers
        for location in locations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            marker.title = location.name
            marker.snippet = location.address
            marker.userData = location
            marker.icon = GMSMarker.markerImage(with: markerColor(for: location.type))
            marker.map = mapView
        }
        
        // Fit camera to show all locations if there are any
        if !locations.isEmpty {
            fitCameraToLocations(mapView: mapView, locations: locations)
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Update markers if locations change
        mapView.clear()
        
        for location in locations {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            marker.title = location.name
            marker.snippet = location.address
            marker.userData = location
            marker.icon = GMSMarker.markerImage(with: markerColor(for: location.type))
            marker.map = mapView
        }
        
        // Update camera position
        if !locations.isEmpty {
            fitCameraToLocations(mapView: mapView, locations: locations)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func fitCameraToLocations(mapView: GMSMapView, locations: [Location]) {
        guard !locations.isEmpty else { return }
        
        print("🗺️ Fitting camera to \(locations.count) locations")
        for (index, location) in locations.enumerated() {
            print("🗺️ Location \(index): \(location.name) at \(location.latitude), \(location.longitude)")
        }
        
        if locations.count == 1 {
            // For single location, center on it with a good zoom level
            let location = locations[0]
            print("🗺️ Single location: centering on \(location.name) at \(location.latitude), \(location.longitude)")
            let camera = GMSCameraPosition.camera(
                withLatitude: location.latitude,
                longitude: location.longitude,
                zoom: 15.0
            )
            
            // Smooth animation with duration
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.2)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            mapView.animate(to: camera)
            CATransaction.commit()
            } else {
            // For multiple locations, create bounds to fit all
            var bounds = GMSCoordinateBounds()
            for location in locations {
                let coordinate = CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
                bounds = bounds.includingCoordinate(coordinate)
            }
            
            print("🗺️ Multiple locations: created bounds")
            
            // Check if bounds are too large (locations too spread out)
            let northeast = bounds.northEast
            let southwest = bounds.southWest
            let centerLat = (northeast.latitude + southwest.latitude) / 2
            let centerLng = (northeast.longitude + southwest.longitude) / 2
            let latSpan = northeast.latitude - southwest.latitude
            let lngSpan = northeast.longitude - southwest.longitude
            print("🗺️ Bounds center: \(centerLat), \(centerLng)")
            print("🗺️ Bounds span: \(latSpan), \(lngSpan)")
            
            // If the span is too large (> 0.5 degrees), center on the first few locations instead
            if latSpan > 0.5 || lngSpan > 0.5 {
                print("🗺️ Bounds too large, centering on first 3 locations")
                let limitedLocations = Array(locations.prefix(3))
                var limitedBounds = GMSCoordinateBounds()
                for location in limitedLocations {
                    let coordinate = CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                    limitedBounds = limitedBounds.includingCoordinate(coordinate)
                }
                let update = GMSCameraUpdate.fit(limitedBounds, withPadding: 60.0)
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.8)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
                mapView.animate(with: update)
                CATransaction.commit()
            } else {
                // Add some padding around the bounds
                let update = GMSCameraUpdate.fit(bounds, withPadding: 60.0)
                
                // Smooth animation with duration
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.8)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
                mapView.animate(with: update)
                CATransaction.commit()
            }
        }
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: SimpleMapView
        
        init(_ parent: SimpleMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let location = marker.userData as? Location {
                // Add pin bounce animation when tapped
                animateMarkerBounce(marker: marker)
                parent.selectedLocation = location
            }
            return true
        }
        
        private func animateMarkerBounce(marker: GMSMarker) {
            // Create a bouncing animation for the marker
            let originalPosition = marker.position
            
            // Animate the marker slightly up and down for a bounce effect
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            
            // Move marker slightly north (up on map) for bounce effect
            let bouncePosition = CLLocationCoordinate2D(
                latitude: originalPosition.latitude + 0.0002,
                longitude: originalPosition.longitude
            )
            marker.position = bouncePosition
            
            CATransaction.setCompletionBlock {
                // Bounce back to original position
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.2)
                CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
                marker.position = originalPosition
                CATransaction.commit()
            }
            
            CATransaction.commit()
        }
    }
}

// NoBinResultView removed - all bin types now use AIResultView

// MARK: - Manual Search View

public struct ManualSearchView: View {
    let selectedImage: UIImage?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResult: AIService.WasteClassificationResult?
    @State private var showingSearchResult = false
    @State private var errorMessage: String?
    @Binding var showingSearch: Bool
    @Binding var showingReportError: Bool
    @StateObject private var aiService = AIService()
    
    public var body: some View {
         return ScrollableViewWithFloatingBack(backAction: {
             showingSearch = false
         }) {
        VStack(spacing: 0) {
                 // Captured Image Display - Full width at top
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                     .frame(maxWidth: .infinity, maxHeight: 250)
                    .clipped()
            } else {
                Rectangle()
                         .fill(Color.gray.opacity(0.2))
                         .frame(maxWidth: .infinity, maxHeight: 250)
                    .overlay(
                        Image(systemName: "photo")
                                 .font(.system(size: 50))
                                 .foregroundColor(.gray.opacity(0.6))
                    )
            }
            
            // Manual Search Interface
                VStack(alignment: .center, spacing: 20) {
                    VStack(spacing: 8) {
                Text("Manual Search")
                            .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                            .multilineTextAlignment(.center)
                
                Text("Enter the name of the item you want to recycle")
                            .font(.system(size: 16))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    }
                
                // Search Field
                    VStack(spacing: 16) {
                    TextField("e.g., cardboard box, plastic bottle...", text: $searchText)
                        .font(.system(size: 16))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.brandWhite)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brandMutedBlue.opacity(0.3), lineWidth: 1)
                            )
                        .disabled(isSearching)
                    
                    // Search Button
                    Button(action: {
                        Task {
                            await performTextSearch()
                        }
                    }) {
                            HStack(spacing: 8) {
                            if isSearching {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "magnifyingglass")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                Text(isSearching ? "Searching..." : "Search")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(searchText.isEmpty || isSearching ? Color.gray : Color.brandSkyBlue)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }
                        .disabled(searchText.isEmpty || isSearching)
                    }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                            .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                }
                
                // Report Error Button
                Button(action: {
                    showingSearch = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Report Error")
                                .font(.system(size: 16, weight: .medium))
                        Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 100)
        }
        .background(Color.brandWhite)
        .sheet(isPresented: $showingSearchResult) {
            if let result = searchResult {
                AIResultView(
                    aiResult: result,
                    selectedImage: selectedImage,
                    showingResult: $showingSearchResult,
                        showingReportError: $showingReportError,
                        showingManualSearch: $showingSearch
                )
            }
        }
    }
    
    // MARK: - Search Methods
    
        func performTextSearch() async {
        guard !searchText.isEmpty else { return }
        
        await MainActor.run {
            isSearching = true
            errorMessage = nil
        }
        
            print("🔍 MANUAL SEARCH STARTED:")
        print("📝 Search Text: \(searchText)")
        print("⏳ Processing...")
        
        // Use real AI analysis
        print("🚀 Using AI analysis")
        do {
            let result = try await aiService.analyzeWasteText(searchText)
            
            // Print AI results
            print("🤖 AI CLASSIFICATION RESULTS:")
            print("📦 Item Name: \(result.itemName)")
            print("🗑️ Bin Type: \(result.binType.rawValue)")
            print("🎨 Bin Color: \(result.binColor)")
            print("📝 Description: \(result.description)")
            print("📋 Instructions: \(result.instructions)")
            print("📊 Confidence: \(String(format: "%.2f", result.confidence * 100))%")
            // All bin types use the same format

            print("----------------------------------------")
            
            await MainActor.run {
                isSearching = false
                searchResult = result
                showingSearchResult = true
            }
        } catch {
            print("❌ AI SEARCH ERROR: \(error.localizedDescription)")
            await MainActor.run {
                isSearching = false
                errorMessage = "Search failed: \(error.localizedDescription)"
            }
        }
        
    }
}

    
    // MARK: - Thank You View

    public struct ThankYouView: View {
        @Binding var showingThankYou: Bool
    @Binding var showingReport: Bool
    
        public var body: some View {
            VStack(spacing: 30) {
                Spacer()
                
                // Thank you icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                // Thank you message
                VStack(spacing: 16) {
                    Text("Thank You!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Your feedback has been sent successfully. We appreciate you taking the time to help us improve EcoVision!")
                        .font(.body)
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            
            Spacer()
            
                // Done button
            Button(action: {
                    showingThankYou = false
                showingReport = false
            }) {
                    Text("Done")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.brandSkyBlue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .background(Color.brandWhite)
        }
    }
    
    // MARK: - Email Service
    
    class EmailService: NSObject, ObservableObject, MFMailComposeViewControllerDelegate {
        @Published var isShowingMailView = false
        @Published var emailResult: Result<MFMailComposeResult, Error>? = nil
        
        func sendErrorReport(userEmail: String, problemDescription: String) {
            if MFMailComposeViewController.canSendMail() {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                mailComposer.setToRecipients(["jarrysinszzj@gmail.com"])
                mailComposer.setSubject("EcoVision App - Error Report")
                
                let emailBody = """
        Error Report from EcoVision App
        
        User Email: \(userEmail)
        
        Problem Description:
        \(problemDescription)
        
        ---
        This report was sent from the EcoVision iOS app.
        """
                
                mailComposer.setMessageBody(emailBody, isHTML: false)
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    
                    // Find the topmost presented view controller
                    var topController = rootViewController
                    while let presentedController = topController.presentedViewController {
                        topController = presentedController
                    }
                    
                    topController.present(mailComposer, animated: true)
                }
            } else {
                // Fallback: Show alert that mail is not configured
                emailResult = .failure(NSError(domain: "EmailService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mail is not configured on this device"]))
            }
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
            
            if let error = error {
                emailResult = .failure(error)
            } else {
                emailResult = .success(result)
            }
        }
    }
}
