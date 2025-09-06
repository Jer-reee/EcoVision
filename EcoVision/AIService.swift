//
//  AIService.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation
import UIKit

// MARK: - AI Service for Waste Classification

class AIService: ObservableObject {
    @Published var isProcessing = false
    @Published var errorMessage: String?
    
    // MARK: - Configuration
    let apiKey = AIConfig.openAIAPIKey
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    

    
    // MARK: - Bin Type Enum
    
    enum BinType: String, CaseIterable {
        case red = "red"
        case yellow = "yellow"
        case green = "green"
        case purple = "purple"
        case ewaste = "ewaste"
        case other = "other"
        case none = "No Bin"
        
        var color: String {
            switch self {
            case .red: return "red"
            case .yellow: return "yellow"
            case .green: return "green"
            case .purple: return "purple"
            case .ewaste, .other, .none: return "gray"
            }
        }
        
        var imageName: String {
            switch self {
            case .red: return "Red Bin"
            case .yellow: return "Yellow Bin"
            case .green: return "Green Bin"
            case .purple: return "Purple Bin"
            case .ewaste, .none: return "Grey Bin"
            case .other: return "Transfer Station"
            }
        }
    }
    
    // MARK: - Waste Classification Result
    
    struct WasteClassificationResult {
        let itemName: String
        let binType: BinType
        let binColor: String
        let binImageName: String
        let description: String
        let instructions: String
        let confidence: Double
        
        var binColor: String {
            return binType.color
        }
        
        var binImageName: String {
            return binType.imageName
        }
    }
    
    // MARK: - Image Analysis
    
    func analyzeWasteImage(_ image: UIImage) async -> WasteClassificationResult? {
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }
        
        do {
            // Convert image to base64
            guard let imageData = image.jpegData(compressionQuality: AIConfig.imageCompressionQuality) else {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Failed to process image"
                }
                return nil
            }
            
            let base64Image = imageData.base64EncodedString()
            
            // Create ChatGPT request
            let request = createChatGPTRequest(imageBase64: base64Image)
            
            // Make API call
            let result = try await performChatGPTRequest(request)
            
            await MainActor.run {
                isProcessing = false
            }
            
