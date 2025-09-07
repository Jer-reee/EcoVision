//
//  CalendarView.swift
//  EcoVision
//
//  Created by Jerry Zhou on 7/8/2025.
//

import SwiftUI

// MARK: - Calendar View

struct CalendarView: View {
    @ObservedObject var wasteService: WasteCollectionService
    let userAddress: String
    @State private var currentDate = Date()
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                VStack(spacing: min(geometry.size.height * 0.01, 8)) {
                    Text("Calendar")
                        .font(.system(size: min(geometry.size.width * 0.08, 34), weight: .bold))
                        .foregroundColor(Color.brandVeryDarkBlue)
                        .padding(.top, min(geometry.size.height * 0.025, 20))
                    
                    // Loading indicator
                    if wasteService.isLoading {
                        ProgressView("Loading collection data...")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandMutedBlue)
                    } else if let errorMessage = wasteService.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(.red)
                    } else if !wasteService.collectionData.isEmpty {
                        Text("Collection schedule for \(userAddress)")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandMutedBlue)
                    }
                }
            
                // Month Navigation
                HStack {
                    Button(action: { changeMonth(-1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(Color.brandSkyBlue)
                            .font(.system(size: min(geometry.size.width * 0.06, 22)))
                    }
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: currentDate))
                        .font(.system(size: min(geometry.size.width * 0.05, 20), weight: .semibold))
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Spacer()
                    
                    Button(action: { changeMonth(1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color.brandSkyBlue)
                            .font(.system(size: min(geometry.size.width * 0.06, 22)))
                    }
                }
                .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                .padding(.vertical, min(geometry.size.height * 0.02, 15))
            
                // Calendar Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: min(geometry.size.width * 0.01, 5)) {
                    // Weekday headers
                    ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                        Text(day)
                            .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .medium))
                            .foregroundColor(Color.brandMutedBlue)
                            .frame(height: min(geometry.size.height * 0.04, 30))
                    }
                    
                    // Calendar days
                    ForEach(calendarDays, id: \.self) { date in
                        CalendarDayView(
                            date: date, 
                            currentDate: currentDate,
                            collectionData: wasteService.collectionData,
                            geometry: geometry
                        )
                    }
                }
                .padding(.horizontal, min(geometry.size.width * 0.05, 20))
            
            Spacer()
                .frame(height: min(geometry.size.height * 0.02, 15))
            
                // Legend
                VStack(alignment: .leading, spacing: min(geometry.size.height * 0.01, 8)) {
                    HStack {
                        Rectangle()
                            .fill(.red)
                            .frame(width: min(geometry.size.width * 0.05, 20), height: min(geometry.size.height * 0.015, 12))
                        Text("Household Waste")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(Color(red: 1.0, green: 0.859, blue: 0.345))
                            .frame(width: min(geometry.size.width * 0.05, 20), height: min(geometry.size.height * 0.015, 12))
                        Text("Mixed Recycling")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandVeryDarkBlue)
                    }
                    
                    HStack {
                        Rectangle()
                            .fill(.green)
                            .frame(width: min(geometry.size.width * 0.05, 20), height: min(geometry.size.height * 0.015, 12))
                        Text("FOGO")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandVeryDarkBlue)
                        
                        Spacer()
                    }
                    
                    if !wasteService.collectionData.isEmpty {
                        VStack(alignment: .leading, spacing: min(geometry.size.height * 0.005, 4)) {
                            Text("Collection Schedule:")
                                .font(.system(size: min(geometry.size.width * 0.035, 14), weight: .medium))
                                .foregroundColor(Color.brandVeryDarkBlue)
                                .padding(.top, min(geometry.size.height * 0.01, 8))
                            
                            Text("• Red bins: Weekly")
                                .font(.system(size: min(geometry.size.width * 0.035, 14)))
                                .foregroundColor(Color.brandMutedBlue)
                            
                            Text("• Yellow & Green bins: Fortnightly")
                                .font(.system(size: min(geometry.size.width * 0.035, 14)))
                                .foregroundColor(Color.brandMutedBlue)
                        }
                    } else {
                        Text("No collection data available")
                            .font(.system(size: min(geometry.size.width * 0.035, 14)))
                            .foregroundColor(Color.brandMutedBlue)
                            .padding(.top, min(geometry.size.height * 0.01, 8))
                    }
                }
                .padding(.horizontal, min(geometry.size.width * 0.05, 20))
                .padding(.bottom, min(geometry.size.height * 0.03, 20))
            }
            .background(Color.brandWhite)
        }
        .onAppear {
            wasteService.fetchWasteCollection(for: userAddress)
        }
    }
    
    private var calendarDays: [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var days: [Date] = []
        for i in 0..<42 { // 6 weeks * 7 days
            if let date = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                days.append(date)
            }
        }
        return days
    }
    
    private func changeMonth(_ direction: Int) {
        if let newDate = calendar.date(byAdding: .month, value: direction, to: currentDate) {
            currentDate = newDate
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let currentDate: Date
    let collectionData: [WasteCollectionRecord]
    let geometry: GeometryProxy
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: min(geometry.size.height * 0.002, 2)) {
            ZStack {
                // Circle background for current date
                if isToday {
                    Circle()
                        .fill(Color.brandSkyBlue.opacity(0.2))
                        .frame(width: min(geometry.size.width * 0.07, 28), height: min(geometry.size.width * 0.07, 28))
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: min(geometry.size.width * 0.035, 14)))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? Color.brandVeryDarkBlue : Color.gray)
            }
            
            // Real waste collection indicators with recurring dates
            if isCurrentMonth {
                HStack(spacing: min(geometry.size.width * 0.002, 1)) {
                    ForEach(collectionsForDate, id: \.type) { collection in
                        Rectangle()
                            .fill(collection.color)
                            .frame(width: min(geometry.size.width * 0.02, 8), height: min(geometry.size.height * 0.004, 3))
                    }
                }
            }
        }
        .frame(height: min(geometry.size.height * 0.05, 40))
        .frame(maxWidth: .infinity)
    }
    
    private var isCurrentMonth: Bool {
        calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var collectionsForDate: [WasteCollection] {
        var collectionsOnThisDate: [WasteCollection] = []
        
        // Calculate the date range for the current month to optimize calculations
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let endOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.end ?? currentDate
        
        for record in collectionData {
            for collection in record.wasteCollections {
                // Get all recurring collection dates for this collection type within the month
                let recurringDates = collection.collectionDates(from: startOfMonth, to: endOfMonth)
                
                // Check if any recurring date matches this calendar day
                for recurringDate in recurringDates {
                    if calendar.isDate(recurringDate, inSameDayAs: date) {
                        collectionsOnThisDate.append(collection)
                        break // Only add once per collection type per day
                    }
                }
            }
        }
        
        return collectionsOnThisDate
    }
}
