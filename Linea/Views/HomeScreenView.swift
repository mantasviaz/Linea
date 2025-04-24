//
//  HomeScreenView.swift
//  Linea
//

import SwiftUI
import Observation

struct HomeScreenView: View {
    @Environment(TaskViewModel.self) var taskViewModel

    var body: some View {
        GeometryReader { geo in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ScrollViewReader { proxy in
                    ZStack(alignment: .topLeading) {
                        TimelineGridView()

                        VStack(spacing: 20) {
                            ForEach(taskViewModel.tasks) { task in
                                TaskBar(task: Binding(
                                    get: { taskViewModel.tasks.first(where: { $0.id == task.id })! },
                                    set: { updated in taskViewModel.update(updated) }
                                ))
                            }
                        }
                        .padding(.top, 50)

                        CurrentTimelineView()
                    }
                    .frame(
                        width: taskViewModel.xPosition(for: taskViewModel.visibleWindow.upperBound),
                        height: geo.size.height
                    )
                    .onAppear {
                        if let firstID = taskViewModel.tasks.first?.id {
                            proxy.scrollTo(firstID, anchor: .center)
                        }
                    }
                }
            }
        }
    }
}

struct TimelineGridView: View {
    @Environment(TaskViewModel.self) var taskViewModel
    var body: some View {
        Canvas { context, size in
            let days = Int(taskViewModel.visibleWindow.upperBound.timeIntervalSince(taskViewModel.visibleWindow.lowerBound) / 86400)
            for d in 0...days {
                let x = CGFloat(d) * taskViewModel.dayWidth
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.gray.opacity(0.2)))
            }
        }
    }
}

struct CurrentTimelineView: View {
    @Environment(TaskViewModel.self) var taskViewModel
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            Canvas { context, size in
                let x = taskViewModel.xPosition(for: timeline.date)
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.blue), lineWidth: 2)
                
            }
        }
    }
}

#Preview {
    @Previewable @State var taskViewModel = TaskViewModel()
    HomeScreenView()
        .environment(taskViewModel)
}
