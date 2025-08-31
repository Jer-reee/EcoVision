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
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Calendar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                    .padding(.top, 20)
                
                // Loading indicator
                if wasteService.isLoading {
                    ProgressView("Loading collection data...")
                        .font(.caption)
                        .foregroundColor(Color.brandMutedBlue)
                } else if let errorMessage = wasteService.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                } else if !wasteService.collectionData.isEmpty {
                    Text("Collection schedule for \(userAddress)")
                        .font(.caption)
                        .foregroundColor(Color.brandMutedBlue)
                }
            }
            
            // Month Navigation
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.brandSkyBlue)
                        .font(.title2)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: currentDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.brandVeryDarkBlue)
                
                Spacer()
                
                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.brandSkyBlue)
                        .font(.title2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 5) {
                // Weekday headers
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color.brandMutedBlue)
                        .frame(height: 30)
                }
                
                // Calendar days
                ForEach(calendarDays, id: \.self) { date in
                    CalendarDayView(
                        date: date, 
                        currentDate: currentDate,
                        collectionData: wasteService.collectionData
                    )
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // Legend
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Rectangle()
                        .fill(.red)
                        .frame(width: 20, height: 12)
                    Text("Household Waste")
                        .font(.caption)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Spacer()
                    
                    Rectangle()
                        .fill(Color(red: 1.0, green: 0.859, blue: 0.345))
                        .frame(width: 20, height: 12)
                    Text("Mixed Recycling")
                        .font(.caption)
                        .foregroundColor(Color.brandVeryDarkBlue)
                }
                
                HStack {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 20, height: 12)
                    Text("FOGO")
                        .font(.caption)
                        .foregroundColor(Color.brandVeryDarkBlue)
                    
                    Spacer()
                }
                
                if !wasteService.collectionData.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Collection Schedule:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(Color.brandVeryDarkBlue)
                            .padding(.top, 8)
                        
                        Text("• Red bins: Weekly")
                            .font(.caption)
                            .foregroundColor(Color.brandMutedBlue)
                        
                        Text("• Yellow & Green bins: Fortnightly")
                            .font(.caption)
                            .foregroundColor(Color.brandMutedBlue)
                    }
                } else {
                    Text("No collection data available")
                        .font(.caption)
                        .foregroundColor(Color.brandMutedBlue)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Color.brandWhite)
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
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                // Circle background for current date
                if isToday {
                    Circle()
                        .fill(Color.brandSkyBlue.opacity(0.2))
                        .frame(width: 28, height: 28)
                }
                
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 14))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isCurrentMonth ? Color.brandVeryDarkBlue : Color.gray)
            }
            
            // Real waste collection indicators with recurring dates
            if isCurrentMonth {
                HStack(spacing: 1) {
                    ForEach(collectionsForDate, id: \.type) { collection in
                        Rectangle()
                            .fill(collection.color)
                            .frame(width: 8, height: 3)
                    }
                }
            }
        }
        .frame(height: 40)
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
