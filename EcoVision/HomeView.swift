//
//  HomeView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {
    @Binding var showingActionSheet: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: min(geometry.size.height * 0.08, 60))
                
                // Header Section
                VStack(spacing: min(geometry.size.height * 0.015, 12)) {
                    Text("EcoVision")
                        .font(.system(size: min(geometry.size.width * 0.08, 34), weight: .bold))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("A smarter way to sort waste in Ballarat")
                        .font(.system(size: min(geometry.size.width * 0.04, 15)))
                        .foregroundColor(Color.brandMutedBlue)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, min(geometry.size.height * 0.05, 30))
            
                // Waste Categories Grid
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Top-left: Household Waste
                        WasteCategoryView(
                            title: "Household Waste",
                            imageName: "Red Bin",
                            color: .red,
                            geometry: geometry
                        )
                        
                        // Vertical divider
                        Rectangle()
                            .fill(Color.brandSkyBlue)
                            .frame(width: 1)
                        
                        // Top-right: Mixed Recycling
                        WasteCategoryView(
                            title: "Mixed Recycling",
                            imageName: "Yellow Bin",
                            color: .yellow,
                            geometry: geometry
                        )
                    }
                    
                     // Horizontal divider
                    Rectangle()
                        .fill(Color.brandSkyBlue)
                        .frame(height: 1)
                    
                    HStack(spacing: 0) {
                        // Bottom-left: FOGO
                        WasteCategoryView(
                            title: "FOGO",
                            imageName: "Green Bin",
                            color: .green,
                            geometry: geometry
                        )
                        
                        // Vertical divider
                        Rectangle()
                            .fill(Color.brandSkyBlue)
                            .frame(width: 1)
                        
                        // Bottom-right: Glass Recycling
                        WasteCategoryView(
                            title: "Glass Recycling",
                            imageName: "Purple Bin",
                            color: .purple,
                            geometry: geometry
                        )
                    }
                }
                .frame(height: min(geometry.size.height * 0.35, 280))
                .padding(.horizontal, min(geometry.size.width * 0.05, 20))
            
                Spacer()
                    .frame(height: min(geometry.size.height * 0.08, 50))
            
                // Call to Action Section
                VStack(spacing: min(geometry.size.height * 0.025, 18)) {
                    Text("Click below to start sorting!")
                        .font(.system(size: min(geometry.size.width * 0.05, 20), weight: .medium))
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .multilineTextAlignment(.center)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(Color.brandSkyBlue)
                        .font(.system(size: min(geometry.size.width * 0.06, 22)))
                    
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        Image("Camera")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: min(geometry.size.width * 0.2, 80), height: min(geometry.size.width * 0.2, 80))
                            .foregroundColor(Color.brandWhite)
                            
                    }
                }
                
                Spacer()
                    .frame(height: min(geometry.size.height * 0.08, 60))
            }
            .background(Color.brandWhite)
        }
    }
}
