//
//  AddressSearchView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import GooglePlaces

// MARK: - Address Search View

struct AddressSearchView: View {
    @Binding var selectedAddress: String
    @StateObject private var placesService = GooglePlacesService()
    @State private var searchText = ""
    @State private var showingResults = false
    @State private var isSearching = false
    
    var onAddressSelected: ((String) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Search TextField
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color.brandMutedBlue)
                    .font(.system(size: 16))
                
                TextField("Start typing your address...", text: $searchText)
                    .font(.system(size: 14))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .onChange(of: searchText) { oldValue, newValue in
                        handleSearchTextChange(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        placesService.clearResults()
                        showingResults = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.brandMutedBlue)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.brandWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.brandSkyBlue, lineWidth: 1)
            )
            
            // Search Results Dropdown
            if showingResults && !placesService.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(placesService.searchResults.prefix(5)) { result in
                        Button(action: {
                            selectAddress(result)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.name)
                                    .font(.system(size: 14))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color.brandVeryDarkBlue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(result.address)
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.brandMutedBlue)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(2)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(Color.brandWhite)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if result.id != placesService.searchResults.prefix(5).last?.id {
                            Divider()
                                .background(Color.brandMutedBlue.opacity(0.2))
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .background(Color.brandWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.brandSkyBlue.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                .zIndex(1)
            }
            
            // Loading Indicator
            if placesService.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching addresses...")
                        .font(.system(size: 12))
                        .foregroundColor(Color.brandMutedBlue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            // Error Message
            if let errorMessage = placesService.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }
        }
        .onAppear {
            // Initialize search text with current address
            searchText = selectedAddress
        }
        .onDisappear {
            // Clean up when view disappears
            placesService.cancelRequests()
            placesService.clearResults()
            showingResults = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSearchTextChange(_ newValue: String) {
        // Update the selected address as user types
        selectedAddress = newValue
        
        // Trigger search with debounce
        if !newValue.isEmpty && newValue.count >= 3 {
            showingResults = true
            placesService.searchAddresses(query: newValue)
        } else {
            showingResults = false
            placesService.clearResults()
        }
    }
    
    private func selectAddress(_ result: PlaceResult) {
        selectedAddress = result.address
        searchText = result.address
        showingResults = false
        placesService.clearResults()
        
        // Call the callback if provided
        onAddressSelected?(result.address)
    }
}

// MARK: - Preview

#Preview {
    AddressSearchView(selectedAddress: .constant("807 Freehold Place")) { address in
        print("Selected address: \(address)")
    }
    .padding()
}
