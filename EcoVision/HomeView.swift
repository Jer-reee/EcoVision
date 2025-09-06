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
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 8) {
                Text("EcoVision")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Text("A smarter way to sort waste in Ballarat")
                    .font(.subheadline)
                    .foregroundColor(Color.brandMutedBlue)
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Waste Categories Grid
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    // Top-left: Household Waste
                    WasteCategoryView(
                        title: "Household Waste",
                        imageName: "Red Bin",
                        color: .red
                    )
                    
                    // Vertical divider
                    Rectangle()
                        .fill(Color.brandSkyBlue)
                        .frame(width: 1)
                    
                    // Top-right: Mixed Recycling
                    WasteCategoryView(
                        title: "Mixed Recycling",
                        imageName: "Yellow Bin",
                        color: .yellow
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
                        color: .green
                    )
                    
                    // Vertical divider
                    Rectangle()
                        .fill(Color.brandSkyBlue)
                        .frame(width: 1)
                    
                    // Bottom-right: Glass Recycling
                    WasteCategoryView(
                        title: "Glass Recycling",
                        imageName: "Purple Bin",
                        color: .purple
                    )
                }
            }
            .frame(height: 300)
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Call to Action Section
            VStack(spacing: 14) {
                Text("Click below to start sorting!")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Image(systemName: "chevron.down")
                    .foregroundColor(Color.brandSkyBlue)
                    .font(.title2)
                
                Button(action: {
                    showingActionSheet = true
                }) {
                    Image("Camera")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color.brandWhite)
                        
                }
            }
            .padding(.bottom, 80)
        }
        .background(Color.brandWhite)
    }
}
