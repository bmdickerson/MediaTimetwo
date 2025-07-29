//
//  ChartView.swift
//  MediaTime
//
//  Created by Brice Dickerson on 7/29/25.
//

import SwiftUI
import Charts

struct ChartView: View {
    let consumingTime: TimeInterval
    let creatingTime: TimeInterval
    
    var totalTime: TimeInterval {
        consumingTime + creatingTime
    }
    
    var consumingPercentage: Double {
        totalTime > 0 ? (consumingTime / totalTime) * 100 : 0
    }
    
    var creatingPercentage: Double {
        totalTime > 0 ? (creatingTime / totalTime) * 100 : 0
    }
    
    var body: some View {
        NavigationLink(destination: DetailedTimeView()) {
            VStack(spacing: 16) {
                HStack {
                    Text("Time Distribution")
                        .font(.headline)
                                            
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if totalTime > 0 {
                    HStack(spacing: 20) {
                        // Pie Chart on the left
                        Chart {
                            SectorMark(
                                angle: .value("Time", consumingTime),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(.red)
                            .opacity(0.8)
                            .cornerRadius(8)
                            
                            SectorMark(
                                angle: .value("Time", creatingTime),
                                innerRadius: .ratio(0.5),
                                angularInset: 2
                            )
                            .foregroundStyle(.green)
                            .opacity(0.8)
                            .cornerRadius(8)
                        }
                        .frame(width: 150, height: 150)
                        
                        // Stats on the right
                        VStack(spacing: 16) {
                            LegendItem(
                                color: .red,
                                icon: ActivityType.consuming.icon,
                                label: "Consuming",
                                percentage: consumingPercentage,
                                time: consumingTime
                            )
                            
                            LegendItem(
                                color: .green,
                                icon: ActivityType.creating.icon,
                                label: "Creating",
                                percentage: creatingPercentage,
                                time: creatingTime
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    HStack(spacing: 20) {
                        // Empty chart placeholder
                        VStack(spacing: 8) {
                            Image(systemName: "chart.pie")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                        }
                        .frame(width: 150, height: 150)
                        
                        // No data message
                        VStack(spacing: 8) {
                            Text("No data to display")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Tap to view detailed analysis")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LegendItem: View {
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

#Preview {
    ChartView(consumingTime: 3600, creatingTime: 1800)
} 
