//
//  DetailedTimeView.swift
//  MediaTime
//
//  Created by joe 
//

import SwiftUI
import SwiftData
import Charts

enum TimePeriod: String, CaseIterable {
    case day = "Day"
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var icon: String {
        switch self {
        case .day: return "calendar"
        case .week: return "calendar.badge.clock"
        case .month: return "calendar.badge.plus"
        case .year: return "calendar.badge.exclamationmark"
        }
    }
}

struct DetailedTimeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [TimeSession]
    @State private var selectedPeriod: TimePeriod = .day
    @State private var selectedDate = Date()
    @State private var showingCalendar = true
    
    private var completedSessions: [TimeSession] {
        sessions.filter { !$0.isActive }
    }
    
    private var sessionsForSelectedPeriod: [TimeSession] {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .day:
            return completedSessions.filter { calendar.isDate($0.startTime, inSameDayAs: selectedDate) }
        case .week:
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)!
            return completedSessions.filter { weekInterval.contains($0.startTime) }
        case .month:
            let monthInterval = calendar.dateInterval(of: .month, for: selectedDate)!
            return completedSessions.filter { monthInterval.contains($0.startTime) }
        case .year:
            let yearInterval = calendar.dateInterval(of: .year, for: selectedDate)!
            return completedSessions.filter { yearInterval.contains($0.startTime) }
        }
    }
    
    private var consumingTimeForPeriod: TimeInterval {
        sessionsForSelectedPeriod.filter { $0.activityType == .consuming }.reduce(0) { $0 + $1.duration }
    }
    
    private var creatingTimeForPeriod: TimeInterval {
        sessionsForSelectedPeriod.filter { $0.activityType == .creating }.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Custom Header
                    HStack {
                        Text("Time Analysis")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Period Selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Time Period")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 0) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedPeriod = period
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: period.icon)
                                            .font(.caption)
                                        Text(period.rawValue)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundColor(selectedPeriod == period ? .white : .primary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedPeriod == period ? Color.blue : Color(.systemGray5))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    
                    // Date Selection
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(formatSelectedPeriod())
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Button(action: { showingCalendar.toggle() }) {
                                Image(systemName: showingCalendar ? "calendar.badge.minus" : "calendar.badge.plus")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Button(action: previousPeriod) {
                                Image(systemName: "chevron.left")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                            
                            Spacer()
                            
                            Button(action: nextPeriod) {
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Calendar View
                    if showingCalendar {
                        CalendarGridView(
                            sessions: completedSessions,
                            selectedDate: $selectedDate,
                            selectedPeriod: selectedPeriod
                        )
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Pie Chart for Selected Period
                    DetailedChartView(
                        consumingTime: consumingTimeForPeriod,
                        creatingTime: creatingTimeForPeriod,
                        period: selectedPeriod
                    )
                    .padding(.horizontal)
                    
                    // Session List for Selected Period
                    if !sessionsForSelectedPeriod.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sessions")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(sessionsForSelectedPeriod.sorted(by: { $0.startTime > $1.startTime })) { session in
                                    AnalysisSessionRow(session: session)
                                }
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            
        }
    }
    
    private func previousPeriod() {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            selectedDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: -1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func nextPeriod() {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            selectedDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: 1, to: selectedDate) ?? selectedDate
        }
    }
    
    private func formatSelectedPeriod() -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .day:
            formatter.dateFormat = "EEEE, MMM d, yyyy"
            return formatter.string(from: selectedDate)
        case .week:
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedDate)!
            formatter.dateFormat = "MMM d"
            let startString = formatter.string(from: weekInterval.start)
            let endString = formatter.string(from: weekInterval.end)
            return "Week: \(startString) - \(endString)"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: selectedDate)
        case .year:
            formatter.dateFormat = "yyyy"
            return formatter.string(from: selectedDate)
        }
    }
}

struct DetailedChartView: View {
    let consumingTime: TimeInterval
    let creatingTime: TimeInterval
    let period: TimePeriod
    
    private var totalTime: TimeInterval {
        consumingTime + creatingTime
    }
    
    private var consumingPercentage: Double {
        totalTime > 0 ? (consumingTime / totalTime) * 100 : 0
    }
    
    private var creatingPercentage: Double {
        totalTime > 0 ? (creatingTime / totalTime) * 100 : 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Time Distribution - \(period.rawValue)")
                .font(.headline)
            
            if totalTime > 0 {
                Chart {
                    SectorMark(
                        angle: .value("Time", consumingTime),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.red)
                    .opacity(0.8)
                    
                    SectorMark(
                        angle: .value("Time", creatingTime),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(.green)
                    .opacity(0.8)
                }
                .frame(height: 200)
                
                HStack(spacing: 20) {
                    DetailedLegendItem(
                        color: .red,
                        icon: ActivityType.consuming.icon,
                        label: "Consuming",
                        percentage: consumingPercentage,
                        time: consumingTime
                    )
                    
                    DetailedLegendItem(
                        color: .green,
                        icon: ActivityType.creating.icon,
                        label: "Creating",
                        percentage: creatingPercentage,
                        time: creatingTime
                    )
                }
                
                // Summary
                HStack {
                    VStack {
                        Text("Total Time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formatTime(totalTime))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: creatingTime >= consumingTime ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(creatingTime >= consumingTime ? .green : .red)
                            Text(creatingTime >= consumingTime ? "Creating" : "Consuming")
                                .fontWeight(.semibold)
                                .foregroundColor(creatingTime >= consumingTime ? .green : .red)
                        }
                    }
                }
                .padding(.top)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text("No data for this \(period.rawValue.lowercased())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct DetailedLegendItem: View {
    let color: Color
    let icon: String
    let label: String
    let percentage: Double
    let time: TimeInterval
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatTime(time))
                .font(.caption)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct AnalysisSessionRow: View {
    let session: TimeSession
    
    var body: some View {
        HStack {
            Image(systemName: session.activityType.icon)
                .foregroundColor(session.activityType == .consuming ? .red : .green)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.activityType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !session.explanation.isEmpty {
                    Text(session.explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(session.startTime, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatTime(session.duration))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    DetailedTimeView()
        .modelContainer(for: TimeSession.self, inMemory: true)
} 
