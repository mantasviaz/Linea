//
//  TimelineGrid.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//
import SwiftUI
import Foundation

struct TimelineGridView: View {
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) var taskViewModel
    var body: some View {
        Canvas { context, size in
            let dayCount = Calendar.current.dateComponents([.day],
                                                           from: taskViewModel.visibleWindow.lowerBound,
                                                           to: taskViewModel.visibleWindow.upperBound).day!
            for d in 0...dayCount {
                let x = CGFloat(d) * dayWidth
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.gray.opacity(0.5)))
            }
        }
    }
}
