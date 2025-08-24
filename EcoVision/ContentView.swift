//
//  ContentView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import PhotosUI
import AVFoundation
import Foundation

struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedTab = 0 // 0: Home, 1: Calendar, 2: Map, 3: Profile
    @State private var showingMapDetail = false
    @State private var showingAIResult = false
    @State private var showingNoBinResult = false
    @State private var showingManualSearch = false
    @State private var showingReportError = false
    @State private var userAddress = "807 Freehold Place" // Default address for demo
    @StateObject private var wasteService = WasteCollectionService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main Content Area
                if showingAIResult {
                    AIResultView(
                        itemName: "Cardboard",
                        binType: "Mixed Recycling",
                        binColor: .yellow,
                        binImageName: "Yellow Bin",
                        showingResult: $showingAIResult,
                        showingReportError: $showingReportError
                    )
                } else if showingNoBinResult {
                    NoBinResultView(
                        showingResult: $showingNoBinResult,
                        showingReportError: $showingReportError
                    )
                } else if showingManualSearch {
                    ManualSearchView(
                        showingSearch: $showingManualSearch,
                        showingReportError: $showingReportError
                    )
                } else if showingReportError {
                    ReportErrorView(showingReport: $showingReportError)
                } else {
                    switch selectedTab {
                    case 0:
                        HomeView(showingActionSheet: $showingActionSheet)
                    case 1:
                        CalendarView(
                            wasteService: wasteService,
                            userAddress: userAddress
                        )
                    case 2:
                        if showingMapDetail {
                            MapDetailView(showingMapDetail: $showingMapDetail)
                        } else {
                            MapView(showingMapDetail: $showingMapDetail)
                        }
                    case 3:
                        ProfileView(
                            address: $userAddress,
                            wasteService: wasteService
                        )
                    default:
                        HomeView(showingActionSheet: $showingActionSheet)
                    }
                }
                
                // Bottom Navigation Bar (hidden when showing result views)
                if !showingAIResult && !showingNoBinResult && !showingManualSearch && !showingReportError {
                    HStack(spacing: 0) {
                        NavigationTabView(
                            icon: "Tab Home",
                            title: "Home",
                            isSelected: selectedTab == 0
                        ) {
                            selectedTab = 0
                        }
                        
                        NavigationTabView(
                            icon: "Tab Calendar",
                            title: "Calendar",
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                        
                        NavigationTabView(
                            icon: "Tab Map",
                            title: "Map",
                            isSelected: selectedTab == 2
                        ) {
                            selectedTab = 2
                            showingMapDetail = false
                        }
                        
                        NavigationTabView(
                            icon: "Tab Me",
                            title: "Profile",
                            isSelected: selectedTab == 3
                        ) {
                            selectedTab = 3
                        }
                    }
                    .frame(height: 80)
                    .background(Color.brandWhite)
                    .overlay(
                        Rectangle()
                            .fill(Color.brandMutedBlue.opacity(0.2))
                            .frame(height: 1),
                        alignment: .top
                    )
                }
            }
            .background(Color.brandWhite)
            .navigationBarHidden(true)
            .actionSheet(isPresented: $showingActionSheet) {
                ActionSheet(
                    title: Text("Select Image Source"),
                    buttons: [
                        .default(Text("Camera")) {
                            checkCameraPermission()
                        },
                        .default(Text("Photo Library")) {
                            showingImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .onChange(of: selectedImage) { oldValue, newImage in
                if let image = newImage {
                    // Simulate AI processing and show different results for demo
                    // In real implementation, this would call your AI model
                    
                    // For demo: randomly show different result types
                    let randomResult = Int.random(in: 0...3)
                    
                    switch randomResult {
                    case 0:
                        // Show successful AI recognition
                        showingAIResult = true
                    case 1:
                        // Show item that can't go in bins
                        showingNoBinResult = true
                    case 2:
                        // Show manual search (failed recognition)
                        showingManualSearch = true
                    default:
                        // Show AI result by default
                        showingAIResult = true
                    }
                    
                    print("Image selected: \(image)")
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showingCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showingCamera = true
                    }
                }
            }
        case .denied, .restricted:
            // Show alert to user about camera permission
            break
        @unknown default:
            break
        }
    }
}

#Preview {
    ContentView()
}