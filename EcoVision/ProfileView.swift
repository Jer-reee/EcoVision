//
//  ProfileView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import GooglePlaces

// MARK: - Profile View

struct ProfileView: View {
    @Binding var address: String
    @ObservedObject var wasteService: WasteCollectionService
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var notificationsEnabled = false
    @State private var reminderTime = Date()
    @State private var showingPermissionAlert = false

    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Profile")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.brandVeryDarkBlue)
                .padding(.top, 20)
                .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 24) {
                // Address Section
                AddressDisplayView(address: $address)
                    .onChange(of: address) { oldValue, newValue in
                        // Fetch collection data when address is selected
                        if !newValue.isEmpty {
                            wasteService.fetchWasteCollection(for: newValue)
                        }
                    }
                
                // Notifications Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Notification:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                        .scaleEffect(0.8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onChange(of: notificationsEnabled) { oldValue, enabled in
                            handleNotificationToggle(enabled: enabled)
                        }
                    
                    Text("Reminder Time\n(the day before)")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.top, 8)
                    
                    DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .scaleEffect(0.9)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(!notificationsEnabled)
                        .onChange(of: reminderTime) { oldValue, newTime in
                            if notificationsEnabled && !wasteService.collectionData.isEmpty {
                                scheduleNotifications()
                            }
                        }
                    
                    // Notification Status
                    if notificationsEnabled {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color.brandSkyBlue)
                                .font(.caption)
                            
                            Text("Reminders scheduled")
                                .font(.caption)
                                .foregroundColor(Color.brandMutedBlue)
                        }
                        .padding(.top, 4)
                    }
                }
                
                // Collection Information Section
                if !wasteService.collectionData.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Collection Schedule:")
                            .font(.system(size: 16))
                            .fontWeight(.medium)
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        ForEach(Array(wasteService.collectionData.prefix(1)), id: \.id) { record in
                            VStack(alignment: .leading, spacing: 8) {
                                // Show collection day and address info
                                if let collectionDay = record.collectionDay, let address = record.address {
                                    Text("Collections for \(address)")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.brandMutedBlue)
                                    Text("Collection Day: \(collectionDay)")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.brandMutedBlue)
                                }
                                
                                // Show each waste type collection with frequency
                                ForEach(record.wasteCollections, id: \.id) { collection in
                                    HStack {
                                        Rectangle()
                                            .fill(collection.color)
                                            .frame(width: 20, height: 20)
                                            .cornerRadius(4)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(collection.type)
                                                .font(.system(size: 14))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color.brandVeryDarkBlue)
                                            
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text("Next: \(collection.date)")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(Color.brandMutedBlue)
                                                
                                                Text(frequencyText(for: collection.frequency))
                                                    .font(.system(size: 11))
                                                    .foregroundColor(Color.brandMutedBlue.opacity(0.8))
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 20)
                } else if wasteService.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading collection data...")
                            .font(.system(size: 14))
                            .foregroundColor(Color.brandMutedBlue)
                    }
                    .padding(.top, 20)
                } else if let errorMessage = wasteService.errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                        .padding(.top, 20)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color.brandWhite)
        .onAppear {
            // Initialize notification state
            notificationsEnabled = notificationManager.isNotificationPermissionGranted
            
            // Set default reminder time to 6 PM
            let calendar = Calendar.current
            let sixPM = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
            reminderTime = sixPM
            
            // Fetch collection data immediately when profile appears
            if wasteService.collectionData.isEmpty {
                wasteService.fetchWasteCollection(for: address)
            }
        }
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Settings") {
                openAppSettings()
            }
            Button("Cancel", role: .cancel) {
                notificationsEnabled = false
            }
        } message: {
            Text("Please enable notifications in Settings to receive collection reminders.")
        }
        .onChange(of: wasteService.collectionData) { oldValue, newData in
            if notificationsEnabled && !newData.isEmpty {
                scheduleNotifications()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            // Renew notifications when app comes to foreground
            if notificationsEnabled && !wasteService.collectionData.isEmpty {
                notificationManager.checkAndRenewNotifications()
            }
        }
    }
    
    private func frequencyText(for frequency: CollectionFrequency) -> String {
        switch frequency {
        case .weekly:
            return "Collected weekly"
        case .fortnightly:
            return "Collected fortnightly"
        }
    }
    
    private func handleNotificationToggle(enabled: Bool) {
        if enabled {
            Task {
                let granted = await notificationManager.requestNotificationPermission()
                await MainActor.run {
                    if granted {
                        if !wasteService.collectionData.isEmpty {
                            scheduleNotifications()
                        }
                    } else {
                        notificationsEnabled = false
                        showingPermissionAlert = true
                    }
                }
            }
        } else {
            notificationManager.cancelCollectionNotifications()
        }
    }
    
    private func scheduleNotifications() {
        guard !wasteService.collectionData.isEmpty else { return }
        
        // Collect all waste collections from all records
        var allCollections: [WasteCollection] = []
        for record in wasteService.collectionData {
            allCollections.append(contentsOf: record.wasteCollections)
        }
        
        // Convert time to DateComponents
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
        
        notificationManager.scheduleCollectionReminders(
            for: allCollections,
            reminderTime: timeComponents,
            userAddress: address
        )
    }
    
    private func openAppSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

