//
//  MapView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import GoogleMaps
import GooglePlaces

// MARK: - Location Model

struct Location: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let type: LocationType
    let openingHours: String
    let website: String?
    let acceptedItems: [String]
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}

enum LocationType {
    case containerDeposit
    case glass
    case ewaste
}

// MARK: - Helper Functions

func markerColor(for type: LocationType) -> UIColor {
    switch type {
    case .containerDeposit:
        return UIColor(Color.brandSkyBlue) // Use brand sky blue for CDS
    case .glass:
        return UIColor.purple // Keep purple for glass
    case .ewaste:
        return UIColor.green // Keep green for e-waste
    }
}

// MARK: - Google Maps View

struct GoogleMapView: UIViewRepresentable {
    @Binding var selectedLocation: Location?
    let locations: [Location]
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(
            withLatitude: GoogleMapsConfig.defaultLatitude,
            longitude: GoogleMapsConfig.defaultLongitude,
            zoom: GoogleMapsConfig.defaultZoom
        )
        
        let mapView = GMSMapView()
        mapView.camera = camera
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
        
        // Add markers with subtle entrance animation
        for (index, location) in locations.enumerated() {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            marker.title = location.name
            marker.snippet = location.address
            marker.icon = createCustomMarker(for: location.type)
            marker.userData = location
            
            // Add marker with a slight delay for staggered appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                marker.map = mapView
            }
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
        
        // Add new markers with subtle entrance animation
        for (index, location) in locations.enumerated() {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )
            marker.title = location.name
            marker.snippet = location.address
            marker.icon = createCustomMarker(for: location.type)
            marker.userData = location
            
