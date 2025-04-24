//
//  TaskBar.swift
//  Linea
//
//  
//

import SwiftUI
import Observation

struct TaskBar: View {
    @Binding var task: Task
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var isDraggingStart = false

    var body: some View {
        let startX = taskViewModel.xPosition(for: task.start)
        let width = taskViewModel.xPosition(for: task.end) - startX
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.accentColor.opacity(0.3))
            Text(task.title)
                .lineLimit(1)
                .padding(.horizontal, 6)
                
        }
        .frame(width: width, height: 40)
        .position(x: startX + width / 2, y: 20)
        .gesture (
            DragGesture(minimumDistance: 0)
                .onChanged { g in
                    let localX = g.location.x - startX
                    isDraggingStart = (localX < 20)
                    let deltaDays = g.translation.width / taskViewModel.dayWidth
                    let deltaSec = deltaDays * 24 * 3600
                    if isDraggingStart {
                        task.start = task.start.addingTimeInterval(deltaSec)
                    } else {
                        task.end = task.end.addingTimeInterval(deltaSec)
                    }
                }
                .onEnded { _ in
                    taskViewModel.update(task)
                }
        )
    }
}

//#Preview {
//    TaskBar()
//}
