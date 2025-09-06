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
import GooglePlaces
import MessageUI

struct ContentView: View {
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingActionSheet = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedTab = 0 // 0: Home, 1: Calendar, 2: Map, 3: Profile
    @State private var showingMapDetail = false
    @State private var selectedLocation: Location?
    @State private var showingAIResult = false
    @State private var showingNoBinResult = false
    @State private var showingManualSearch = false
    @State private var showingReportError = false
    @State private var userAddress = "807 Freehold Place" // Default address for demo
    @StateObject private var wasteService = WasteCollectionService()
    @StateObject private var aiService = AIService()
    @State private var aiClassificationResult: AIService.WasteClassificationResult?
    @State private var showingAILoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main Content Area
                if showingAIResult, let result = aiClassificationResult {
                    AIResultView(
                        aiResult: result,
                        selectedImage: selectedImage,
                        showingResult: $showingAIResult,
                        showingReportError: $showingReportError,
                        showingManualSearch: $showingManualSearch
                    )
                } else if showingNoBinResult {
                    NoBinResultView(
                        selectedImage: selectedImage,
                        showingResult: $showingNoBinResult,
                        showingReportError: $showingReportError,
                        showingManualSearch: $showingManualSearch
                    )
                } else if showingManualSearch {
                    ManualSearchView(
                        selectedImage: selectedImage,
                        showingSearch: $showingManualSearch,
                        showingReportError: $showingReportError
                    )
                } else if showingAILoading {
                    AILoadingView(
                        selectedImage: selectedImage,
                        showingLoading: $showingAILoading,
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
                            MapDetailView(showingMapDetail: $showingMapDetail, location: selectedLocation ?? Location(
                                name: "CDS Vic Alfred Square",
                                address: "Shop 1/61 Curtis St, Ballarat Central VIC 3350",
                                latitude: -37.5622,
                                longitude: 143.8503,
                                type: .containerDeposit,
                                openingHours: "8:00am-7:00pm Daily",
                                website: "https://cdsvic.com.au",
                                acceptedItems: [
                                    "Most aluminium, glass, plastic and liquid paperboard (carton) drink containers between 150mL and 3 litres",
                                    "You can keep the lids on, we recycle them too!",
                                    "Look for the 10c mark on the drink container label"
                                ]
                            ))
                        } else {
                            MapView(showingMapDetail: $showingMapDetail, selectedLocation: $selectedLocation)
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
                if !showingAIResult && !showingNoBinResult && !showingManualSearch && !showingReportError && !showingAILoading {
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
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // App going to background - this is handled by the individual services
            }
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
                    Task {
                        await processImageWithAI(image)
                    }
                }
            }
        }
    }
    
    // MARK: - AI Image Processing
    
    private func processImageWithAI(_ image: UIImage) async {
        print("📷 IMAGE ANALYSIS STARTED:")
        print("🖼️ Image size: \(image.size)")
        print("⏳ Processing...")
        
        await MainActor.run {
            showingAILoading = true
        }
        
        // Use real AI analysis
        print("🚀 Using AI analysis")
        if let result = await aiService.analyzeWasteImage(image) {
            // Print AI results
            print("🤖 AI CLASSIFICATION RESULTS:")
            print("📦 Item Name: \(result.itemName)")
            print("🗑️ Bin Type: \(result.binType.rawValue)")
            print("🎨 Bin Color: \(result.binColor)")
            print("📝 Description: \(result.description)")
            print("📋 Instructions: \(result.instructions)")
            print("📊 Confidence: \(String(format: "%.2f", result.confidence * 100))%")
            print("🔧 Special Collection: \(result.binType == .ewaste || result.binType == .other)")
            if result.binType == .ewaste || result.binType == .other {
                print("📦 Special Collection Type: \(result.binType.rawValue)")
            }

            print("----------------------------------------")
            
            await handleAIResult(result)
        } else {
            print("❌ AI IMAGE ANALYSIS FAILED - Falling back to manual search")
            await MainActor.run {
                showingAILoading = false
                showingManualSearch = true
            }
        }
    }
    
    private func handleAIResult(_ result: AIService.WasteClassificationResult) async {
        print("🎯 ROUTING AI RESULT:")
        print("📦 Item: \(result.itemName)")
        print("🗑️ Bin Type: \(result.binType.rawValue)")
        print("🔄 Routing to: ", terminator: "")
        
        await MainActor.run {
            showingAILoading = false
            aiClassificationResult = result
            
            // Fallback routing: Check instructions if bin type is "none" but instructions suggest a specific bin
            let finalBinType = determineCorrectBinType(from: result)
            
            // Create corrected result if fallback was used
            let correctedResult: AIService.WasteClassificationResult
            if finalBinType != result.binType {
                print("🔄 Creating corrected result with bin type: \(finalBinType.rawValue)")
                correctedResult = AIService.WasteClassificationResult(
                    itemName: result.itemName,
                    binType: finalBinType,
                    binColor: finalBinType.color,
                    binImageName: finalBinType.imageName,
                    description: result.description,
                    instructions: result.instructions,
                    confidence: result.confidence
                )
                aiClassificationResult = correctedResult
            } else {
                correctedResult = result
            }
            
            switch finalBinType {
            case .none:
                print("No Bin Result View")
                showingNoBinResult = true
            case .red, .yellow, .green, .purple, .ewaste, .other:
                print("AI Result View (Regular Bin)")
                showingAIResult = true
            }
        }
    }
    
    // MARK: - Fallback Routing Logic
    
    private func determineCorrectBinType(from result: AIService.WasteClassificationResult) -> AIService.BinType {
        // If bin type is already correct, use it
        if result.binType != .none {
            return result.binType
        }
        
        // Fallback: Analyze instructions to determine correct bin type
        let instructions = result.instructions.lowercased()
        
        if instructions.contains("green bin") || instructions.contains("garden waste") || instructions.contains("organic") {
            print("🔄 Fallback: Detected green bin from instructions")
            return .green
        } else if instructions.contains("yellow bin") || instructions.contains("recycling") || instructions.contains("recyclable") {
            print("🔄 Fallback: Detected yellow bin from instructions")
            return .yellow
        } else if instructions.contains("red bin") || instructions.contains("general waste") || instructions.contains("landfill") {
            print("🔄 Fallback: Detected red bin from instructions")
            return .red
        } else if instructions.contains("purple bin") || instructions.contains("glass") {
            print("🔄 Fallback: Detected purple bin from instructions")
            return .purple
        } else if instructions.contains("battery") || instructions.contains("electronic") || instructions.contains("e-waste") || instructions.contains("computer") || instructions.contains("phone") || instructions.contains("appliance") {
            print("🔄 Fallback: Detected e-waste from instructions")
            return .ewaste
        } else if instructions.contains("transfer station") || instructions.contains("special collection") {
            print("🔄 Fallback: Detected other/special collection from instructions")
            return .other
        }
        
        // If no clear bin type found in instructions, return none
        print("🔄 Fallback: No clear bin type found in instructions")
        return .none
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
        ScrollableViewWithFloatingBack(backAction: {
            showingSearch = false
        }) {
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
            }
        }
        .background(Color.brandWhite)
        .sheet(isPresented: $showingSearchResult) {
            if let result = searchResult {
                AIResultView(
                    aiResult: result,
                    selectedImage: selectedImage,
                    showingResult: $showingSearchResult,
                    showingReportError: $showingReportError,
                    showingManualSearch: $showingSearch
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
            print("🔧 Special Collection: \(result.binType == .ewaste || result.binType == .other)")
            if result.binType == .ewaste || result.binType == .other {
                print("📦 Special Collection Type: \(result.binType.rawValue)")
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
    @StateObject private var emailService = EmailService()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingThankYou = false
    
    var body: some View {
        ScrollableViewWithFloatingBack(backAction: {
            showingReport = false
        }) {
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
                    
                    TextField("Enter your email", text: $email)
                        .font(.system(size: 16))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.brandWhite)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brandMutedBlue.opacity(0.3), lineWidth: 1)
                        )
                }
                
                // Problem Description Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Please briefly explain what the problem is:")
                        .font(.system(size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    TextEditor(text: $problemDescription)
                        .frame(height: 120)
                        .font(.system(size: 16))
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.brandWhite)
                                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.brandMutedBlue.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Submit Button
            Button(action: {
                // Validate inputs
                guard !email.isEmpty && !problemDescription.isEmpty else {
                    alertMessage = "Please fill in both email and problem description."
                    showingAlert = true
                    return
                }
                
                // Send email
                emailService.sendErrorReport(userEmail: email, problemDescription: problemDescription)
                
                // Show thank you page
                showingThankYou = true
            }) {
                Text("Submit Report")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.brandVeryDarkBlue)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.brandWhite)
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showingThankYou) {
            ThankYouView(showingThankYou: $showingThankYou, showingReport: $showingReport)
        }
    }
}

