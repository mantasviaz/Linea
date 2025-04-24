//
//  TaskViewModel.swift
//  Linea
//

import Foundation
import SwiftUI

@Observable
class TaskViewModel {
    var tasks: [Task] = [] {
        didSet { tasks.sort(by: { $0.end < $1.end }) }
    }
    
    let dayWidth: CGFloat = 200
    
    var visibleWindow: ClosedRange<Date> {
        let now = Date()
        return now.addingTimeInterval(-7 * 24 * 3600)...now.addingTimeInterval(7 * 24 * 3600)
    }
    
    func xPosition(for date: Date) -> CGFloat {
        let totalDays = visibleWindow.upperBound.timeIntervalSince(visibleWindow.lowerBound) / 86400
        let frac = date.timeIntervalSince(visibleWindow.lowerBound) / (totalDays * 86400)
        return CGFloat(frac) * totalDays * dayWidth
    }
    
    func update (_ task: Task) {
        guard let idx = tasks.firstIndex(of: task) else { return }
        tasks[idx] = task
    }
}



