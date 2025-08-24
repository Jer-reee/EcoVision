//
//  DataModels.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct WasteCollectionResponse: Codable {
    let totalCount: Int
    let results: [WasteCollectionRecord]
    
    private enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case results
    }
}

struct WasteCollectionRecord: Codable, Identifiable, Equatable {
    let id = UUID()
    let propnum: String?
    let address: String?
    let collectionday: String?
    let nextwaste: String?
    let nextrecycle: String?
    let nextgreen: String?
    let suburb: String?
    let street: String?
    let serviceType: String?
    let collectionDay: String?
    let zone: Int?
    
    private enum CodingKeys: String, CodingKey {
        case propnum, address, collectionday, nextwaste, nextrecycle, nextgreen
        case suburb, street, zone
        case serviceType = "service_type"
        case collectionDay = "collection_day"
    }
    
    // Implement Equatable based on data content, not the UUID
    static func == (lhs: WasteCollectionRecord, rhs: WasteCollectionRecord) -> Bool {
        return lhs.propnum == rhs.propnum &&
               lhs.address == rhs.address &&
               lhs.collectionday == rhs.collectionday &&
               lhs.nextwaste == rhs.nextwaste &&
               lhs.nextrecycle == rhs.nextrecycle &&
               lhs.nextgreen == rhs.nextgreen &&
               lhs.suburb == rhs.suburb &&
               lhs.street == rhs.street &&
               lhs.serviceType == rhs.serviceType &&
               lhs.collectionDay == rhs.collectionDay &&
               lhs.zone == rhs.zone
    }
}

// Computed properties for individual collection types
extension WasteCollectionRecord {
    var wasteCollections: [WasteCollection] {
        var collections: [WasteCollection] = []
        
        if let nextwaste = nextwaste {
            collections.append(WasteCollection(
                type: "Household Waste",
                date: nextwaste,
                color: .red,
                frequency: .weekly
            ))
        }
        
        if let nextrecycle = nextrecycle {
            collections.append(WasteCollection(
                type: "Mixed Recycling", 
                date: nextrecycle,
                color: .yellow,
                frequency: .fortnightly
            ))
        }
        
        if let nextgreen = nextgreen {
            collections.append(WasteCollection(
                type: "FOGO",
                date: nextgreen,
                color: .green,
                frequency: .fortnightly
            ))
        }
        
        return collections
    }
}

enum CollectionFrequency {
    case weekly
    case fortnightly
}

struct WasteCollection: Identifiable {
    let id = UUID()
    let type: String
    let date: String
    let color: Color
    let frequency: CollectionFrequency
    
    var collectionDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
    
    // Calculate all collection dates within a given date range
    func collectionDates(from startDate: Date, to endDate: Date) -> [Date] {
        guard let baseDate = collectionDate else { return [] }
        
        var dates: [Date] = []
        let calendar = Calendar.current
        
        // Calculate the interval based on frequency
        let dayInterval: Int
        switch frequency {
        case .weekly:
            dayInterval = 7
        case .fortnightly:
            dayInterval = 14
        }
        
        // Find the first collection date within or before the range
        var currentDate = baseDate
        
        // Go backwards to find collections before the start date if needed
        while currentDate > startDate {
            if let previousDate = calendar.date(byAdding: .day, value: -dayInterval, to: currentDate) {
                currentDate = previousDate
            } else {
                break
            }
        }
        
        // Go forward to find the first date in range
        while currentDate < startDate {
            if let nextDate = calendar.date(byAdding: .day, value: dayInterval, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        // Collect all dates within the range
        while currentDate <= endDate {
            if currentDate >= startDate {
                dates.append(currentDate)
            }
            
            if let nextDate = calendar.date(byAdding: .day, value: dayInterval, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }
}
