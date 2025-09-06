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
