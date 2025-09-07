//
//  ResultViews.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import MessageUI

// MARK: - AI Recognition Result View

public struct AIResultView: View {
    let aiResult: AIService.WasteClassificationResult
    let selectedImage: UIImage?
    @Binding var showingResult: Bool
    @Binding var showingReportError: Bool
    @Binding var showingManualSearch: Bool
    
    private var binColor: Color {
        switch aiResult.binType {
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .purple: return .purple
        case .ewaste: return .gray
        case .other: return .black
        }
    }
    
    public var body: some View {
        ScrollableViewWithFloatingBack(backAction: {
                    showingResult = false
                }) {
            VStack(spacing: 0) {
                // Captured Image Display - Full width at top
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                    .clipped()
            } else {
                Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                    .overlay(
                        Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.6))
                        )
                }
                
                // Content Section
                VStack(alignment: .center, spacing: 22) {
                    // Item Name and Bin Type Row
                     HStack(alignment: .center, spacing: 16) {
                         // Item Name (LEFT)
                         VStack(alignment: .center, spacing: 9) {
                             Text(aiResult.itemName)
                                 .font(.title2)
                                 .fontWeight(.bold)
                                 .foregroundColor(Color.brandVeryDarkBlue)
                                 .lineLimit(2)
                                 .minimumScaleFactor(0.8)
                                 .multilineTextAlignment(.center)
                         }
                         .frame(maxWidth: .infinity, alignment: .center)
                         
                         // Bin Icon (RIGHT)
                         VStack(alignment: .center, spacing: 6) {
                             // ALL bin types use the same image display logic
                             if let image = UIImage(named: aiResult.binImageName) {
                                 Image(uiImage: image)
                                     .resizable()
                                     .aspectRatio(contentMode: .fit)
                                     .frame(width: 50, height: 50)
                             } else {
                                 // ALL bin types use the same fallback
                                 Image(systemName: "trash.fill")
                                     .font(.system(size: 30))
                                     .foregroundColor(binColor)
                                     .frame(width: 50, height: 50)
                             }
                             
                             Text(aiResult.binType.rawValue)
                                 .font(.system(size: 12, weight: .medium))
                                 .foregroundColor(binColor)
                                 .lineLimit(1)
                                 .minimumScaleFactor(0.7)
                                 .multilineTextAlignment(.center)
                         }
                     }
                    
                    // Description Section
                    VStack(alignment: .center, spacing: 8) {
                        Text("Description:")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.brandVeryDarkBlue)
                            .multilineTextAlignment(.center)
                
                Text(aiResult.description)
                            .font(.system(size: 16))
                            .foregroundColor(Color.brandVeryDarkBlue)
                            .lineLimit(nil)
                            .multilineTextAlignment(.center)
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
                    
                    // Disposal Instructions Section
                    VStack(alignment: .center, spacing: 8) {
                        Text("Disposal instructions:")
                            .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                
                Text(aiResult.instructions)
                            .font(.system(size: 16))
                    .foregroundColor(Color.brandVeryDarkBlue)
                            .lineLimit(nil)
                    .multilineTextAlignment(.center)
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
                    
                    // Action Buttons
                    HStack(spacing: 12) {
                        // Manual Search Button
                        Button(action: {
                            showingResult = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingManualSearch = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text("Not correct?")
                                    .font(.system(size: 13))
                                Text("Try searching manually")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(Color.brandSkyBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.brandSkyBlue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.brandSkyBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                
                // Report Error Button
                Button(action: {
                    showingResult = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showingReportError = true
                    }
                }) {
                            HStack(spacing: 4) {
                        Text("Report Error")
                                    .font(.system(size: 13))
                        Image(systemName: "exclamationmark.circle")
                                    .font(.system(size: 12))
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.top, 16)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
        .background(Color.brandWhite)
    }
}

// NoBinResultView removed - all bin types now use AIResultView

// MARK: - Manual Search View

public struct ManualSearchView: View {
    let selectedImage: UIImage?
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResult: AIService.WasteClassificationResult?
    @State private var showingSearchResult = false
    @State private var errorMessage: String?
    @Binding var showingSearch: Bool
    @Binding var showingReportError: Bool
    @StateObject private var aiService = AIService()
    
    public var body: some View {
        return ScrollableViewWithFloatingBack(backAction: {
            showingSearch = false
        }) {
        VStack(spacing: 0) {
                // Captured Image Display - Full width at top
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                    .clipped()
            } else {
                Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                    .overlay(
                        Image(systemName: "photo")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.6))
                    )
            }
            
            // Manual Search Interface
                VStack(alignment: .center, spacing: 20) {
                    VStack(spacing: 8) {
                Text("Manual Search")
                            .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                            .multilineTextAlignment(.center)
                
                Text("Enter the name of the item you want to recycle")
                            .font(.system(size: 16))
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    }
                
                // Search Field
                    VStack(spacing: 16) {
                    TextField("e.g., cardboard box, plastic bottle...", text: $searchText)
                        .font(.system(size: 16))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.brandWhite)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.brandMutedBlue.opacity(0.3), lineWidth: 1)
                            )
                        .disabled(isSearching)
                    
                    // Search Button
                    Button(action: {
                        Task {
                            await performTextSearch()
                        }
                    }) {
                            HStack(spacing: 8) {
                            if isSearching {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "magnifyingglass")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                Text(isSearching ? "Searching..." : "Search")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(searchText.isEmpty || isSearching ? Color.gray : Color.brandSkyBlue)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            )
                        }
                        .disabled(searchText.isEmpty || isSearching)
                    }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                            .font(.system(size: 14))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
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
                                .font(.system(size: 16, weight: .medium))
                        Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.top, 16)
                .padding(.bottom, 100)
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
    
        func performTextSearch() async {
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
            // All bin types use the same format

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

    
    // MARK: - Thank You View

    public struct ThankYouView: View {
        @Binding var showingThankYou: Bool
    @Binding var showingReport: Bool
    
        public var body: some View {
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
}
