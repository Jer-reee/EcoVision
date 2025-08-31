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
    
        // MARK: - Ballarat Recycling Standards
    private let ballaratRecyclingStandards = """
BALLARAT RECYCLING STANDARDS:

YELLOW BIN (Paper and Plastic Recycling):
- Paper and cardboard (clean and dry)
- Plastic bottles and containers (numbers 1-7)
- Aluminium and steel cans and containers
- Milk and juice cartons
- Plastic packaging and containers

RED BIN (General Waste):
- Food waste and scraps
- Plastic bags and soft plastics
- Nappies and sanitary items
- Broken ceramics and crockery
- Contaminated items
- Non-recyclable materials

GREEN BIN (Organic and Garden Waste):
- Garden clippings and prunings
- Leaves and branches
- Grass clippings
- Weeds (without seeds)
- Food scraps and organic waste
- Kitchen waste

PURPLE BIN (Glass Recycling):
- Glass bottles and jars (all colors)
- Wine and beer bottles
- Food jars and containers
- Glass containers (clean and empty)

SPECIAL COLLECTION:
- Batteries (household and car)
- Electronics and e-waste
- Light bulbs and fluorescent tubes
- Paint and chemicals
- Oil and filters
- Mattresses and furniture

"""
    
    // MARK: - Waste Classification Result
    
    struct WasteClassificationResult {
        let itemName: String
        let binType: BinType
        let binColor: String
        let binImageName: String
        let description: String
        let instructions: String
        let confidence: Double
        let isSpecialCollection: Bool
        let specialCollectionType: String?
    }
    
    enum BinType: String, CaseIterable {
        case yellow = "Yellow Bin"
        case red = "Red Bin"
        case green = "Green Bin"
        case purple = "Purple Bin"
        case special = "Special Collection"
        case none = "No Bin"
        
        var color: String {
            switch self {
            case .yellow: return "Yellow"
            case .red: return "Red"
            case .green: return "Green"
            case .purple: return "Purple"
            case .special: return "Purple"
            case .none: return "Gray"
            }
        }
        
        var imageName: String {
            switch self {
            case .yellow: return "Yellow Bin"
            case .red: return "Red Bin"
            case .green: return "Green Bin"
            case .purple: return "Purple Bin"
            case .special: return "Purple Bin"
            case .none: return "Gray Bin"
            }
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
        let systemPrompt = """
        You are a waste classification expert for Ballarat, Australia. Analyze the provided image and classify the waste item according to Ballarat's recycling standards.

        \(ballaratRecyclingStandards)

        Respond with a JSON object in this exact format:
        {
            "itemName": "exact item name",
            "binType": "yellow|red|green|purple|special|none",
            "description": "brief description of the item",
            "instructions": "specific disposal instructions for Ballarat",
            "confidence": 0.95,
            "isSpecialCollection": false,
            "specialCollectionType": null,

        }

        Rules:
        - Be very specific about the item name
        - Use exact bin types from the standards: yellow, red, green, purple, special, none
        - CRITICAL: Always match the binType with your instructions
        - ALUMINUM/ALUMINIUM CANS = "yellow" bin type (never "none")
        - DRINK CONTAINERS (aluminum, plastic) = "yellow" bin type
        - Glass bottles and jars = "purple" bin type
        - Food waste and organic matter = "green" bin type
        - Non-recyclable items = "red" bin type
        - Batteries, electronics, chemicals = "special" bin type
        - Only use "none" when truly unidentifiable
        - Provide clear, actionable instructions that match your bin type choice
        - Set confidence based on image clarity (0.0-1.0)
        
        MANDATORY EXAMPLES - Follow these exactly:
        - Aluminum/Aluminium can (Coke, beer, etc.) → {"binType": "yellow"}
        - Plastic bottle/container → {"binType": "yellow"}
        - Glass bottle/jar → {"binType": "purple"}
        - Food scraps/organic waste → {"binType": "green"}
        - Battery/electronics → {"binType": "special"}
        
        CRITICAL: If you say "yellow bin" in instructions, you MUST use binType: "yellow"
        CRITICAL: If you say "purple bin" in instructions, you MUST use binType: "purple"
        CRITICAL: If you say "green bin" in instructions, you MUST use binType: "green"
        CRITICAL: If you say "red bin" in instructions, you MUST use binType: "red"
        """
        
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
        
        // Extract JSON from ChatGPT response
        guard let jsonStart = content.range(of: "{"),
              let jsonEnd = content.range(of: "}", options: .backwards) else {
            print("❌ No JSON found in response")
            throw AIError.invalidResponse
        }
        
        let jsonString = String(content[jsonStart.lowerBound...jsonEnd.upperBound])
        print("📋 Extracted JSON: \(jsonString)")
        
        guard let jsonData = jsonString.data(using: .utf8),
              let result = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ Failed to parse JSON")
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
        let isSpecialCollection = json["isSpecialCollection"] as? Bool ?? false
        let specialCollectionType = json["specialCollectionType"] as? String
        
        return WasteClassificationResult(
            itemName: itemName,
            binType: binType,
            binColor: binType.color,
            binImageName: binType.imageName,
            description: description,
            instructions: instructions,
            confidence: confidence,
            isSpecialCollection: isSpecialCollection,
            specialCollectionType: specialCollectionType
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
        let systemPrompt = """
        You are a waste classification expert for Ballarat, Australia. Analyze the provided text description and classify the waste item according to Ballarat's recycling standards.

        \(ballaratRecyclingStandards)

        Respond with a JSON object in this exact format:
        {
            "itemName": "exact item name",
            "binType": "yellow|red|green|purple|special|none",
            "description": "brief description of the item",
            "instructions": "specific disposal instructions for Ballarat",
            "confidence": 0.95,
            "isSpecialCollection": false,
            "specialCollectionType": null,

        }

        CRITICAL CLASSIFICATION RULES:
        - ALUMINUM/ALUMINIUM CANS → binType: "yellow" (NEVER "none")
        - PLASTIC BOTTLES/CONTAINERS → binType: "yellow"
        - GLASS BOTTLES/JARS → binType: "purple" 
        - FOOD SCRAPS/ORGANIC → binType: "green"
        - BATTERIES/ELECTRONICS → binType: "special"
        - NON-RECYCLABLES → binType: "red"
        - UNKNOWN/UNCLEAR → binType: "none"

        MANDATORY EXAMPLES - Follow these exactly:
        - Input: "aluminum can" OR "aluminium can" OR "Coke can" → Output: {"binType": "yellow"}
        - Input: "plastic bottle" OR "water bottle" → Output: {"binType": "yellow"}
        - Input: "glass bottle" OR "wine bottle" OR "jar" → Output: {"binType": "purple"}
        - Input: "food scraps" OR "banana peel" → Output: {"binType": "green"}
        - Input: "battery" OR "phone" OR "electronics" → Output: {"binType": "special"}
        
        CRITICAL: If you say "yellow bin" in instructions, you MUST use binType: "yellow"
        CRITICAL: If you say "purple bin" in instructions, you MUST use binType: "purple"
        CRITICAL: If you say "green bin" in instructions, you MUST use binType: "green"
        CRITICAL: If you say "red bin" in instructions, you MUST use binType: "red"
        """
        
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
}
   
