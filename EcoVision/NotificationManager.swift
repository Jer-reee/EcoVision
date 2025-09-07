//
//  NotificationManager.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationPermissionGranted = false
    private var expirationTimer: Timer?
    
    private override init() {
        super.init()
        checkNotificationPermission()
        startExpirationTimer()
    }
    
    deinit {
        expirationTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startExpirationTimer() {
        // Check for expired notifications every hour
        expirationTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.removeExpiredNotifications()
        }
        
        // Also check when app becomes active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func appDidBecomeActive() {
        removeExpiredNotifications()
    }
    
    // MARK: - Permission Management
    
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isNotificationPermissionGranted = granted
            }
            return granted
        } catch {
            print("❌ Notification permission error: \(error)")
            return false
        }
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Notification Expiration Management
    
    func removeExpiredNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { requests in
            let now = Date()
            let expiredIdentifiers = requests.compactMap { request -> String? in
                guard let userInfo = request.content.userInfo as? [String: Any],
                      let expirationDateString = userInfo["expirationDate"] as? String,
                      let expirationDate = ISO8601DateFormatter().date(from: expirationDateString) else {
                    return nil
                }
                
                // If notification has expired, mark for removal
                if expirationDate < now {
                    return request.identifier
                }
                return nil
            }
            
            if !expiredIdentifiers.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: expiredIdentifiers)
                print("🗑️ Removed \(expiredIdentifiers.count) expired notifications")
            }
        }
    }
    
    // MARK: - Notification Scheduling
    
    func scheduleCollectionReminders(
        for collections: [WasteCollection],
        reminderTime: DateComponents,
        userAddress: String
    ) {
        // First remove all existing collection notifications and expired ones
        cancelCollectionNotifications()
        removeExpiredNotifications()
        
        guard isNotificationPermissionGranted else {
            print("⚠️ Notification permission not granted")
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate notifications for the next 12 months for long-term reliability
        let oneYearFromNow = calendar.date(byAdding: .year, value: 1, to: now) ?? now
        
        for collection in collections {
            let collectionDates = collection.collectionDates(from: now, to: oneYearFromNow)
            
            for collectionDate in collectionDates {
                // Schedule notification for the day before collection
                if let reminderDate = calendar.date(byAdding: .day, value: -1, to: collectionDate) {
                    scheduleNotification(
                        for: collection,
                        reminderDate: reminderDate,
                        collectionDate: collectionDate,
                        reminderTime: reminderTime,
                        userAddress: userAddress
                    )
                }
            }
        }
    }
    
    private func scheduleNotification(
        for collection: WasteCollection,
        reminderDate: Date,
        collectionDate: Date,
        reminderTime: DateComponents,
        userAddress: String
    ) {
        let calendar = Calendar.current
        
        // Create the notification date by combining reminder date with user's preferred time
        var notificationDateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        notificationDateComponents.hour = reminderTime.hour ?? 18 // Default to 6 PM
        notificationDateComponents.minute = reminderTime.minute ?? 0
        
        guard let notificationDate = calendar.date(from: notificationDateComponents),
              notificationDate > Date() else {
            return // Don't schedule past notifications
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "🗑️ Collection Reminder"
        content.body = createNotificationMessage(for: collection, collectionDate: collectionDate)
        content.sound = .default
        content.badge = 1
        
        // Add expiration date (24 hours from notification time)
        let expirationDate = calendar.date(byAdding: .hour, value: 24, to: notificationDate) ?? notificationDate
        
        // Add user info for tracking
        content.userInfo = [
            "collectionType": collection.type,
            "collectionDate": ISO8601DateFormatter().string(from: collectionDate),
            "address": userAddress,
            "expirationDate": ISO8601DateFormatter().string(from: expirationDate)
        ]
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: notificationDateComponents,
            repeats: false
        )
        
        // Create unique identifier
        let identifier = "collection_\(collection.type)_\(ISO8601DateFormatter().string(from: collectionDate))"
        
        // Create and schedule request
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func createNotificationMessage(for collection: WasteCollection, collectionDate: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let emoji: String
        switch collection.type {
        case "Household Waste":
            emoji = "🔴"
        case "Mixed Recycling":
            emoji = "🟡"
        case "FOGO":
            emoji = "🟢"
        default:
            emoji = "🗑️"
        }
        
        return "\(emoji) Don't forget! Your \(collection.type) bin will be collected tomorrow (\(formatter.string(from: collectionDate))). Please put your bin out tonight."
    }
    
    // MARK: - Notification Management
    
    func cancelCollectionNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let collectionNotificationIds = requests
                .filter { $0.identifier.hasPrefix("collection_") }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: collectionNotificationIds)
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Notification Status
    
    func getPendingNotificationsCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.filter { $0.identifier.hasPrefix("collection_") }.count
    }
    
    // MARK: - Automatic Renewal
    
    func checkAndRenewNotifications() {
        Task {
            // Check if we have notifications scheduled beyond 6 months from now
            let sixMonthsFromNow = Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
            let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            
            let futureCollectionNotifications = requests.filter { request in
                guard request.identifier.hasPrefix("collection_"),
                      let trigger = request.trigger as? UNCalendarNotificationTrigger,
                      let triggerDate = Calendar.current.date(from: trigger.dateComponents) else {
                    return false
                }
                return triggerDate > sixMonthsFromNow
            }
            
            // If we have fewer than 10 notifications beyond 6 months, we might need to renew
            if futureCollectionNotifications.count < 10 {
                // Check if notifications are enabled and we have stored user preferences
                await MainActor.run {
                    if self.isNotificationPermissionGranted {
                        // Note: In a real app, you'd store user preferences and collection data
                        // For now, this will be triggered when user enables notifications in ProfileView
                    }
                }
            }
        }
    }
}

// MARK: - User Notification Center Delegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        
        if userInfo["collectionType"] is String {
            // You could navigate to specific screen here if needed
        }
        
        completionHandler()
    }
}
