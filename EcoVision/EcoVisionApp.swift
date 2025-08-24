//
//  EcoVisionApp.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import UserNotifications

@main
struct EcoVisionApp: App {
    init() {
        // App initialization

        
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationManager.shared
        
        // Check and renew notifications if needed
        NotificationManager.shared.checkAndRenewNotifications()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
