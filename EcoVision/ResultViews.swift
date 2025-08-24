//
//  ResultViews.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - AI Recognition Result View

struct AIResultView: View {
    let itemName: String
    let binType: String
    let binColor: Color
    let binImageName: String
    @Binding var showingResult: Bool
    @Binding var showingReportError: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: {
                    showingResult = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .font(.system(size: 16))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Captured Image Placeholder
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
            
            Spacer()
            
            // Item Identification
            VStack(spacing: 16) {
                Text(itemName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                // Bin Recommendation
                HStack(spacing: 16) {
                    Image(binImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(binColor)
                    
                    Text(binType)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(binColor)
                }
                
                Text("Cardboard can be recycled into new cardboards.\nPlease place in the yellow bin.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Report Error Button
                Button(action: {
                    showingResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Report Error")
                            .font(.system(size: 14))
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.red)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(Color.brandWhite)
    }
}

// MARK: - No Bin Result View

struct NoBinResultView: View {
    @Binding var showingResult: Bool
    @Binding var showingReportError: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: {
                    showingResult = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .font(.system(size: 16))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Captured Image Placeholder
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
            
            Spacer()
            
            // No Bin Result
            VStack(spacing: 16) {
                Text("Batteries")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                // "Do not throw in bins" indicator
                HStack(spacing: 16) {
                    Image(systemName: "trash.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Do not throw")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text("in the Bins")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                Text("Batteries cannot be placed in bin as they can cause fires and damage in environment!\nPlease see the map below for battery/e-waste collection points.")
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Map Section
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
        VStack {
                            Text("🗺️")
                                .font(.system(size: 30))
                            Text("Collection Points Map")
                                .font(.caption)
                                .foregroundColor(Color.brandMutedBlue)
                        }
                    )
                    .cornerRadius(8)
                    .padding(.top, 16)
                
                // Location Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("CDS Vic Alfred Square")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    
                    Text("Address: Shop 1/61 Curtis St, Ballarat Central VIC 3350")
                        .font(.system(size: 12))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Opening Hours:")
                        .font(.system(size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Monday: 8:00am-7:00pm\nTuesday: 8:00am-7:00pm\nWednesday: 8:00am-7:00pm\nThursday: 8:00am-7:00pm")
                        .font(.system(size: 11))
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
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
                
                // Report Error Button
                Button(action: {
                    showingResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Report Error")
                            .font(.system(size: 14))
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.red)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(Color.brandWhite)
    }
}

// MARK: - Manual Search View

struct ManualSearchView: View {
    @State private var searchText = ""
    @Binding var showingSearch: Bool
    @Binding var showingReportError: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: {
                    showingSearch = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .font(.system(size: 16))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            // Error Message
            VStack(spacing: 16) {
                Text("Sorry, object not identified")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Text("We are unable to identify the item.\nPlease take another photo or manually search for the item")
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Search Field
                TextField("Search for item...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 16))
                    .padding(.top, 20)
                
                // Report Error Button
                Button(action: {
                    showingSearch = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
                    HStack(spacing: 8) {
                        Text("Report Error")
                            .font(.system(size: 14))
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.red)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.brandWhite)
    }
}

// MARK: - Report Error View

struct ReportErrorView: View {
    @State private var email = ""
    @State private var problemDescription = ""
    @Binding var showingReport: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                Button(action: {
                    showingReport = false
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .font(.system(size: 16))
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Seen an Error/Issue?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    TextField("", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 14))
                }
                
                // Problem Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Please briefly explain what the problem is:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    TextEditor(text: $problemDescription)
                        .frame(height: 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .font(.system(size: 14))
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Submit Button
            Button(action: {
                // Handle form submission
                showingReport = false
            }) {
                Text("Submit")
                    .font(.system(size: 16))
                    .fontWeight(.medium)
                    .foregroundColor(Color.brandWhite)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.brandVeryDarkBlue)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 120)
        }
        .background(Color.brandWhite)
    }
}
