//
//  TaskViewModel.swift
//  Linea
//

import Foundation
import SwiftUI
import SwiftData
import Observation
import UIKit

@MainActor
@Observable
class TaskViewModel {
    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }
    var importedImage: UIImage? = nil
    
    var draftTasks: [LineaTaskDraft] = []
    var tasks: [LineaTask] = []
    var groups: [String: Color] = [:]
    var colors: [String: Color] = [
        "Blue": Color(red: 0.8, green: 0.89, blue: 1),
        "Red": Color(red: 1, green: 0.76, blue: 0.76),
        "Orange": Color(red: 1, green: 0.87, blue: 0.65),
        "Green": Color(red: 0.84, green: 0.95, blue: 0.77),
        "Purple": Color(red: 0.89, green: 0.84, blue: 0.95)
    ]
    
    init() {
        do {
            container = try ModelContainer(for: LineaTask.self, GroupColor.self)
        } catch {
            fatalError("Failed to create SwiftData container: \(error)")
        }

        let taskDescriptor = FetchDescriptor<LineaTask>(
            sortBy: [SortDescriptor(\.end, order: .forward)]
        )
        tasks = (try? context.fetch(taskDescriptor)) ?? []

        var loadedGroups: [String: Color] = [:]
        let groupDescriptor = FetchDescriptor<GroupColor>()
        let storedColours = (try? context.fetch(groupDescriptor)) ?? []
        for g in storedColours {
            loadedGroups[g.name] = g.swiftUIColor
        }
        self.groups = loadedGroups

        if groups.isEmpty {
            self.groups = [ : ]
            for (name, colour) in groups {
                context.insert(GroupColor(name: name, color: colour))
            }
            try? context.save()
        }
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
    
    func deleteAllEvents() {
        for task in tasks {
            delete(task)
        }
        let groupNames = Array(groups.keys)
        for name in groupNames {
            deleteGroup(name: name)
        }
    }

    func deleteGoogleTasks() {
        let googleTasks = tasks.filter { $0.isFromGoogle }
        for task in googleTasks {
            delete(task)
        }
    }
    
    func xPosition(for date: Date, dayWidth: CGFloat) -> CGFloat {
        let cal = Calendar.current
        let wholeDays = cal.dateComponents([.day], from: windowOrigin, to: date).day!
        let midnightThatDay = cal.date(byAdding: .day, value: wholeDays, to: windowOrigin)!
        let secondsIntoDay = date.timeIntervalSince(midnightThatDay)
        let fraction = secondsIntoDay / (24 * 3600)
        return (CGFloat(wholeDays) + CGFloat(fraction)) * dayWidth
    }
    
    func update(_ task: LineaTask) {
        if let idx = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[idx] = task
        } else {
            tasks.append(task)
        }
        tasks.sort { $0.end < $1.end }
        context.insert(task)
        try? context.save()
    }

    func delete(_ task: LineaTask) {
        tasks.removeAll { $0.id == task.id }
        context.delete(task)
        try? context.save()
    }

    func renameGroup(oldName: String, newName: String) {
        guard oldName != newName, !newName.isEmpty,
              let colour = groups.removeValue(forKey: oldName) else { return }
        
        groups[newName] = colour
        context.insert(GroupColor(name: newName, color: colour))
        try? context.save()
    }

    func updateGroupColor(name: String, color: Color) {
        groups[name] = color
        context.insert(GroupColor(name: name, color: color))
        try? context.save()
    }

    func deleteGroup(name: String) {
        groups.removeValue(forKey: name)
        for model in (try? context.fetch(FetchDescriptor<GroupColor>())) ?? [] where model.name == name {
            context.delete(model)
        }
        try? context.save()
    }
    
    func addGroup(name: String, color: Color) {
        var proposed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if proposed.isEmpty { proposed = "Group" }

        if groups.keys.contains(proposed) {
            var idx = 1
            while groups.keys.contains("\(proposed) \(idx)") { idx += 1 }
            proposed = "\(proposed) \(idx)"
        }

        groups[proposed] = color
        context.insert(GroupColor(name: proposed, color: color))
        try? context.save()
    }
    
    func fetchAllTasks() -> [LineaTask] {
        let descriptor = FetchDescriptor<LineaTask>(
            sortBy: [SortDescriptor(\.end, order: .forward)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    func commitDraftTasks() {
        for draft in draftTasks {
            let task = LineaTask(
                id: UUID(),
                group: draft.group,
                title: draft.title,
                start: draft.start,
                end: draft.end,
                completed: false
            )
            update(task)
        }
        draftTasks.removeAll()
    }
}