// MARK: - Address Display Component

struct AddressDisplayView: View {
    @Binding var address: String
    @State private var showingAddressEdit = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    if address.isEmpty {
                        Text("No address set")
                            .font(.system(size: 14))
                            .foregroundColor(Color.brandMutedBlue)
                            .italic()
                    } else {
                        Text(address)
                            .font(.system(size: 14))
                            .foregroundColor(Color.brandVeryDarkBlue)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showingAddressEdit = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: address.isEmpty ? "plus.circle.fill" : "pencil.circle.fill")
                            .font(.system(size: 16))
                        Text(address.isEmpty ? "Add" : "Edit")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.brandSkyBlue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showingAddressEdit) {
            AddressEditSheet(
                selectedAddress: $address,
                isPresented: $showingAddressEdit
            )
        }
    }
}

// MARK: - Address Edit Sheet

struct AddressEditSheet: View {
    @Binding var selectedAddress: String
    @Binding var isPresented: Bool
    @StateObject private var placesService = GooglePlacesService()
    @State private var searchText = ""
    @State private var showingResults = false
    @State private var isSearching = false
    @State private var searchTimer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Your Address")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Text("Search for your address in the Ballarat area to get personalized waste collection schedules.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.brandMutedBlue)
                        .lineLimit(nil)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Search Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Address:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
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
                    
                    // Search Results
                    if showingResults && !placesService.searchResults.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 0) {
                                ForEach(placesService.searchResults.prefix(10)) { result in
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
                                        .padding(.vertical, 12)
                                        .background(Color.brandWhite)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    if result.id != placesService.searchResults.prefix(10).last?.id {
                                        Divider()
                                            .background(Color.brandMutedBlue.opacity(0.2))
                                            .padding(.horizontal, 12)
                                    }
                                }
                            }
                        }
                        .background(Color.brandWhite)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brandSkyBlue.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .frame(maxHeight: 300)
                    }
                    
                    // Loading Indicator
                    if placesService.isLoading {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Searching addresses in Ballarat...")
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
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Current Selection Display
                if !selectedAddress.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Selected Address:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        Text(selectedAddress)
                            .font(.system(size: 14))
                            .foregroundColor(Color.brandMutedBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.brandSkyBlue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .background(Color.brandWhite)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(Color.brandSkyBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(Color.brandSkyBlue)
                    .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            // Initialize search text with current address
            searchText = selectedAddress
        }
        .onDisappear {
            // Clean up when view disappears
            searchTimer?.invalidate()
            placesService.cancelRequests()
            placesService.clearResults()
            showingResults = false
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSearchTextChange(_ newValue: String) {
        // Cancel previous timer
        searchTimer?.invalidate()
        
        if !newValue.isEmpty && newValue.count >= 2 {
            // Debounce search by 300ms to avoid too many API calls
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                showingResults = true
                placesService.searchAddresses(query: newValue)
            }
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
    }
}
