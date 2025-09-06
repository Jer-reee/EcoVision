//
//  WasteCollectionService.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import Foundation
import Combine

// MARK: - API Service

class WasteCollectionService: ObservableObject {
    @Published var collectionData: [WasteCollectionRecord] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL = "https://data.ballarat.vic.gov.au"
    private let path = "/api/explore/v2.1/catalog/datasets/waste-collection-days/records"
    
    func fetchWasteCollection(for address: String) {
        guard !address.isEmpty && address != "Start typing..." else { return }
        
        isLoading = true
        errorMessage = nil
        
        // URL encode the address for the API call
        let queryParams = "where=address like \"\(address)\"&limit=20"
        let urlString = "\(baseURL)\(path)?\(queryParams)"
        
        // Print the URL being requested
        print("🌐 API REQUEST URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            // Print response status
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("❌ Network Error: \(error.localizedDescription)")
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self?.errorMessage = "No data received"
                    return
                }
                
                // Print raw response data
                if let dataString = String(data: data, encoding: .utf8) {
                    print("📄 Raw API Response:")
                    print(dataString)
                }
                
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(WasteCollectionResponse.self, from: data)
                    
                    print("✅ Successfully parsed API response:")
                    print("📊 Total count: \(response.totalCount)")
                    print("📦 Number of results: \(response.results.count)")
                    
                    // Print details of each result
                    for (index, record) in response.results.enumerated() {
                        print("🏠 Result \(index + 1):")
                        print("   Address: \(record.address ?? "N/A")")
                        print("   Collection Day: \(record.collectionDay ?? "N/A")")
                        print("   Next Waste: \(record.nextwaste ?? "N/A")")
                        print("   Next Recycle: \(record.nextrecycle ?? "N/A")")
                        print("   Next Green: \(record.nextgreen ?? "N/A")")
                        print("   Zone: \(record.zone ?? 0)")
                    }
                    
                    self?.collectionData = response.results
                    
                    if response.results.isEmpty {
                        print("⚠️ No collection data found for this address")
                        self?.errorMessage = "No collection data found for this address"
                    } else {
                        print("🎉 Collection data loaded successfully!")
                    }
                } catch {
                    print("❌ Decoding error: \(error)")
                    self?.errorMessage = "Failed to parse data: \(error.localizedDescription)"
                    
                    // Print more detailed error information
                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("🔑 Key not found: \(key), Context: \(context)")
                        case .typeMismatch(let type, let context):
                            print("🔄 Type mismatch: \(type), Context: \(context)")
                        case .valueNotFound(let type, let context):
                            print("🕳️ Value not found: \(type), Context: \(context)")
                        case .dataCorrupted(let context):
                            print("💥 Data corrupted: \(context)")
                        @unknown default:
                            print("❓ Unknown decoding error")
                        }
                    }
                }
            }
        }.resume()
    }
}
