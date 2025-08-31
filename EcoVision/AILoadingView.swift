//
//  AILoadingView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

struct AILoadingView: View {
    let selectedImage: UIImage?
    @Binding var showingLoading: Bool
    @Binding var showingReportError: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Captured Image Display
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Loading Content
            VStack(spacing: 24) {
                // AI Processing Animation
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.brandSkyBlue.opacity(0.3), lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(Color.brandSkyBlue, lineWidth: 4)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(
                                Animation.linear(duration: 1)
                                    .repeatForever(autoreverses: false),
                                value: UUID()
                            )
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 30))
                            .foregroundColor(Color.brandSkyBlue)
                    }
                    
                    Text("AI Analyzing...")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Our AI is identifying your waste item and finding the best recycling option for Ballarat.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                }
                
                // Processing Steps
                VStack(alignment: .leading, spacing: 12) {
                    ProcessingStep(
                        icon: "eye",
                        title: "Image Analysis",
                        description: "Identifying waste item type",
                        isCompleted: true
                    )
                    
                    ProcessingStep(
                        icon: "brain.head.profile",
                        title: "AI Classification",
                        description: "Determining recycling category",
                        isCompleted: false
                    )
                    
                    ProcessingStep(
                        icon: "leaf",
                        title: "Local Standards",
                        description: "Applying Ballarat recycling rules",
                        isCompleted: false
                    )
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 80)
            
            // Back Button at bottom for better accessibility
            Button(action: {
                showingLoading = false
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(Color.brandSkyBlue)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.brandSkyBlue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.brandWhite)
    }
}

struct ProcessingStep: View {
    let icon: String
    let title: String
    let description: String
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.brandSkyBlue : Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                
                Image(systemName: isCompleted ? "checkmark" : icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isCompleted ? .white : .gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isCompleted ? Color.brandVeryDarkBlue : .gray)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AILoadingView(
        selectedImage: nil,
        showingLoading: .constant(true),
        showingReportError: .constant(false)
    )
}