            return result
            
        } catch {
            await MainActor.run {
                isProcessing = false
                errorMessage = "AI analysis failed: \(error.localizedDescription)"
            }
            return nil
        }
    }
    
    // MARK: - ChatGPT Request Creation
    
    private func createChatGPTRequest(imageBase64: String) -> [String: Any] {
        let systemPrompt = "You are a waste classification expert for Ballarat, Victoria, Australia. Analyze the provided image and classify the waste item according to Ballarat's recycling standards. BIN TYPES: red (General waste), yellow (Paper and plastic recycling), green (Food waste and green waste), purple (Glass recycling), ewaste (E-waste), other (Take to transfer station). Respond with a JSON object: {\"itemName\": \"exact item name\", \"binType\": \"red|yellow|green|purple|ewaste|other\", \"description\": \"brief description\", \"instructions\": \"specific disposal instructions\", \"confidence\": 0.99}"
        
        return [
            "model": AIConfig.model,
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Please analyze this waste item and provide classification according to Ballarat recycling standards."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(imageBase64)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": AIConfig.maxTokens,
            "temperature": AIConfig.temperature
        ]
    }
    
    // MARK: - API Request
    
    private func performChatGPTRequest(_ request: [String: Any]) async throws -> WasteClassificationResult {
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: request)
            // Debug: Print request details (remove in production)
            print("🔗 AI Request URL: \(url)")
            print("📋 AI Request Headers: \(urlRequest.allHTTPHeaderFields ?? [:])")
            print("🔑 API Key configured: \(AIConfig.isAPIKeyConfigured)")
            print("📏 Request body size: \(urlRequest.httpBody?.count ?? 0) bytes")
        } catch {
            print("❌ Failed to serialize request: \(error)")
            throw AIError.invalidRequest
        }
        
        let (data, response): (Data, URLResponse)
        do {
            print("🌐 Making network request...")
            (data, response) = try await URLSession.shared.data(for: urlRequest)
            print("✅ Network request completed")
        } catch {
            print("❌ Network request failed: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            throw AIError.apiError("Network error: \(error.localizedDescription)")
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw AIError.invalidResponse
        }
        
        print("📡 HTTP Status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            print("❌ HTTP Error \(httpResponse.statusCode)")
            
            // Try to parse error response for more details
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("🔍 Full Error Response: \(errorJson)")
                
                if let error = errorJson["error"] as? [String: Any] {
                    let message = error["message"] as? String ?? "Unknown error"
                    let type = error["type"] as? String ?? "Unknown type"
                    let code = error["code"] as? String ?? "Unknown code"
                    
                    print("🚨 Error Details:")
                    print("   Type: \(type)")
                    print("   Code: \(code)")
                    print("   Message: \(message)")
                    
                    throw AIError.apiError("HTTP \(httpResponse.statusCode): \(message)")
                }
            } else {
                print("❌ Unable to parse error response")
            }
            
            throw AIError.apiError("HTTP \(httpResponse.statusCode)")
        }
        
        return try parseChatGPTResponse(data)
    }
    
    // MARK: - Response Parsing
    
    private func parseChatGPTResponse(_ data: Data) throws -> WasteClassificationResult {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.invalidResponse
        }
        
        print("🤖 RAW AI RESPONSE:")
        print("📄 Full Content: \(content)")
        
            throw AIError.invalidResponse
        }
        
        print("🔍 Parsed JSON Object: \(result)")
        
        return try createWasteClassificationResult(from: result)
    }
    
    private func createWasteClassificationResult(from json: [String: Any]) throws -> WasteClassificationResult {
        guard let itemName = json["itemName"] as? String,
              let binTypeString = json["binType"] as? String,
              let description = json["description"] as? String,
              let instructions = json["instructions"] as? String,
              let confidence = json["confidence"] as? Double else {
            throw AIError.invalidResponse
        }
        
        let binType = BinType(rawValue: binTypeString) ?? .none
        
        return WasteClassificationResult(
            itemName: itemName,
            binType: binType,
            binColor: binType.color,
            binImageName: binType.imageName,
            description: description,
            instructions: instructions,
        )
    }
    
    // MARK: - Error Handling
    
    enum AIError: Error, LocalizedError {
        case invalidURL
        case invalidRequest
        case invalidResponse
        case apiError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid API URL"
            case .invalidRequest:
                return "Invalid request format"
            case .invalidResponse:
                return "Invalid response from AI service"
            case .apiError(let message):
                return "API Error: \(message)"
            }
        }
    }
    
    // MARK: - Text Analysis
    
    func analyzeWasteText(_ text: String) async throws -> WasteClassificationResult {
        await MainActor.run {
            isProcessing = true
            errorMessage = nil
        }
        
        do {
            // Create ChatGPT request for text analysis
            let request = createChatGPTTextRequest(text: text)
            
            // Make API call
            let result = try await performChatGPTRequest(request)
            
            await MainActor.run {
                isProcessing = false
            }
            
            return result
            
        } catch {
            await MainActor.run {
                isProcessing = false
                errorMessage = "Text analysis failed: \(error.localizedDescription)"
            }
            throw error
        }
    }
    
    // MARK: - ChatGPT Text Request Creation
    
    private func createChatGPTTextRequest(text: String) -> [String: Any] {
        let systemPrompt = "You are a waste classification expert for Ballarat, Victoria, Australia. Analyze the provided text description and classify the waste item according to Ballarat's recycling standards. BIN TYPES: red (General waste), yellow (Paper and plastic recycling), green (Food waste and green waste), purple (Glass recycling), ewaste (E-waste), other (Take to transfer station). Respond with a JSON object: {\"itemName\": \"exact item name\", \"binType\": \"red|yellow|green|purple|ewaste|other\", \"description\": \"brief description\", \"instructions\": \"specific disposal instructions\", \"confidence\": 0.95}"
        
        return [
            "model": AIConfig.model,
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": "Please analyze this waste item description and provide classification according to Ballarat recycling standards: \(text)"
                ]
            ],
            "max_tokens": AIConfig.maxTokens,
            "temperature": AIConfig.temperature
        ]
    }