            // Add marker with a slight delay for staggered appearance
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                marker.map = mapView
            }
        }
        
        // Fit camera to show all locations if there are any
        if !locations.isEmpty {
            fitCameraToLocations(mapView: mapView, locations: locations)
        }
    }
    
    private func fitCameraToLocations(mapView: GMSMapView, locations: [Location]) {
        guard !locations.isEmpty else { return }
        
        if locations.count == 1 {
            // For single location, center on it with a good zoom level
            let location = locations[0]
            let camera = GMSCameraPosition.camera(
                withLatitude: location.latitude,
                longitude: location.longitude,
                zoom: 15.0  // Increased zoom for better detail view
            )
            
            // Smooth animation with duration
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.2)  // Longer animation for single location
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
            
            // Add some padding around the bounds
            let update = GMSCameraUpdate.fit(bounds, withPadding: 60.0)  // Increased padding
            
            // Smooth animation with duration
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.8)  // Shorter animation for bounds fitting
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            mapView.animate(with: update)
            CATransaction.commit()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private func createCustomMarker(for type: LocationType) -> UIImage? {
        // Use Google Maps default colored marker icons
        switch type {
        case .ewaste:
            return GMSMarker.markerImage(with: .green)
        case .glass:
            return GMSMarker.markerImage(with: .purple)
        case .containerDeposit:
            return GMSMarker.markerImage(with: .blue)
        }
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
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

// MARK: - Map View

struct MapView: View {
    @Binding var showingMapDetail: Bool
    @Binding var selectedLocation: Location?
    @State private var selectedFilter = 0 // 0: E-Waste, 1: Glass
    let initialFilter: Int?
    
    init(showingMapDetail: Binding<Bool>, selectedLocation: Binding<Location?>, initialFilter: Int? = nil) {
        self._showingMapDetail = showingMapDetail
        self._selectedLocation = selectedLocation
        self.initialFilter = initialFilter
    }
    
    // Real Ballarat waste dropoff locations
    private let allLocations: [Location] = [
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
    
    private var filteredLocations: [Location] {
        switch selectedFilter {
        case 0:
            return allLocations.filter { $0.type == .ewaste }
        case 1:
            return allLocations.filter { $0.type == .glass }
        default:
            return allLocations.filter { $0.type != .containerDeposit }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Map")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.brandVeryDarkBlue)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            // Google Maps Area
            GoogleMapView(selectedLocation: $selectedLocation, locations: filteredLocations)
                .frame(height: 250)
                .padding(.horizontal, 20)
                .onChange(of: selectedLocation) { oldValue, newValue in
                    if newValue != nil {
                        showingMapDetail = true
                    }
                }
            
            // Filter Tabs
            HStack(spacing: 0) {
                FilterTabButton(
                    title: "E-Waste",
                    isSelected: selectedFilter == 0,
                    isFirst: true,
                    isLast: false
                ) {
                    selectedFilter = 0
                }
                
                FilterTabButton(
                    title: "Glass",
                    isSelected: selectedFilter == 1,
                    isFirst: false,
                    isLast: false
                ) {
                    selectedFilter = 1
                }
                
                // CDS Website Link Button
                Button(action: {
                    if let url = URL(string: "https://cdsvic.org.au/locations") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.system(size: 12))
                        Text("CDS")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(Color.brandSkyBlue.opacity(0.1))
                    .overlay(
                        Rectangle()
                            .stroke(Color.brandSkyBlue.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            // Location List Header
            HStack {
                Text("Locations (\(filteredLocations.count))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color.brandVeryDarkBlue)
            Spacer()
                if filteredLocations.count > 4 {
                    Text("Scroll for more")
                        .font(.system(size: 12))
                        .foregroundColor(Color.brandMutedBlue)
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 8)
            
            // Location List
            ScrollView(.vertical, showsIndicators: true) {
                LazyVStack(spacing: 8) {
                    ForEach(filteredLocations) { location in
                        Button(action: {
                            selectedLocation = location
                            showingMapDetail = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(location.name)
                                        .font(.system(size: 16))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color.brandVeryDarkBlue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text(location.address)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.brandMutedBlue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color.brandMutedBlue)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.brandWhite)
                            .overlay(
                                Rectangle()
                                    .fill(Color.brandMutedBlue.opacity(0.2))
                                    .frame(height: 1),
                                alignment: .bottom
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Bottom spacing for better scrolling experience
                    Spacer(minLength: 20)
                }
                .padding(.bottom, 100) // Safe area padding
            }
            .padding(.horizontal, 20)
        }
        .background(Color.brandWhite)
        .onAppear {
            // Set initial filter if provided
            if let initialFilter = initialFilter {
                selectedFilter = initialFilter
            }
        }
    }
}

struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let isFirst: Bool
    let isLast: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? Color.brandWhite : Color.brandVeryDarkBlue)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(isSelected ? Color.brandSkyBlue : Color.clear)
                .overlay(
                    Rectangle()
                        .stroke(Color.brandSkyBlue, lineWidth: 1)
                )
                .clipShape(
                    Rectangle()
                        .inset(by: 0)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Map Detail View

struct MapDetailView: View {
    @Binding var showingMapDetail: Bool
    let location: Location
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: {
                    showingMapDetail = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.brandSkyBlue)
                        .font(.title2)
                }
                
                Spacer()
                
                Text("Location Details")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Spacer()
                
                // Invisible spacer for centering
                Image(systemName: "chevron.left")
                    .foregroundColor(Color.clear)
                    .font(.title2)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            // Google Maps Area for Detail View
            GoogleMapView(selectedLocation: .constant(nil), locations: [location])
            .frame(height: 280)
            .padding(.horizontal, 20)
            
            // Location Details
            VStack(alignment: .leading, spacing: 16) {
                Text(location.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Address: \(location.address)")
                        .font(.system(size: 14))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Opening Hours:")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.top, 8)
                    
                    Text(location.openingHours)
                        .font(.system(size: 13))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    if let website = location.website {
                        HStack(spacing: 20) {
                            Button(action: {
                                if let url = URL(string: website) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "globe")
                                    Text("Visit Website")
                                }
                                .font(.caption)
                                .foregroundColor(Color.brandSkyBlue)
                            }
                            
                            Button(action: {
                                // Open in Google Maps
                                let address = location.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "https://maps.google.com/?q=\(address)") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "location")
                                    Text("Directions")
                                }
                                .font(.caption)
                                .foregroundColor(Color.brandSkyBlue)
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    Text("Accepted Items:")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.top, 12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(location.acceptedItems, id: \.self) { item in
                            Text("• \(item)")
                                .font(.system(size: 13))
                                .foregroundColor(Color.brandVeryDarkBlue)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.brandWhite)
    }
}
