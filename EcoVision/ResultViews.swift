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
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
                // Report Error Button
                Button(action: {
                    showingResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
        }
        .background(Color.brandWhite)
    }
}

// MARK: - No Bin Result View

struct NoBinResultView: View {
    let selectedImage: UIImage?
    @Binding var showingResult: Bool
    @Binding var showingReportError: Bool
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(
        VStack {
                            Text("🗺️")
                                .font(.system(size: 30))
                            Text("Collection Points Map")
                                .font(.caption)
                                .foregroundColor(Color.brandMutedBlue)
                        }
                    )
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
                
                // Report Error Button
                Button(action: {
                    showingResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
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
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                        .disabled(isSearching)
                    
                    // Search Button
                    Button(action: {
                        Task {
                            await performTextSearch()
                        }
                    }) {
                            if isSearching {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "magnifyingglass")
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
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
        }
        .background(Color.brandWhite)
        .sheet(isPresented: $showingSearchResult) {
            if let result = searchResult {
                AIResultView(
                    aiResult: result,
                    selectedImage: selectedImage,
                    showingResult: $showingSearchResult,
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
                    
                }
                
                // Problem Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Please briefly explain what the problem is:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    TextEditor(text: $problemDescription)
                        .frame(height: 120)
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
    }
}
