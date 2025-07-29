//
//  SharedMediaTimeAttributes.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import Foundation
import ActivityKit

// MARK: - Live Activity Attributes (Shared)
struct MediaTimeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var activityType: String
        var runningTime: String
        var startTime: Date
        var sessionDescription: String
    }
    
    var activityType: String
    var sessionId: String
} 