//
//  SessionHistoryView.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [TimeSession]
    @State private var selectedFilter: ActivityType? = nil
    @State private var selectedDateRange: DateRange = .today
    
    enum DateRange: String, CaseIterable {
        case today = "Today"
        case yesterday = "Yesterday"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case allTime = "All Time"
        
        var dateInterval: DateInterval? {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                let startOfDay = calendar.startOfDay(for: now)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                return DateInterval(start: startOfDay, end: endOfDay)
            case .yesterday:
                let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
                let startOfDay = calendar.startOfDay(for: yesterday)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                return DateInterval(start: startOfDay, end: endOfDay)
            case .thisWeek:
                let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start
                return startOfWeek.map { DateInterval(start: $0, end: now) }
            case .thisMonth:
                let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start
                return startOfMonth.map { DateInterval(start: $0, end: now) }
            case .allTime:
                return nil
            }
        }
    }
    
    var filteredSessions: [TimeSession] {
        var filtered = sessions.filter { !$0.isActive }
        
        if let filter = selectedFilter {
            filtered = filtered.filter { $0.activityType == filter }
        }
        
        if let dateInterval = selectedDateRange.dateInterval {
            filtered = filtered.filter { session in
                session.startTime >= dateInterval.start && session.startTime < dateInterval.end
            }
        }
        
        return filtered.sorted { $0.startTime > $1.startTime }
    }
    
    var totalConsumingTime: TimeInterval {
        filteredSessions.filter { $0.activityType == .consuming }.reduce(0) { $0 + $1.duration }
    }
    
    var totalCreatingTime: TimeInterval {
        filteredSessions.filter { $0.activityType == .creating }.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Summary stats
                VStack(spacing: 12) {
                    Text("Summary")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("Consuming")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatTime(totalConsumingTime))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                        }
                        
                        VStack {
                            Text("Creating")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatTime(totalCreatingTime))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                        
                        VStack {
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatTime(totalConsumingTime + totalCreatingTime))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Filters
                VStack(alignment: .leading, spacing: 8) {
                    Text("Filters")
                        .font(.headline)
                    
                    HStack {
                        Picker("Date Range", selection: $selectedDateRange) {
                            ForEach(DateRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Spacer()
                        
                        Picker("Activity Type", selection: $selectedFilter) {
                            Text("All").tag(nil as ActivityType?)
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type as ActivityType?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Sessions list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sessions (\(filteredSessions.count))")
                        .font(.headline)
                    
                    if filteredSessions.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("No sessions found")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(filteredSessions) { session in
                                    DetailedSessionRow(session: session)
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.large)
        }
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

struct DetailedSessionRow: View {
    let session: TimeSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: session.activityType.icon)
                    .foregroundColor(Color(session.activityType.color))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.activityType.rawValue)
                        .font(.headline)
                    
                    if !session.explanation.isEmpty {
                        Text(session.explanation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTime(session.duration))
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(session.startTime, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text(session.startTime, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let endTime = session.endTime {
                    Text("Ended: \(endTime, style: .time)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
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
    SessionHistoryView()
        .modelContainer(for: TimeSession.self, inMemory: true)
} 
