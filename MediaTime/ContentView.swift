//
//  ContentView.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import SwiftUI
import SwiftData

// MARK: - Day Usage Bar Graph Component

struct DayUsageBarGraph: View {
    let todaySessions: [TimeSession]
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Today's Usage")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Legend and totals
            VStack {
                HStack(spacing: 15) {
                    StatCard(
                        title: "Consuming",
                        time: consumingTime,
                        color: .red,
                        icon: ActivityType.consuming.icon
                    )
                    
                    StatCard(
                        title: "Creating",
                        time: creatingTime,
                        color: .green,
                        icon: ActivityType.creating.icon
                    )
                }
                .padding(-2)
                
                // Balance row
                BalanceCard(
                    consumingTime: consumingTime,
                    creatingTime: creatingTime
                )
                .padding(-2)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private var consumingTime: TimeInterval {
        todaySessions.filter { $0.activityType == .consuming }.reduce(0) { $0 + $1.duration }
    }
    
    private var creatingTime: TimeInterval {
        todaySessions.filter { $0.activityType == .creating }.reduce(0) { $0 + $1.duration }
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var sessions: [TimeSession]
    @State private var showingNewSession = false
    @State private var showingQuickStart = false
    @State private var selectedActivityType: ActivityType = .consuming
    @State private var sessionDescription = ""
    
    var activeSessions: [TimeSession] {
        sessions.filter { $0.isActive }
    }
    
    var completedSessions: [TimeSession] {
        sessions.filter { !$0.isActive }
    }
    
    var todaySessions: [TimeSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return completedSessions.filter { calendar.isDate($0.startTime, inSameDayAs: today) }
    }
    
    var consumingTime: TimeInterval {
        todaySessions.filter { $0.activityType == .consuming }.reduce(0) { $0 + $1.duration }
    }
    
    var creatingTime: TimeInterval {
        todaySessions.filter { $0.activityType == .creating }.reduce(0) { $0 + $1.duration }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: -20) {
                // Scrollable content
                ScrollView {
                    VStack(spacing: 20) {
                        // Header with date and summary
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(formatDate())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Summary")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            NavigationLink(destination: SessionHistoryView()) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color(.systemBackground))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // Active sessions at the top
                        if !activeSessions.isEmpty {
                            ForEach(activeSessions) { session in
                                ActiveSessionCard(session: session) {
                                    stopSession(session)
                                }
                            }
                        }
                        
                        // Day usage bar graph (replaces "Today's Time")
                        DayUsageBarGraph(todaySessions: todaySessions)
                
                        // Chart view
                        ChartView(consumingTime: consumingTime, creatingTime: creatingTime)
                
                        // Start new session buttons
                        VStack(spacing: 12) {
                            Button(action: { showingQuickStart = true }) {
                                HStack {
                                    Image(systemName: "bolt.fill")
                                    Text("Quick Start")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(12)
                            }
                            
                            Button(action: { showingNewSession = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Custom Session")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                
                        // Recent sessions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Sessions")
                                .font(.headline)
                            
                            if completedSessions.isEmpty {
                                Text("No completed sessions yet")
                                    .foregroundColor(.secondary)
                                    .italic()
                            } else {
                                ForEach(completedSessions.prefix(5)) { session in
                                    SessionRow(session: session)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                    .padding()
                }
                .scrollIndicators(.hidden)
                .background(Color(.systemGroupedBackground))
            }
        }
        .sheet(isPresented: $showingNewSession) {
            NewSessionView(
                selectedActivityType: $selectedActivityType,
                sessionDescription: $sessionDescription,
                onStart: startNewSession
            )
        }
        .sheet(isPresented: $showingQuickStart) {
            QuickStartView { activityType, description in
                startQuickSession(activityType: activityType, description: description)
            }
        }
    }
    
    // MARK: - Session Management
    
    private func startNewSession() {
        let session = TimeSession(activityType: selectedActivityType, description: sessionDescription)
        modelContext.insert(session)
        selectedActivityType = .consuming
        sessionDescription = ""
        showingNewSession = false
        
        // Start Live Activity
        LiveActivityManager.shared.startLiveActivity(for: session)
    }
    
    private func startQuickSession(activityType: ActivityType, description: String) {
        let session = TimeSession(activityType: activityType, description: description)
        modelContext.insert(session)
        showingQuickStart = false
        
        // Start Live Activity
        LiveActivityManager.shared.startLiveActivity(for: session)
    }
    
    private func stopSession(_ session: TimeSession) {
        session.stop()
        
        // End Live Activity
        LiveActivityManager.shared.endLiveActivity(for: session)
    }
    
    // MARK: - Live Activities
    
    private func startLiveActivity(for session: TimeSession) {
        LiveActivityManager.shared.startLiveActivity(for: session)
    }
    
    private func endLiveActivity(for session: TimeSession) {
        LiveActivityManager.shared.endLiveActivity(for: session)
    }
    
    // MARK: - Live Activity Interaction Handling
    
    func handleLiveActivityInteraction() {
        // This would be called when user taps on the Live Activity
        print("Live Activity was tapped - user wants to stop session")
        
        // Find the active session and stop it
        if let activeSession = activeSessions.first {
            stopSession(activeSession)
        }
    }
    
    func handleLiveActivitySwipe() {
        // This would be called when user swipes on the Live Activity
        print("Live Activity was swiped - user wants to switch activity type")
        
        // Find the active session and switch its activity type
        if let activeSession = activeSessions.first {
            activeSession.switchActivityType()
            LiveActivityManager.shared.switchActivityType(for: activeSession)
        }
    }
    
    // Public method to handle LiveActivity interactions from the app
    static func handleLiveActivityInteraction() {
        // This is a static method that can be called from the app delegate
        // It will find the current ContentView instance and handle the interaction
        print("LiveActivity interaction received - stopping current session")
    }
    
    // Public method to handle LiveActivity swipe from the app
    static func handleLiveActivitySwipe() {
        // This is a static method that can be called from the app delegate
        // It will find the current ContentView instance and handle the swipe
        print("LiveActivity swipe received - switching activity type")
    }
    
    // MARK: - Helper Functions
    
    private func formatDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date()).uppercased()
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func formatRunningTime(_ startTime: Date) -> String {
        let duration = Date().timeIntervalSince(startTime)
        return formatDuration(duration)
    }
}

// MARK: - Active Session Card

struct ActiveSessionCard: View {
    let session: TimeSession
    let onStop: () -> Void
    @State private var currentTime = Date()
    @State private var dragOffset: CGFloat = 0
    @State private var showingSwitchHint = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Computed Properties
    
    private var switchHintOverlay: some View {
        Group {
            if showingSwitchHint {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundColor(.white)
                    Text("Switched to \(session.activityType.rawValue)")
                        .foregroundColor(.white)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(session.activityType == .consuming ? Color.red : Color.green)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private var swipeHintOverlay: some View {
        HStack {
            Image(systemName: "arrow.left.arrow.right")
                .font(.caption2)
                .foregroundColor(.secondary)
            Text("Swipe to switch")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(6)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Activity info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: session.activityType.icon)
                        .foregroundColor(session.activityType == .consuming ? .red : .green)
                    Text(session.activityType.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                if !session.explanation.isEmpty {
                    Text(session.explanation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text("Running for \(formatRunningTime())")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Large stop button
            Button(action: onStop) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop")
                }
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.red)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow, lineWidth: 3)
        )
        .shadow(color: Color(.systemGray4).opacity(0.3), radius: 4, x: 0, y: 2)
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.x
                }
                .onEnded { value in
                    let threshold: CGFloat = 100
                    if abs(value.translation.x) > threshold {
                        // Switch activity type
                        session.switchActivityType()
                        LiveActivityManager.shared.switchActivityType(for: session)
                        
                        // Show feedback
                        withAnimation(.spring()) {
                            showingSwitchHint = true
                        }
                        
                        // Hide feedback after delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.spring()) {
                                showingSwitchHint = false
                            }
                        }
                    }
                    
                    withAnimation(.spring()) {
                        dragOffset = 0
                    }
                }
        )
        .overlay(switchHintOverlay, alignment: .top)
        .overlay(swipeHintOverlay, alignment: .bottomTrailing)
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private func formatRunningTime() -> String {
        let duration = currentTime.timeIntervalSince(session.startTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %02ds", minutes, seconds)
        }
    }
}

struct StatCard: View {
    let title: String
    let time: TimeInterval
    let color: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(formatTime(time))
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
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

struct BalanceCard: View {
    let consumingTime: TimeInterval
    let creatingTime: TimeInterval
    
    private var totalTime: TimeInterval {
        consumingTime + creatingTime
    }
    
    private var balance: Double {
        guard totalTime > 0 else { return 0 }
        return ((creatingTime - consumingTime) / totalTime) * 100
    }
    
    private var balanceColor: Color {
        if balance > 10 {
            return .green
        } else if balance < -10 {
            return .red
        } else {
            return .orange
        }
    }
    
    private var balanceIcon: String {
        if balance > 10 {
            return "arrow.up.circle.fill"
        } else if balance < -10 {
            return "arrow.down.circle.fill"
        } else {
            return "equal.circle.fill"
        }
    }
    
    private var balanceText: String {
        if balance > 10 {
            return "Creating Focus"
        } else if balance < -10 {
            return "Consuming Focus"
        } else {
            return "Balanced"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: balanceIcon)
                .font(.title2)
                .foregroundColor(balanceColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Balance")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(balanceText)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(balanceColor)
            }
            
            Spacer()
            
            Text(String(format: "%.1f%%", abs(balance)))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(balanceColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct ActiveSessionRow: View {
    let session: TimeSession
    let onStop: () -> Void
    @State private var elapsedTime: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            Image(systemName: session.activityType.icon)
                .foregroundColor(Color(session.activityType.color))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.activityType.rawValue)
                    .font(.headline)
                
                if !session.explanation.isEmpty {
                    Text(session.explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(formatTime(session.duration))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct SessionRow: View {
    let session: TimeSession
    
    var body: some View {
        HStack {
            Image(systemName: session.activityType.icon)
                .foregroundColor(Color(session.activityType.color))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(session.activityType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !session.explanation.isEmpty {
                    Text(session.explanation)
                        .font(.caption)
                        .foregroundColor(.secondary)
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

struct NewSessionView: View {
    @Binding var selectedActivityType: ActivityType
    @Binding var sessionDescription: String
    let onStart: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Start New Session")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Type")
                        .font(.headline)
                    
                    HStack(spacing: 0) {
                        ForEach(ActivityType.allCases, id: \.self) { type in
                            Button(action: {
                                selectedActivityType = type
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: type.icon)
                                        .font(.caption)
                                    Text(type.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(selectedActivityType == type ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedActivityType == type ? 
                                              (type == .consuming ? Color.red : Color.green) : 
                                              Color(.systemGray5))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description (Optional)")
                        .font(.headline)
                    
                    TextField("What are you working on?", text: $sessionDescription)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        onStart()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TimeSession.self, inMemory: true)
}