// MARK: - Thank You View

struct ThankYouView: View {
    @Binding var showingThankYou: Bool
    @Binding var showingReport: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Thank you icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // Thank you message
            VStack(spacing: 16) {
                Text("Thank You!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Text("Your feedback has been sent successfully. We appreciate you taking the time to help us improve EcoVision!")
                    .font(.body)
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
            
            // Done button
            Button(action: {
                showingThankYou = false
                showingReport = false
            }) {
                Text("Done")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.brandSkyBlue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
        }
        .background(Color.brandWhite)
    }
}

// MARK: - Email Service

class EmailService: NSObject, ObservableObject, MFMailComposeViewControllerDelegate {
    @Published var isShowingMailView = false
    @Published var emailResult: Result<MFMailComposeResult, Error>? = nil
    
    func sendErrorReport(userEmail: String, problemDescription: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["jarrysinszzj@gmail.com"])
            mailComposer.setSubject("EcoVision App - Error Report")
            
            let emailBody = """
        Error Report from EcoVision App
        
        User Email: \(userEmail)
        
        Problem Description:
        \(problemDescription)
        
        ---
        This report was sent from the EcoVision iOS app.
        """
            
            mailComposer.setMessageBody(emailBody, isHTML: false)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                // Find the topmost presented view controller
                var topController = rootViewController
                while let presentedController = topController.presentedViewController {
                    topController = presentedController
                }
                
                topController.present(mailComposer, animated: true)
            }
        } else {
            // Fallback: Show alert that mail is not configured
            emailResult = .failure(NSError(domain: "EmailService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Mail is not configured on this device"]))
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        
        if let error = error {
            emailResult = .failure(error)
        } else {
            emailResult = .success(result)
        }
    }
}

#Preview {
    ContentView()
}