//
//  AIConfig.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation

struct AIConfig {
    // MARK: - OpenAI Configuration
    
    /// OpenAI API Key
    /// Get your API key from: https://platform.openai.com/api-keys
    /// Replace this with your actual API key for production use
    static let openAIAPIKey = "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"
    
    // MARK: - AI Model Configuration
    
    /// GPT model to use for image analysis
    static let model = "gpt-4o"
    
    /// Maximum tokens for response
    static let maxTokens = 10000
    
    /// Temperature for response creativity (0.0 = deterministic, 1.0 = creative)
    static let temperature = 0.1
    
    // MARK: - Image Processing
    
    /// JPEG compression quality for image upload
    static let imageCompressionQuality: CGFloat = 0.8
    
    /// Maximum image size in bytes (OpenAI limit: 20MB)
    static let maxImageSize: Int = 20 * 1024 * 1024
    
    // MARK: - Ballarat Specific Configuration
    
    /// City name for recycling standards
    static let cityName = "Ballarat"
    
    /// State for recycling standards
    static let stateName = "Victoria"
    
    /// Country for recycling standards
    static let countryName = "Australia"
    
    // MARK: - Error Messages
    
    static let errorMessages = [
        "api_key_missing": "OpenAI API key not configured. Please add your API key to AIConfig.swift",
        "image_processing_failed": "Failed to process image. Please try again.",
        "network_error": "Network error. Please check your internet connection.",
        "api_error": "AI service error. Please try again later.",
        "invalid_response": "Invalid response from AI service. Please try again."
    ]
    
    // MARK: - Validation
    
    /// Check if API key is configured
    static var isAPIKeyConfigured: Bool {
        return !openAIAPIKey.isEmpty && openAIAPIKey.hasPrefix("sk-") && openAIAPIKey.count > 20
    }
    
    /// Get error message for key
    static func getErrorMessage(for key: String) -> String {
        return errorMessages[key] ?? "Unknown error occurred"
    }
}
