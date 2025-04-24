//
//  TaskViewModel.swift
//  Linea
//

import Foundation
import SwiftUI

@Observable
class TaskViewModel {
    var tasks: [Task]

    init() {
        self.tasks = Task.samples
        self.tasks.sort(by: { $0.end < $1.end })
    }


    var visibleWindow: ClosedRange<Date> {
        let now = Date()
        return now.addingTimeInterval(-7 * 24 * 3600)...now.addingTimeInterval(7 * 24 * 3600)
    }
    
    func xPosition(for date: Date, dayWidth: CGFloat) -> CGFloat {
        let totalDays = visibleWindow.upperBound.timeIntervalSince(visibleWindow.lowerBound) / 86400
        let frac = date.timeIntervalSince(visibleWindow.lowerBound) / (totalDays * 86400)
        return CGFloat(frac) * totalDays * dayWidth
    }
    
    func update (_ task: Task) {
        guard let idx = tasks.firstIndex(of: task) else { return }
        tasks[idx] = task
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
                group: "Design",
                title: "Create Wireframes",
                start: formatter.date(from: "2025-04-21 09:00")!,
                end: formatter.date(from: "2025-04-23 12:00")!
            ),
            Task(
                id: UUID(),
                group: "Development",
                title: "Implement Feature A",
                start: formatter.date(from: "2025-04-23 13:00")!,
                end: formatter.date(from: "2025-04-25 17:00")!
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
                end: formatter.date(from: "2025-04-23 16:30")!
            ),
            Task(
                id: UUID(),
                group: "Team",
                title: "Retrospective",
                start: formatter.date(from: "2025-04-25 11:00")!,
                end: formatter.date(from: "2025-04-25 12:00")!
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




