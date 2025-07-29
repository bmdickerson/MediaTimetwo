import Foundation
import SwiftUI
import ActivityKit
import SwiftData

class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<MediaTimeAttributes>?
    private var updateTimer: Timer?
    private var currentSessionId: String?
    
    private init() {
        // Clean up any existing activities on app launch
        cleanupExistingActivities()
    }
    
    func startLiveActivity(for session: TimeSession) {
        print("🚀 Attempting to start LiveActivity for session: \(session.activityType.rawValue)")
        
        // Check if Live Activities are supported on this device
        if #unavailable(iOS 16.1) {
            print("❌ Live Activities require iOS 16.1 or later")
            return
        }
        
        // Check authorization
        let authInfo = ActivityAuthorizationInfo()
        print("📱 Live Activities enabled: \(authInfo.areActivitiesEnabled)")
        print("📱 Frequent updates enabled: \(authInfo.areActivitiesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("❌ Live Activities are not enabled in system settings")
            print("💡 Go to Settings > Face ID & Passcode > Allow Access When Locked > Live Activities")
            return
        }
        
        // Generate a unique session ID using the start time and activity type
        let sessionId = "\(session.activityType.rawValue)-\(session.startTime.timeIntervalSince1970)"
        print("🆔 Session ID: \(sessionId)")
        
        // End any existing activity first
        endLiveActivity(for: session)
        
        let attributes = MediaTimeAttributes(
            activityType: session.activityType.rawValue,
            sessionId: sessionId
        )
        
        let contentState = MediaTimeAttributes.ContentState(
            activityType: session.activityType.rawValue,
            runningTime: "0m 0s",
            startTime: session.startTime,
            sessionDescription: session.explanation
        )
        
        print("📝 Attributes: \(attributes)")
        print("📝 Content State: \(contentState)")
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: contentState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            currentSessionId = sessionId
            print("✅ Live Activity started successfully!")
            print("🆔 Activity ID: \(activity.id)")
            print("📊 Activity state: \(activity.activityState)")
            
            // Start timer to update the Live Activity
            startUpdateTimer(for: session)
        } catch {
            print("❌ Failed to start Live Activity: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            print("🔍 Error type: \(type(of: error))")
        }
    }
    
    func endLiveActivity(for session: TimeSession) {
        print("Ending LiveActivity for session: \(session.activityType.rawValue)")
        
        // Stop the update timer
        updateTimer?.invalidate()
        updateTimer = nil
        
        guard let activity = currentActivity else { 
            print("No current activity to end")
            return 
        }
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            currentActivity = nil
            currentSessionId = nil
            print("✅ Live Activity ended successfully for session: \(session.activityType.rawValue)")
        }
    }
    
    func updateLiveActivity(for session: TimeSession) {
        guard let activity = currentActivity else { return }
        
        let runningTime = formatRunningTime(session.startTime)
        let contentState = MediaTimeAttributes.ContentState(
            activityType: session.activityType.rawValue,
            runningTime: runningTime,
            startTime: session.startTime,
            sessionDescription: session.explanation
        )
        
        Task {
            await activity.update(ActivityContent(state: contentState, staleDate: nil))
        }
    }
    
    func switchActivityType(for session: TimeSession) {
        session.switchActivityType()
        updateLiveActivity(for: session)
    }
    
    private func startUpdateTimer(for session: TimeSession) {
        // Invalidate any existing timer
        updateTimer?.invalidate()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateLiveActivity(for: session)
        }
        print("🕐 Update timer started for LiveActivity")
    }
    
    private func formatRunningTime(_ startTime: Date) -> String {
        let duration = Date().timeIntervalSince(startTime)
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %02ds", minutes, seconds)
        }
    }
    
    private func cleanupExistingActivities() {
        Task {
            let activities = Activity<MediaTimeAttributes>.activities
            print("🧹 Cleaning up \(activities.count) existing activities")
            for activity in activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
    
    private func cleanupInvalidActivity() async {
        print("🧹 Cleaning up invalid activity")
        currentActivity = nil
        currentSessionId = nil
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    deinit {
        updateTimer?.invalidate()
    }
} 
