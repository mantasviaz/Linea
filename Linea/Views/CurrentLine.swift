//
//  CurrentLine.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI
import Foundation

struct CurrentLine: View {
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) private var taskViewModel
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            Canvas { context, size in
                let x = taskViewModel.xPosition(for: timeline.date, dayWidth: dayWidth)

                // vertical line
                var p = Path(); p.move(to: CGPoint(x: x, y: 0)); p.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(p, with: .color(.blue), lineWidth: 2)

                let r: CGFloat = 6
                let circleRect = CGRect(x: x - r, y: -r, width: r * 2, height: r * 2)
                context.fill(Path(ellipseIn: circleRect), with: .color(.blue))
            }
        }
    }
}
