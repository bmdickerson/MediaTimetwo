//
//  MediaTimeWidgetControl.swift
//  MediaTimeWidget
//
//  Created by Brice Dickerson on 7/29/25.
//

import WidgetKit
import SwiftUI
import ActivityKit

struct MediaTimeWidgetControl: Widget {
    let kind: String = "MediaTimeWidgetControl"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ControlProvider()) { entry in
            MediaTimeWidgetControlEntryView(entry: entry)
        }
        .configurationDisplayName("MediaTime Control")
        .description("Control your media sessions")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MediaTimeWidgetControlEntryView: View {
    let entry: ControlEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text("MediaTime")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("Control Sessions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ControlProvider: TimelineProvider {
    typealias Entry = ControlEntry
    
    func placeholder(in context: Context) -> ControlEntry {
        ControlEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ControlEntry) -> ()) {
        let entry = ControlEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ControlEntry>) -> ()) {
        var entries: [ControlEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = ControlEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ControlEntry: TimelineEntry {
    let date: Date
}

#Preview(as: .systemSmall) {
    MediaTimeWidgetControl()
} timeline: {
    ControlEntry(date: .now)
}
