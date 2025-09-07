//
//  ProfileView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - Profile View

struct ProfileView: View {
    @Binding var address: String
    @ObservedObject var wasteService: WasteCollectionService
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var notificationsEnabled = false
    @State private var reminderTime = Date()
    @State private var showingPermissionAlert = false

    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                Text("Profile")
                    .font(.system(size: min(geometry.size.width * 0.08, 34), weight: .bold))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .padding(.top, min(geometry.size.height * 0.025, 20))
                    .padding(.bottom, min(geometry.size.height * 0.04, 30))
                
                VStack(alignment: .leading, spacing: 0) {
                // Address Section
                AddressDisplayView(address: $address)
                    .onChange(of: address) { oldValue, newValue in
                        // Fetch collection data when address is selected
                        if !newValue.isEmpty {
                            wasteService.fetchWasteCollection(for: newValue)
                        }
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                    .padding(.bottom, min(geometry.size.height * 0.03, 24))
                
                // Notifications Section
                VStack(alignment: .leading, spacing: min(geometry.size.height * 0.02, 16)) {
                    HStack {
                        Text("Notification:")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        if notificationsEnabled {
                            Spacer()
                            
                            Text("Reminder Time")
                                .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                                .foregroundColor(Color.brandVeryDarkBlue)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                                .animation(.easeInOut(duration: 0.3), value: notificationsEnabled)
                        }
                    }
                    
                    HStack {
                        Toggle("", isOn: $notificationsEnabled)
                            .labelsHidden()
                            .scaleEffect(min(geometry.size.width * 0.002, 0.8))
                            .onChange(of: notificationsEnabled) { oldValue, enabled in
                                handleNotificationToggle(enabled: enabled)
                            }
                        
                        if notificationsEnabled {
                            Spacer()
                            
                            DatePicker("", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .scaleEffect(min(geometry.size.width * 0.0022, 0.9))
                                .onChange(of: reminderTime) { oldValue, newTime in
                                    if notificationsEnabled && !wasteService.collectionData.isEmpty {
                                        scheduleNotifications()
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .trailing).combined(with: .opacity)
                                ))
                                .animation(.easeInOut(duration: 0.3), value: notificationsEnabled)
                        }
                    }
                    
                    // Notification Status
                    if notificationsEnabled {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Color.brandSkyBlue)
                                .font(.system(size: min(geometry.size.width * 0.03, 12)))
                            
                            Text("Reminders scheduled")
                                .font(.system(size: min(geometry.size.width * 0.03, 12)))
                                .foregroundColor(Color.brandMutedBlue)
                        }
                        .padding(.top, min(geometry.size.height * 0.01, 8))
                    }
                }
                .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                
                // Collection Information Section
                if !wasteService.collectionData.isEmpty {
                    VStack(alignment: .leading, spacing: min(geometry.size.height * 0.02, 16)) {
                        Text("Your Collection Schedule:")
                            .font(.system(size: min(geometry.size.width * 0.045, 18), weight: .semibold))
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        ForEach(Array(wasteService.collectionData.prefix(1)), id: \.id) { record in
                            VStack(alignment: .leading, spacing: min(geometry.size.height * 0.015, 12)) {
                                // Show collection day and address info
                                if let collectionDay = record.collectionDay, let address = record.address {
                                    Text("Collections for \(address)")
                                        .font(.system(size: min(geometry.size.width * 0.03, 12)))
                                        .foregroundColor(Color.brandMutedBlue)
                                    Text("Collection Day: \(collectionDay)")
                                        .font(.system(size: min(geometry.size.width * 0.03, 12)))
                                        .foregroundColor(Color.brandMutedBlue)
                                }
                                
                                // Show each waste type collection with frequency
                                ForEach(record.wasteCollections, id: \.id) { collection in
                                    HStack {
                                        Rectangle()
                                            .fill(collection.color)
                                            .frame(width: min(geometry.size.width * 0.05, 20), height: min(geometry.size.width * 0.05, 20))
                                            .cornerRadius(min(geometry.size.width * 0.01, 4))
                                        
                                        VStack(alignment: .leading, spacing: min(geometry.size.height * 0.005, 4)) {
                                            Text(collection.type)
                                                .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .medium))
                                                .foregroundColor(Color.brandVeryDarkBlue)
                                            
                                            VStack(alignment: .leading, spacing: min(geometry.size.height * 0.003, 3)) {
                                                Text("Next: \(collection.date)")
                                                    .font(.system(size: min(geometry.size.width * 0.03, 12)))
                                                    .foregroundColor(Color.brandMutedBlue)
                                                
                                                Text(frequencyText(for: collection.frequency))
                                                    .font(.system(size: min(geometry.size.width * 0.027, 11)))
                                                    .foregroundColor(Color.brandMutedBlue.opacity(0.8))
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                    .padding(.top, min(geometry.size.height * 0.025, 20))
                } else if wasteService.isLoading {
                    HStack {
                        ProgressView()
                            .scaleEffect(min(geometry.size.width * 0.002, 0.8))
                        Text("Loading collection data...")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandMutedBlue)
                    }
                    .padding(.top, min(geometry.size.height * 0.025, 20))
                } else if let errorMessage = wasteService.errorMessage {
                    Text("Error: \(errorMessage)")
                        .font(.system(size: min(geometry.size.width * 0.035, 14)))
                        .foregroundColor(.red)
                        .padding(.top, min(geometry.size.height * 0.025, 20))
                }
            }
            }
            .background(Color.brandWhite)
        }
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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Address:")
                        .font(.system(size: 18, weight: .semibold))
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
    @State private var addressText = ""
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: min(geometry.size.height * 0.02, 16)) {
                        Text("Enter Your Address")
                            .font(.system(size: min(geometry.size.width * 0.06, 22), weight: .bold))
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        Text("Enter your full address in the Ballarat area to get personalized waste collection schedules.")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandMutedBlue)
                            .lineLimit(nil)
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                    .padding(.top, min(geometry.size.height * 0.025, 20))
                    .padding(.bottom, min(geometry.size.height * 0.025, 20))
                
