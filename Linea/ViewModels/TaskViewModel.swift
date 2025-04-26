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
    var colors: [String: Color] = ["Blue": Color(red: 0.8, green: 0.89, blue: 1), "Red": Color(red: 1, green: 0.76, blue: 0.76), "Orange": Color(red: 1, green: 0.87, blue: 0.65), "Green": Color(red: 0.84, green: 0.95, blue: 0.77), "Purple": Color(red: 0.89, green: 0.84, blue: 0.95)]
    
    //TODO: Delete later
    init() {
        self.groups = [
            "Blue": colors["Blue"]!, "Red": colors["Red"]!, "Orange": colors["Orange"]!, "Green": colors["Green"]!, "Purple": colors["Purple"]!
        ]
    }
    
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
    
    func addGroup(name: String, color: Color) {
        groups[name] = color
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
                group: "Blue",
                title: "Blue",
                start: formatter.date(from: "2025-04-24 00:00")!,
                end: formatter.date(from: "2025-04-25 00:00")!
            ),
            Task(
                id: UUID(),
                group: "Green",
                title: "Green",
                start: formatter.date(from: "2025-04-23 12:00")!,
                end: formatter.date(from: "2025-04-24 12:00")!
            ),
            Task(
                id: UUID(),
                group: "Red",
                title: "Red",
                start: formatter.date(from: "2025-04-22 10:00")!,
                end: formatter.date(from: "2025-04-26 14:00")!
            ),
            Task(
                id: UUID(),
                group: "Purple",
                title: "Purple",
                start: formatter.date(from: "2025-04-22 15:00")!,
                end: formatter.date(from: "2025-04-24 19:41")!
            ),
            Task(
                id: UUID(),
                group: "Orange",
                title: "Orange",
                start: formatter.date(from: "2025-04-24 00:00")!,
                end: formatter.date(from: "2025-04-25 00:00")!
            ),
            Task(
                id: UUID(),
                group: "Orange",
                title: "Test New Builds",
                start: formatter.date(from: "2025-04-21 10:00")!,
                end: formatter.date(from: "2025-04-27 14:00")!
            ),
            Task(
                id: UUID(),
                group: "Blue",
                title: "CIS 3200 - HW 4",
                start: formatter.date(from: "2025-04-21 15:00")!,
                end: formatter.date(from: "2025-04-23 16:30")!
            )
        ]
    }()
}




