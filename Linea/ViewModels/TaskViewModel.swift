//
//  TaskViewModel.swift
//  Linea
//

import Foundation
import SwiftUI

@Observable
class TaskViewModel {
    var tasks: [Task] = Task.samples.sorted { $0.end < $1.end }
    var groups: [String: Color] = [:]
    
    var windowOrigin: Date {
        let nowMidnight = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .year, value: -1, to: nowMidnight)!
    }

    var visibleWindow: ClosedRange<Date> {
        let start = windowOrigin
        let end = Calendar.current.date(byAdding: .year, value: 2, to: windowOrigin)
        return start...end!
    }
    
    func xPosition(for date: Date, dayWidth: CGFloat) -> CGFloat {
        let cal          = Calendar.current
        let wholeDays    = cal.dateComponents([.day], from: windowOrigin, to: date).day!
        let midnightThatDay = cal.date(byAdding: .day, value: wholeDays, to: windowOrigin)!
        let secondsIntoDay  = date.timeIntervalSince(midnightThatDay)
        let fraction        = secondsIntoDay / (24 * 3_600)
        return (CGFloat(wholeDays) + CGFloat(fraction)) * dayWidth
    }
    
    func update(_ task: Task) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task           // existing task edited
        } else {
            tasks.append(task)          // new task added
        }
        tasks.sort { $0.end < $1.end }
    }
}

extension Task {
    static let samples: [Task] = {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        return [
            Task(
                id: UUID(),
                group: "Testing",
                title: "Midnight",
                start: formatter.date(from: "2025-04-24 00:00")!,
                end: formatter.date(from: "2025-04-25 00:00")!
            ),
            Task(
                id: UUID(),
                group: "Development",
                title: "Noon",
                start: formatter.date(from: "2025-04-23 12:00")!,
                end: formatter.date(from: "2025-04-24 12:00")!
            ),
            Task(
                id: UUID(),
                group: "QA",
                title: "Test New Builds",
                start: formatter.date(from: "2025-04-22 10:00")!,
                end: formatter.date(from: "2025-04-26 14:00")!
            ),
            Task(
                id: UUID(),
                group: "PM",
                title: "Sprint Review",
                start: formatter.date(from: "2025-04-22 15:00")!,
                end: formatter.date(from: "2025-04-24 19:41")!
            ),
            Task(
                id: UUID(),
                group: "Team",
                title: "Test",
                start: formatter.date(from: "2025-04-24 00:00")!,
                end: formatter.date(from: "2025-04-25 00:00")!
            ),
            Task(
                id: UUID(),
                group: "QA",
                title: "Test New Builds",
                start: formatter.date(from: "2025-04-21 10:00")!,
                end: formatter.date(from: "2025-04-27 14:00")!
            ),
            Task(
                id: UUID(),
                group: "PM",
                title: "Sprint Review",
                start: formatter.date(from: "2025-04-21 15:00")!,
                end: formatter.date(from: "2025-04-23 16:30")!
            ),
            Task(
                id: UUID(),
                group: "Team",
                title: "Retrospective",
                start: formatter.date(from: "2025-04-22 11:00")!,
                end: formatter.date(from: "2025-04-25 12:00")!
            ),
            Task(
                id: UUID(),
                group: "QA",
                title: "Test New Builds",
                start: formatter.date(from: "2025-04-25 10:00")!,
                end: formatter.date(from: "2025-04-27 14:00")!
            ),
            Task(
                id: UUID(),
                group: "PM",
                title: "Sprint Review",
                start: formatter.date(from: "2025-04-21 15:00")!,
                end: formatter.date(from: "2025-04-27 16:30")!
            ),
            Task(
                id: UUID(),
                group: "Team",
                title: "Retrospective",
                start: formatter.date(from: "2025-04-21 11:00")!,
                end: formatter.date(from: "2025-04-25 12:00")!
            )
        ]
    }()
}




