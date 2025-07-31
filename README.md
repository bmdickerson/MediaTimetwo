# MediaTime - Time Tracking App

A SwiftUI app that helps you track and balance your time between consuming media and creating content.

## Features

###  Core Functionality
- **Time Tracking**: Track time spent consuming media vs. creating content
- **Real-time Monitoring**: See active sessions with live timers
- **Visual Analytics**: Pie chart showing time distribution
- **Session History**: Detailed view of all completed sessions with filtering options

###  Dashboard
- **Today's Summary**: Quick overview of consuming vs. creating time
- **Active Sessions**: View and stop currently running sessions
- **Visual Chart**: Pie chart showing time distribution
- **Recent Sessions**: Quick access to recent activity

###  Quick Start
- **Predefined Activities**: Quick start buttons for common activities like:
  - Watching TV
  - Social Media
  - Reading News
  - Writing Code
  - Writing Content
  - Design Work
  - Learning
  - Music/Podcasts

###  Session History
- **Filtering Options**: Filter by activity type and date range
- **Detailed View**: See start/end times, duration, and descriptions
- **Summary Statistics**: Total time breakdown for filtered periods

###  User Interface
- **Modern Design**: Clean, intuitive SwiftUI interface
- **Color Coding**: Red for consuming, green for creating
- **SF Symbols**: Consistent iconography throughout
- **Responsive Layout**: Works on iPhone and iPad

## Technical Details

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **SwiftData**: Persistent data storage
- **Charts Framework**: Data visualization
- **MVVM Pattern**: Clean separation of concerns

### Data Model
```swift
@Model
final class TimeSession {
    var startTime: Date
    var endTime: Date?
    var activityType: ActivityType
    var explanation: String
    var isActive: Bool
    var duration: TimeInterval
}
```

### Activity Types
- **Consuming**: Media consumption activities (TV, social media, reading, etc.)
- **Creating**: Content creation activities (coding, writing, design, etc.)

## Getting Started

1. **Open the Project**: Open `MediaTime.xcodeproj` in Xcode
2. **Build and Run**: Select a simulator or device and run the app
3. **Start Tracking**: Use Quick Start or Custom Session to begin tracking time
4. **Monitor Progress**: View your daily stats and time distribution
5. **Review History**: Access detailed session history and analytics

## Usage

### Starting a Session
1. Tap "Quick Start" for predefined activities
2. Or tap "Custom Session" to create a personalized session
3. Select activity type (Consuming or Creating)
4. Add optional description
5. Tap "Start" to begin tracking

### Managing Active Sessions
- View running sessions in the "Active Sessions" section
- See real-time elapsed time
- Tap the stop button to end a session

### Viewing Analytics
- **Dashboard**: See today's summary and time distribution chart
- **History**: Access detailed session history with filtering options
- **Statistics**: View total time breakdowns for different periods

## Requirements

- iOS 18.5+
- Xcode 16.0+
- Swift 5.0+

## Installation

1. Clone or download the project
2. Open `MediaTime.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run the project

## Future Enhancements

- **Notifications**: Reminders to stop sessions
- **Goals**: Set daily/weekly time balance goals
- **Export**: Export data to CSV or other formats
- **Widgets**: Home screen widgets for quick access
- **iCloud Sync**: Sync data across devices
- **Categories**: More detailed activity categorization

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve the app.

## License

This project is open source and available under the MIT License. 