                    // Address Input Section
                    VStack(alignment: .leading, spacing: min(geometry.size.height * 0.02, 16)) {
                        VStack(alignment: .leading, spacing: min(geometry.size.height * 0.01, 8)) {
                            Text("Address:")
                                .font(.system(size: min(geometry.size.width * 0.04, 16), weight: .medium))
                                .foregroundColor(Color.brandVeryDarkBlue)
                            
                            TextField("e.g., 123 Main Street, Ballarat VIC 3350", text: $addressText)
                                .font(.system(size: min(geometry.size.width * 0.035, 14)))
                                .foregroundColor(Color.brandVeryDarkBlue)
                                .padding(.horizontal, min(geometry.size.width * 0.03, 12))
                                .padding(.vertical, min(geometry.size.height * 0.012, 10))
                                .background(Color.brandWhite)
                                .overlay(
                                    RoundedRectangle(cornerRadius: min(geometry.size.width * 0.02, 8))
                                        .stroke(Color.brandSkyBlue, lineWidth: 1)
                                )
                            
                            Text("Please enter your full address including street number, street name, suburb, and postcode.")
                                .font(.system(size: min(geometry.size.width * 0.03, 12)))
                                .foregroundColor(Color.brandMutedBlue)
                                .lineLimit(nil)
                        }
                    
                        // Example addresses for reference
                        VStack(alignment: .leading, spacing: min(geometry.size.height * 0.01, 8)) {
                            Text("Example addresses:")
                                .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .medium))
                                .foregroundColor(Color.brandVeryDarkBlue)
                            
                            VStack(alignment: .leading, spacing: min(geometry.size.height * 0.005, 4)) {
                                Text("• 123 Sturt Street, Ballarat Central VIC 3350")
                                Text("• 45 Lydiard Street North, Ballarat VIC 3350")
                                Text("• 789 Wendouree Parade, Lake Wendouree VIC 3350")
                            }
                            .font(.system(size: min(geometry.size.width * 0.03, 12)))
                            .foregroundColor(Color.brandMutedBlue)
                        }
                    }
                    .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                
                    // Current Selection Display
                    if !selectedAddress.isEmpty {
                        VStack(alignment: .leading, spacing: min(geometry.size.height * 0.01, 8)) {
                            Text("Current Address:")
                                .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .medium))
                                .foregroundColor(Color.brandVeryDarkBlue)
                            
                            Text(selectedAddress)
                                .font(.system(size: min(geometry.size.width * 0.035, 14)))
                                .foregroundColor(Color.brandMutedBlue)
                                .padding(.horizontal, min(geometry.size.width * 0.03, 12))
                                .padding(.vertical, min(geometry.size.height * 0.01, 8))
                                .background(Color.brandSkyBlue.opacity(0.1))
                                .cornerRadius(min(geometry.size.width * 0.02, 8))
                        }
                        .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                        .padding(.bottom, min(geometry.size.height * 0.025, 20))
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
                        Button("Save") {
                            selectedAddress = addressText
                            isPresented = false
                        }
                        .foregroundColor(Color.brandSkyBlue)
                        .fontWeight(.medium)
                        .disabled(addressText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .onAppear {
                // Initialize with current address
                addressText = selectedAddress
            }
        }
    }
}
