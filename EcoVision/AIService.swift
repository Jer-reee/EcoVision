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
    
        // MARK: - Ballarat Waste Guide Standards
    private let ballaratWasteGuide = """
BALLARAT WASTE GUIDE (City of Ballarat):

RED BIN (General Waste):
- Nappies, baby wipes
- Plastic bags, soft plastics
- Takeaway coffee cups, straws
- Toothpaste tubes, toothbrushes
- Meat trays, foil trays
- Gloves, band aids, earbuds, wipes
- Cigarette butts, cling wrap/plastic film
- Coffee cups and lids
- Face wipes, sanitary products
- Kitty litter, animal waste
- Vacuum cleaner dust
- Waxed cardboard, waxed/toiled paper
- Polystyrene (household plastic #6)
- Styrofoam, foam boxes
- Non-recyclable materials

YELLOW BIN (Paper and Plastic Recycling):
- CLEAN, EMPTY cans and aluminium
- Plastic bottles and containers from kitchen, laundry and bathroom
- Paper and cardboard
- Aluminium foil (clean of food)
- Cardboard, magazines, newspapers
- Office paper, envelopes (no window)
- Greeting cards, telephone books
- Pizza boxes (clean of food and oils)
- Tissue boxes with plastic removed
- Toilet rolls (empty)
- Milk bottles (plastic #2) no lids
- Juice bottles (with no handle)
- Cordial bottles (with handle)
- Shampoo and conditioner bottles
- Detergent bottles (empty)
- Sauce bottles (empty)
- Medicine bottles (glass) (clean)
- Cosmetic containers (plastic or glass)
- Ice cream containers (clean)
- Margarine containers (clean)
- Yoghurt containers (clean)
- Takeaway containers (plastic) (clean)
- Plastic containers (rigid plastic)
- Plant pots (empty)
- Long life cartons, Tetra Paks
- NO LIDS of any type
- DO NOT BAG KEEP IT LOOSE

GREEN BIN (Food Waste and Green Waste):
- Leaves, weeds, prunings
- Grass, flowers and small branches 10mm in diameter and 55mm long
- Tree prunings, branches (trees)
- Garden clippings and prunings
- Fruit and vegetables
- Food scraps and organic waste
- Kitchen waste, vegetable scraps
- Tea bags with string
- DO NOT BAG KEEP IT LOOSE

PURPLE BIN (Glass Recycling):
- Glass bottles and jars (all colors)
- Wine bottles (empty)
- Beer bottles
- Food jars and containers
- Alcohol bottles glass (no lids)
- Glass containers (clean and empty)
- Glass ware, ceramics (broken)
- Window glass (broken-wrapped)
- NO LIDS of any type

E-WASTE (Take to E-Waste Collection Point or Transfer Station):
- Electronic waste (e-waste)
- Batteries (car and household)
- Cameras, computers (and parts)
- Mobile phones, music cards
- Radios, televisions
- VCRs/VHS players
- Microwaves, refrigerators
- Washing machines, white goods
- Fridges/freezers/white goods
- Toys (electric)
- Smoke alarms
- Light globes (compact fluorescent tubes)
- Hearing aid batteries
- Printers and printer cartridges
- All electronic items cannot be placed in general waste bin
- Take to designated e-waste collection points or transfer station

OTHER (Take to Transfer Station):
- Building waste (bricks, concrete, rubble etc)
- Car parts (metal or electronic)
- Carpets, doors
- Furniture (good condition - donate to charity)
- Bicycles, lawn mowers
- Scrap metals
- Timber (treated), timber (natural, under 10cm diameter)
- Wood (treated)
- Soil and rock
- Plaster board
- Paint, paint tins
- Chemicals (pool, garden, household)
- Poisons, pesticides, farm chemicals
- Fuels and diesels, oil (cooking), oil (engine)
- Gas bottles (all types)
- Drums (chemical containers - empty and triple rinsed)
- Asbestos
- Mattresses
- Hypodermic needles (in sealable container)
- Syringes/sharps (wrapped)
- Medicines
- X-ray images
- Large logs (can be disposed at Transfer Station)

SPECIAL NOTES:
- Pass on glass drop-off sites located around Ballarat
- Visit recyclingballarat.com or call 5320 5500 for glass drop-off sites
- Ballarat Transfer Station: 119 Gillies Street South, Alfredton
- Visit chemclear.org.au to register chemicals
- Visit recyclingnearyou.com.au for more information
- Visit returnmed.com.au/faqs for more information
- Contact Environmental Health team for disposal information (25 Armstrong Street South, Ballarat)
- Any public toilet provides a syringe bin and is collected by a contractor service

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
        
        // All bin types use the same format - no special collections
    }
    
    enum BinType: String, CaseIterable {
        case red = "Red Bin"
        case yellow = "Yellow Bin"
        case green = "Green Bin"
        case purple = "Purple Bin"
        case ewaste = "E-Waste"
        case other = "Other"
        
        var color: String {
            switch self {
            case .red: return "red"
            case .yellow: return "yellow"
            case .green: return "green"
            case .purple: return "purple"
            case .ewaste: return "gray"
            case .other: return "gray"
            }
        }
        
        var imageName: String {
            switch self {
            case .red: return "Red Bin"
            case .yellow: return "Yellow Bin"
            case .green: return "Green Bin"
            case .purple: return "Purple Bin"
            case .ewaste: return "Gray Bin"
            case .other: return "Transfer Station"
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
        You are a waste classification expert for Ballarat, Australia. Analyze the provided image and classify the waste item according to Ballarat's official waste guide.

        \(ballaratWasteGuide)

        Respond with a JSON object in this exact format:
        {
            "itemName": "exact item name",
            "binType": "red|yellow|green|purple|ewaste|other|none",
            "description": "brief description of the item",
            "instructions": "specific disposal instructions for Ballarat",
            "confidence": 0.95,
        }

        MANDATORY CLASSIFICATION RULES - NO EXCEPTIONS:
        
        IF YOU SEE ANY BATTERY (AA, AAA, 9V, car, household, hearing aid, etc.) → binType: "ewaste"
        IF YOU SEE ANY ELECTRONIC (phone, computer, TV, camera, etc.) → binType: "ewaste"
        IF YOU SEE ANY PAPER/CARDBOARD (box, newspaper, magazine) → binType: "yellow"
        IF YOU SEE ANY GLASS (bottle, jar) → binType: "purple"
        IF YOU SEE ANY FOOD/GARDEN WASTE → binType: "green"
        IF YOU SEE ANY PLASTIC BOTTLE/CAN (clean, empty) → binType: "yellow"
        IF YOU SEE ANY SOFT PLASTIC/BAG → binType: "red"
        
        ONLY use "other" for: building materials, chemicals, large furniture
        ONLY use "none" if: completely unidentifiable
        
        CRITICAL: BATTERIES = E-WASTE ALWAYS
        CRITICAL: ELECTRONICS = E-WASTE ALWAYS
        CRITICAL: PAPER/CARDBOARD = YELLOW ALWAYS
        
        BIN TYPE MAPPING:
        - RED BIN: General waste, nappies, soft plastics, coffee cups, meat trays, non-recyclables
        - YELLOW BIN: Clean empty cans, plastic bottles/containers, paper/cardboard (NO LIDS)
        - GREEN BIN: Food scraps, garden waste, leaves, prunings, organic matter, flowers
        - PURPLE BIN: Glass bottles/jars (NO LIDS)
        - E-WASTE: Batteries, electronics, computers, phones, appliances
        - OTHER: ONLY building materials, chemicals, large items (take to transfer station)
        - NONE: Only when truly unidentifiable
        
        MANDATORY EXAMPLES - Follow these exactly:
        - Aluminum/Aluminium can (Coke, beer, etc.) → {"binType": "yellow"}
        - Plastic bottle/container (clean, empty) → {"binType": "yellow"}
        - Glass bottle/jar (clean, empty) → {"binType": "purple"}
        - Food scraps/organic waste → {"binType": "green"}
        - Flowers/garden waste → {"binType": "green"}
        - Battery/electronics → {"binType": "ewaste"}
        - Soft plastics/bags → {"binType": "red"}
        - Building materials → {"binType": "other"}
        
        CRITICAL: If you say "red bin" in instructions, you MUST use binType: "red"
        CRITICAL: If you say "yellow bin" in instructions, you MUST use binType: "yellow"
        CRITICAL: If you say "green bin" in instructions, you MUST use binType: "green"
        CRITICAL: If you say "purple bin" in instructions, you MUST use binType: "purple"
        CRITICAL: If you say "e-waste" in instructions, you MUST use binType: "ewaste"
        CRITICAL: If you say "transfer station" in instructions, you MUST use binType: "other"
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
        
        // Extract JSON from ChatGPT response with improved error handling
        let jsonString = extractJSONFromContent(content)
        print("📋 Extracted JSON: \(jsonString)")
        
        // Validate JSON string is not empty
        guard !jsonString.isEmpty else {
            print("❌ Extracted JSON string is empty")
            throw AIError.invalidResponse
        }
        
        guard let jsonData = jsonString.data(using: .utf8),
              let result = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("❌ Failed to parse JSON")
            print("📋 JSON String that failed: \(jsonString)")
            throw AIError.invalidResponse
        }
        
        print("🔍 Parsed JSON Object: \(result)")
        
        return try createWasteClassificationResult(from: result)
    }
    
    // MARK: - JSON Extraction Helper
    
    private func extractJSONFromContent(_ content: String) -> String {
        // First, try to find the first complete JSON object
        guard let jsonStart = content.range(of: "{"),
              let jsonEnd = content.range(of: "}", options: .backwards),
              jsonEnd.upperBound > jsonStart.lowerBound else {
            print("❌ No valid JSON found in response")
            print("📄 Content length: \(content.count)")
            print("📄 Content preview: \(String(content.prefix(200)))")
            return ""
        }
        
        // Extract the JSON string
        let jsonString = String(content[jsonStart.lowerBound..<jsonEnd.upperBound])
        
        // Validate that we have a complete JSON object by checking bracket balance
        let openBraces = jsonString.filter { $0 == "{" }.count
        let closeBraces = jsonString.filter { $0 == "}" }.count
        
        if openBraces != closeBraces {
            print("⚠️ Unbalanced JSON braces: \(openBraces) open, \(closeBraces) close")
            // Try to find a more complete JSON object
            return extractCompleteJSONFromContent(content)
        }
        
        return jsonString
    }
    
    private func extractCompleteJSONFromContent(_ content: String) -> String {
        // More sophisticated JSON extraction that handles nested objects
        var braceCount = 0
        var jsonStart: String.Index?
        var jsonEnd: String.Index?
        
        for (index, char) in content.enumerated() {
            let stringIndex = content.index(content.startIndex, offsetBy: index)
            
            if char == "{" {
                if jsonStart == nil {
                    jsonStart = stringIndex
                }
                braceCount += 1
            } else if char == "}" {
                braceCount -= 1
                if braceCount == 0 && jsonStart != nil {
                    jsonEnd = content.index(after: stringIndex)
                    break
                }
            }
        }
        
        guard let start = jsonStart, let end = jsonEnd else {
            print("❌ Could not find complete JSON object")
            return ""
        }
        
        return String(content[start..<end])
    }
    
    private func createWasteClassificationResult(from json: [String: Any]) throws -> WasteClassificationResult {
        guard let itemName = json["itemName"] as? String,
              let binTypeString = json["binType"] as? String,
              let description = json["description"] as? String,
              let instructions = json["instructions"] as? String,
              let confidence = json["confidence"] as? Double else {
            throw AIError.invalidResponse
        }
        
        let binType = BinType(rawValue: binTypeString) ?? .other
        
        return WasteClassificationResult(
            itemName: itemName,
            binType: binType,
            binColor: binType.color,
            binImageName: binType.imageName,
            description: description,
            instructions: instructions,
            confidence: confidence
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
        You are a waste classification expert for Ballarat, Australia. Analyze the provided text description and classify the waste item according to Ballarat's official waste guide.

        \(ballaratWasteGuide)

        Respond with a JSON object in this exact format:
        {
            "itemName": "exact item name",
            "binType": "red|yellow|green|purple|ewaste|other|none",
            "description": "brief description of the item",
            "instructions": "specific disposal instructions for Ballarat",
            "confidence": 0.95,
        }

        MANDATORY CLASSIFICATION RULES - NO EXCEPTIONS:
        
        IF TEXT CONTAINS "battery" OR "batteries" → binType: "ewaste"
        IF TEXT CONTAINS "phone" OR "computer" OR "electronic" → binType: "ewaste"
        IF TEXT CONTAINS "cardboard" OR "paper" OR "newspaper" → binType: "yellow"
        IF TEXT CONTAINS "glass" OR "bottle" OR "jar" → binType: "purple"
        IF TEXT CONTAINS "food" OR "garden" OR "organic" → binType: "green"
        IF TEXT CONTAINS "plastic bottle" OR "can" (clean, empty) → binType: "yellow"
        IF TEXT CONTAINS "soft plastic" OR "bag" → binType: "red"
        
        ONLY use "other" for: building materials, chemicals, large furniture
        ONLY use "none" if: completely unidentifiable
        
        CRITICAL: BATTERIES = E-WASTE ALWAYS
        CRITICAL: ELECTRONICS = E-WASTE ALWAYS
        CRITICAL: PAPER/CARDBOARD = YELLOW ALWAYS

        MANDATORY EXAMPLES - Follow these exactly:
        - Input: "aluminum can" OR "aluminium can" OR "Coke can" → Output: {"binType": "yellow"}
        - Input: "plastic bottle" OR "water bottle" (clean, empty) → Output: {"binType": "yellow"}
        - Input: "glass bottle" OR "wine bottle" OR "jar" (clean, empty) → Output: {"binType": "purple"}
        - Input: "battery" OR "batteries" OR "household battery" OR "car battery" → Output: {"binType": "ewaste"}
        - Input: "phone" OR "computer" OR "laptop" OR "television" OR "TV" → Output: {"binType": "ewaste"}
        - Input: "food scraps" OR "banana peel" OR "garden waste" OR "flowers" → Output: {"binType": "green"}
        - Input: "soft plastic" OR "plastic bag" OR "coffee cup" → Output: {"binType": "red"}
        - Input: "cardboard box" OR "newspaper" OR "magazine" OR "paper" → Output: {"binType": "yellow"}
        - Input: "building materials" OR "chemicals" → Output: {"binType": "other"}
        
        CRITICAL: If you say "red bin" in instructions, you MUST use binType: "red"
        CRITICAL: If you say "yellow bin" in instructions, you MUST use binType: "yellow"
        CRITICAL: If you say "green bin" in instructions, you MUST use binType: "green"
        CRITICAL: If you say "purple bin" in instructions, you MUST use binType: "purple"
        CRITICAL: If you say "e-waste" in instructions, you MUST use binType: "ewaste"
        CRITICAL: If you say "transfer station" in instructions, you MUST use binType: "other"
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
   
