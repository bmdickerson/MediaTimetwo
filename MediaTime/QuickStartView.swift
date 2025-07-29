//
//  QuickStartView.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import SwiftUI

struct QuickStartView: View {
    let onStartSession: (ActivityType, String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    struct QuickActivity {
        let title: String
        let description: String
        let activityType: ActivityType
        let icon: String
        let color: Color
    }
    
    let quickActivities: [QuickActivity] = [
        QuickActivity(
            title: "Music",
            description: "Listening to music or podcasts",
            activityType: .consuming,
            icon: "music.note",
            color: .red
        ),
        QuickActivity(
            title: "Social Media",
            description: "Browsing social media platforms",
            activityType: .consuming,
            icon: "bubble.left.and.bubble.right",
            color: .red
        ),
        QuickActivity(
            title: "Games",
            description: "Reading news articles or blogs",
            activityType: .consuming,
            icon: "gamecontroller",
            color: .red
        ),
        QuickActivity(
            title: "Code",
            description: "Programming or software development",
            activityType: .creating,
            icon: "laptopcomputer",
            color: .green
        ),
        QuickActivity(
            title: "Write",
            description: "Writing articles, blogs, or creative content",
            activityType: .creating,
            icon: "square.and.pencil",
            color: .green
        ),
        QuickActivity(
            title: "Design",
            description: "Graphic design or creative work",
            activityType: .creating,
            icon: "paintbrush",
            color: .green
        ),
        QuickActivity(
            title: "Learn",
            description: "Educational content or courses",
            activityType: .consuming,
            icon: "book",
            color: .red
        ),
        QuickActivity(
            title: "Watch Youtube",
            description: "Watching television or streaming content",
            activityType: .consuming,
            icon: ActivityType.consuming.icon,
            color: .red
        )
        
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(quickActivities, id: \.title) { activity in
                        QuickActivityCard(activity: activity) {
                            onStartSession(activity.activityType, activity.description)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Quick Start")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuickActivityCard: View {
    let activity: QuickStartView.QuickActivity
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: activity.icon)
                    .font(.system(size: 30))
                    .foregroundColor(activity.color)
                
                VStack(spacing: 4) {
                    Text(activity.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(activity.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    QuickStartView { _, _ in }
} 
