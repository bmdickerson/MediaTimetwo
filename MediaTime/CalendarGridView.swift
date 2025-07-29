//
//  CalendarGridView.swift
//  MediaTime
//
//  Created by joey

import SwiftUI
import Foundation

struct CalendarGridView: View {
    let sessions: [TimeSession]
    @Binding var selectedDate: Date
    let selectedPeriod: TimePeriod
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    // Get the month to display based on the selected period
    private var displayMonth: Date {
        switch selectedPeriod {
        case .day, .week:
            return selectedDate
        case .month:
            return selectedDate
        case .year:
            return selectedDate
        }
    }
    
    // Get all days for the current month view
    private var daysInMonth: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayMonth) else { return [] }
        
        var days: [Date] = []
        let startOfMonth = monthInterval.start
        let endOfMonth = monthInterval.end
        
        // Get the first day of the week that contains the start of the month
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        // Get days from the start of the week to fill the calendar grid
        var currentDate = startOfWeek
        let endOfLastWeek = calendar.date(byAdding: .day, value: 41, to: startOfWeek) ?? endOfMonth
        
        while currentDate <= endOfLastWeek && days.count < 42 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    // Get time data for a specific day
    private func getTimeData(for date: Date) -> (consuming: TimeInterval, creating: TimeInterval) {
        let daySessions = sessions.filter { calendar.isDate($0.startTime, inSameDayAs: date) }
        let consuming = daySessions.filter { $0.activityType == .consuming }.reduce(0) { $0 + $1.duration }
        let creating = daySessions.filter { $0.activityType == .creating }.reduce(0) { $0 + $1.duration }
        return (consuming, creating)
    }
    
    // Get the background color for a day based on activity balance
    private func getDayColor(for date: Date) -> Color {
        let timeData = getTimeData(for: date)
        let totalTime = timeData.consuming + timeData.creating
        
        // No data = gray
        if totalTime == 0 {
            return Color.clear
        }
        
        // More creating = green, more consuming = red
        if timeData.creating >= timeData.consuming {
            let intensity = min(1.0, totalTime / (4 * 3600)) // Max intensity at 4 hours
            return Color.green.opacity(0.3 + intensity * 0.4)
        } else {
            let intensity = min(1.0, totalTime / (4 * 3600)) // Max intensity at 4 hours
            return Color.red.opacity(0.3 + intensity * 0.4)
        }
    }
    
    // Check if day is in current month
    private func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: displayMonth, toGranularity: .month)
    }
    
    // Check if date is selected
    private func isSelected(_ date: Date) -> Bool {
        switch selectedPeriod {
        case .day:
            return calendar.isDate(date, inSameDayAs: selectedDate)
        case .week:
            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else { return false }
            return weekInterval.contains(date)
        case .month:
            return calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
        case .year:
            return calendar.isDate(date, equalTo: selectedDate, toGranularity: .year)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Month header
            HStack {
                Text(formatMonthYear(displayMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            // Day of week headers
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { weekday in
                    Text(weekday.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isInCurrentMonth: isInCurrentMonth(date),
                        isSelected: isSelected(date),
                        backgroundColor: getDayColor(for: date),
                        timeData: getTimeData(for: date),
                        onTap: {
                            selectedDate = date
                        }
                    )
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                HStack {
                    Circle()
                        .fill(Color.green.opacity(0.6))
                        .frame(width: 12, height: 12)
                    Text("More Creating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Circle()
                        .fill(Color.red.opacity(0.6))
                        .frame(width: 12, height: 12)
                    Text("More Consuming")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                    Text("No Data")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
    }
    
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarDayView: View {
    let date: Date
    let isInCurrentMonth: Bool
    let isSelected: Bool
    let backgroundColor: Color
    let timeData: (consuming: TimeInterval, creating: TimeInterval)
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isInCurrentMonth ? .primary : .secondary)
                
                // Small indicator for time if there's data
                if timeData.consuming + timeData.creating > 0 {
                    HStack(spacing: 1) {
                        if timeData.consuming > 0 {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 3, height: 3)
                        }
                        if timeData.creating > 0 {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }
            .frame(width: 40, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isInCurrentMonth ? 1.0 : 0.6)
    }
}

#Preview {
    CalendarGridView(
        sessions: [],
        selectedDate: .constant(Date()),
        selectedPeriod: .day
    )
    .padding()
} 
