//
//  MapView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - Map View

struct MapView: View {
    @Binding var showingMapDetail: Bool
    @State private var selectedFilter = 0 // 0: Container Deposit, 1: Glass, 2: E-Waste
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Map")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.brandVeryDarkBlue)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            // Map Area (placeholder)
            Rectangle()
                .fill(Color.green.opacity(0.3))
                .overlay(
                    VStack {
                        Text("🗺️")
                            .font(.system(size: 60))
                        Text("Map View\n(Interactive map will be here)")
                            .font(.caption)
                            .foregroundColor(Color.brandMutedBlue)
                            .multilineTextAlignment(.center)
                        
                        // Sample location pins
                        VStack(spacing: 8) {
                            Button("📍 Location Pin 1") {
                                showingMapDetail = true
                            }
                            .foregroundColor(Color.brandSkyBlue)
                            
                            Button("📍 Location Pin 2") {
                                showingMapDetail = true
                            }
                            .foregroundColor(Color.brandSkyBlue)
                        }
                        .padding(.top, 20)
                    }
                )
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
                    ForEach(0..<6, id: \.self) { index in
                        Button(action: {
                            showingMapDetail = true
                        }) {
                            HStack {
                                Text("CDS Vic Alfred Square")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.brandVeryDarkBlue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
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
                
                Text("Map")
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
            
            // Map Area (placeholder)
            Rectangle()
                .fill(Color.green.opacity(0.3))
                .overlay(
                    VStack {
                        Text("🗺️")
                            .font(.system(size: 60))
                        Text("Detailed Map View\n📍 CDS Vic Alfred Square")
                            .font(.caption)
                            .foregroundColor(Color.brandMutedBlue)
                            .multilineTextAlignment(.center)
                    }
                )
                .frame(height: 200)
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Location Details
            VStack(alignment: .leading, spacing: 16) {
                Text("CDS Vic Alfred Square")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Address: Shop 1/61 Curtis St, Ballarat Central VIC 3350")
                        .font(.system(size: 14))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Opening Hours:")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Monday:    8:00am-7:00pm")
                        Text("Tuesday:    8:00am-7:00pm")
                        Text("Wednesday: 8:00am-7:00pm")
                        Text("Thursday:   8:00am-7:00pm")
                        Text("Friday:     8:00am-7:00pm")
                        Text("Saturday:   8:00am-7:00pm")
                        Text("Sunday:     8:00am-7:00pm")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                Text("Visit Website")
                            }
                            .font(.caption)
                            .foregroundColor(Color.brandSkyBlue)
                        }
                        
                        Button(action: {}) {
                            HStack(spacing: 4) {
                                Image(systemName: "location")
                                Text("Directions")
                            }
                            .font(.caption)
                            .foregroundColor(Color.brandSkyBlue)
                        }
                    }
                    .padding(.top, 8)
                    
                    Text("Accepted Items:")
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.top, 12)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("• Most aluminium, glass, plastic and liquid paperboard (carton) drink containers between 150mL and 3 litres are eligible.")
                        Text("• You can keep the lids on, we recycle them too! Look for the 10c mark on the drink container label. It is often located near the barcode.")
                    }
                    .font(.system(size: 13))
                    .foregroundColor(Color.brandVeryDarkBlue)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.brandWhite)
    }
}
