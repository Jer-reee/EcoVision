//
//  ResultViews.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - AI Recognition Result View

struct AIResultView: View {
    let aiResult: AIService.WasteClassificationResult
    let selectedImage: UIImage?
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
            
            // Item Identification
            VStack(spacing: 16) {
                Text(aiResult.itemName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                // Bin Recommendation
                HStack(spacing: 16) {
                    Image(aiResult.binImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color(aiResult.binColor.lowercased()))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(aiResult.binType.rawValue)
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundColor(Color(aiResult.binColor.lowercased()))
                        
                        if aiResult.confidence < 0.8 {
                            Text("Low confidence")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Text(aiResult.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Text(aiResult.instructions)
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.top, 8)
                
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
    let selectedImage: UIImage?
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
    let selectedImage: UIImage?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResult: AIService.WasteClassificationResult?
    @State private var showingSearchResult = false
    @State private var errorMessage: String?
    @Binding var showingSearch: Bool
    @Binding var showingReportError: Bool
    @StateObject private var aiService = AIService()
    
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
                    .padding(.top, 20)
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
                    .padding(.top, 20)
            }
            
            Spacer()
            
            // Manual Search Interface
            VStack(spacing: 16) {
                Text("Manual Search")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Text("Enter the name of the item you want to recycle")
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                // Search Field
                HStack(spacing: 12) {
                    TextField("e.g., cardboard box, plastic bottle...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16))
                        .disabled(isSearching)
                    
                    // Search Button
                    Button(action: {
                        Task {
                            await performTextSearch()
                        }
                    }) {
                        HStack(spacing: 6) {
                            if isSearching {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            Text(isSearching ? "Searching..." : "Search")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            searchText.isEmpty || isSearching 
                                ? Color.gray 
                                : Color.brandSkyBlue
                        )
                        .cornerRadius(8)
                    }
                    .disabled(searchText.isEmpty || isSearching)
                }
                .padding(.top, 20)
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
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
            
            // Back Button at bottom for better accessibility
            Button(action: {
                showingSearch = false
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
        .sheet(isPresented: $showingSearchResult) {
            if let result = searchResult {
                AIResultView(
                    aiResult: result,
                    selectedImage: selectedImage,
                    showingResult: $showingSearchResult,
                    showingReportError: $showingReportError
                )
            }
        }
    }
    
    // MARK: - Search Methods
    
    private func performTextSearch() async {
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
            print("🔧 Special Collection: \(result.isSpecialCollection)")
            if let specialType = result.specialCollectionType {
                print("📦 Special Collection Type: \(specialType)")
            }

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

// MARK: - Report Error View

struct ReportErrorView: View {
    @State private var email = ""
    @State private var problemDescription = ""
    @Binding var showingReport: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            
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
            .padding(.bottom, 80)
            
            // Back Button at bottom for better accessibility
            Button(action: {
                showingReport = false
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
