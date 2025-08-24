//
//  MapView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import MapKit

// MARK: - Location Model

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let type: LocationType
    let openingHours: String
    let website: String?
    let acceptedItems: [String]
}

enum LocationType {
    case containerDeposit
    case glass
    case ewaste
}

// MARK: - Helper Functions

func markerColor(for type: LocationType) -> Color {
    switch type {
    case .containerDeposit:
        return .blue
    case .glass:
        return .green
    case .ewaste:
        return .orange
    }
}

// MARK: - Map View

struct MapView: View {
    @Binding var showingMapDetail: Bool
    @Binding var selectedLocation: Location?
    @State private var selectedFilter = 0 // 0: Container Deposit, 1: Glass, 2: E-Waste
    
    // Sample locations data
    private let allLocations: [Location] = [
        Location(
            name: "CDS Vic Alfred Square",
            address: "Shop 1/61 Curtis St, Ballarat Central VIC 3350",
            latitude: -37.5622,
            longitude: 143.8503,
            type: .containerDeposit,
            openingHours: "8:00am-7:00pm Daily",
            website: "https://cdsvic.com.au",
            acceptedItems: [
                "Most aluminium, glass, plastic and liquid paperboard (carton) drink containers between 150mL and 3 litres",
                "You can keep the lids on, we recycle them too!",
                "Look for the 10c mark on the drink container label"
            ]
        ),
        Location(
            name: "Glass Recycling Centre",
            address: "123 Main St, Melbourne VIC 3000",
            latitude: -37.8136,
            longitude: 144.9631,
            type: .glass,
            openingHours: "9:00am-5:00pm Mon-Fri",
            website: nil,
            acceptedItems: [
                "All types of glass bottles and jars",
                "Clean glass only - no broken pieces"
            ]
        ),
        Location(
            name: "E-Waste Collection Point",
            address: "456 Tech Ave, Sydney NSW 2000",
            latitude: -33.8688,
            longitude: 151.2093,
            type: .ewaste,
            openingHours: "10:00am-4:00pm Tue-Sat",
            website: "https://ewaste.com.au",
            acceptedItems: [
                "Computers, laptops, and tablets",
                "Mobile phones and chargers",
                "Televisions and monitors",
                "Small household electronics"
            ]
        )
    ]
    
    private var filteredLocations: [Location] {
        switch selectedFilter {
        case 0:
            return allLocations.filter { $0.type == .containerDeposit }
        case 1:
            return allLocations.filter { $0.type == .glass }
        case 2:
            return allLocations.filter { $0.type == .ewaste }
        default:
            return allLocations
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
            
            // Map Area (Apple Maps)
            Map {
                ForEach(filteredLocations) { location in
                    Annotation(location.name, coordinate: CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )) {
                        // Custom marker based on type
                        Circle()
                            .fill(markerColor(for: location.type))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedLocation = location
                            }
                    }
                }
            }
            .mapStyle(.standard)
            .frame(height: 250)
            .padding(.horizontal, 20)
            
            // Filter Tabs
            HStack(spacing: 0) {
                FilterTabButton(
                    title: "Container Deposit Scheme",
                    isSelected: selectedFilter == 0
                ) {
                    selectedFilter = 0
                }
                
                FilterTabButton(
                    title: "Glass",
                    isSelected: selectedFilter == 1
                ) {
                    selectedFilter = 1
                }
                
                FilterTabButton(
                    title: "E-Waste",
                    isSelected: selectedFilter == 2
                ) {
                    selectedFilter = 2
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Location List
            ScrollView {
                VStack(spacing: 8) {
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
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.brandWhite)
        .onAppear {
            // View appeared
        }
    }
    

}

struct FilterTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? Color.brandWhite : Color.brandVeryDarkBlue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.brandSkyBlue : Color.clear)
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.brandSkyBlue, lineWidth: 1)
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
            .padding(.bottom, 20)
            
            // Map Area (Apple Maps)
            Map {
                Annotation(location.name, coordinate: CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )) {
                    Circle()
                        .fill(markerColor(for: location.type))
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                }
            }
            .mapStyle(.standard)
            .frame(height: 200)
            .padding(.horizontal, 20)
            
            Spacer()
            
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
                                // Open in Apple Maps
                                let address = location.address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                if let url = URL(string: "http://maps.apple.com/?address=\(address)") {
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
