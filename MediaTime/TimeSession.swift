//
//  TimeSession.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import Foundation
import SwiftData

enum ActivityType: String, CaseIterable, Codable {
    case consuming = "Consuming"
    case creating = "Creating"
    
    var icon: String {
        switch self {
        case .consuming:
            return "spoon.serving"
        case .creating:
            return "camera.macro"
        }
    }
    
    var color: String {
        switch self {
        case .consuming:
            return "red"
        case .creating:
            return "green"
        }
    }
}

@Model
final class TimeSession {
    var startTime: Date
    var endTime: Date?
    var activityType: ActivityType
    var explanation: String
    var isActive: Bool
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    init(startTime: Date = Date(), activityType: ActivityType, description: String = "", isActive: Bool = true) {
        self.startTime = startTime
        self.activityType = activityType
        self.explanation = description
        self.isActive = isActive
    }
    
    func stop() {
        self.endTime = Date()
        self.isActive = false
    }
    
    func switchActivityType() {
        self.activityType = self.activityType == .consuming ? .creating : .consuming
    }
}
