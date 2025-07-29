import WidgetKit
import SwiftUI
import ActivityKit

struct MediaTimeLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MediaTimeAttributes.self) { context in
            // Live Activity UI
            LiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                CompactLeadingView(context: context)
            } compactTrailing: {
                CompactTrailingView(context: context)
            } minimal: {
                MinimalView(context: context)
            }
        }
    }
}

// MARK: - Live Activity Views

struct LiveActivityView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    @State private var dragOffset: CGFloat = 0
    @State private var showingSwitchHint = false
    
    private var isConsuming: Bool {
        context.state.activityType == "Consuming"
    }
    
    private var iconName: String {
        isConsuming ? "spoon.serving" : "camera.macro"
    }
    
    private var iconColor: Color {
        isConsuming ? .red : .green
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.title2)
                    Text(context.state.activityType)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                }
                
                if !context.state.sessionDescription.isEmpty {
                    Text(context.state.sessionDescription)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Text(context.state.runningTime)
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Image(systemName: "stop.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
                Text("Tap to stop")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .onTapGesture {
                // This will trigger the Live Activity interaction
                // The main app will handle stopping the session
            }
        }
        .padding()
        .offset(x: dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 80
                    if abs(value.translation.width) > threshold {
                        // Trigger activity type switch
                        // This will be handled by the main app through the LiveActivity interaction
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
        .overlay(
            // Switch hint overlay
            Group {
                if showingSwitchHint {
                    HStack {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundColor(.white)
                        Text("Switching...")
                            .foregroundColor(.white)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(isConsuming ? Color.green : Color.red)
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            , alignment: .top
        )
        .overlay(
            // Swipe hint
            HStack {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Swipe")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Color(.systemBackground).opacity(0.7))
            .cornerRadius(4)
            , alignment: .bottomTrailing
        )
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Dynamic Island Views

struct ExpandedLeadingView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    
    private var isConsuming: Bool {
        context.state.activityType == "Consuming"
    }
    
    private var iconName: String {
        isConsuming ? "desktopcomputer" : "pencil.and.outline"
    }
    
    private var iconColor: Color {
        isConsuming ? .red : .green
    }
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .font(.title3)
            Text(context.state.activityType)
                .font(.headline)
                .fontWeight(.semibold)
                .textCase(.uppercase)
        }
    }
}

struct ExpandedTrailingView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    
    var body: some View {
        Text(context.state.runningTime)
            .font(.title3)
            .fontWeight(.semibold)
            .monospacedDigit()
            .foregroundColor(.primary)
    }
}

struct ExpandedBottomView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    
    var body: some View {
        if !context.state.sessionDescription.isEmpty {
            Text(context.state.sessionDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
    }
}

struct CompactLeadingView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    
    private var isConsuming: Bool {
        context.state.activityType == "Consuming"
    }
    
    private var iconName: String {
        isConsuming ? "desktopcomputer" : "pencil.and.outline"
    }
    
    private var iconColor: Color {
        isConsuming ? .red : .green
    }
    
    var body: some View {
        Image(systemName: iconName)
            .foregroundColor(iconColor)
            .font(.title3)
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    
    var body: some View {
        Text(context.state.runningTime)
            .font(.caption2)
            .fontWeight(.medium)
            .monospacedDigit()
            .foregroundColor(.primary)
    }
}

struct MinimalView: View {
    let context: ActivityViewContext<MediaTimeAttributes>
    
    private var isConsuming: Bool {
        context.state.activityType == "Consuming"
    }
    
    private var iconName: String {
        isConsuming ? "desktopcomputer" : "pencil.and.outline"
    }
    
    private var iconColor: Color {
        isConsuming ? .red : .green
    }
    
    var body: some View {
        Image(systemName: iconName)
            .foregroundColor(iconColor)
            .font(.title3)
    }
} 
