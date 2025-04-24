//
//  HomeScreenView.swift
//  Linea
//

import SwiftUI
import Observation

struct HomeScreenView: View {
    @Environment(TaskViewModel.self) var taskViewModel
    //TODO: Decide if to leave bouncing
    //init() {
    //   UIScrollView.appearance().bounces = false
    //}
    var body: some View {
        GeometryReader { geo in
            //change based on selected weekly vs not
            let dayWidth = geo.size.width / 7
            
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ScrollViewReader { proxy in
                    ZStack(alignment: .topLeading) {
                        //draw background grid lines
                        TimelineGridView(dayWidth: dayWidth)
                        
                        //tasks
                        VStack(spacing: 20) {
                            ForEach(taskViewModel.tasks) { task in
                                TaskBar(task: Binding(
                                    get: { taskViewModel.tasks.first(where: { $0.id == task.id })! },
                                    set: { updated in taskViewModel.update(updated) }
                                ), dayWidth: dayWidth)
                            }
                        }
                        .padding(.top, 50)
                            
                        //blue line
                        CurrentTimelineView(dayWidth: dayWidth)
                    }
                    //set canvas size
                    .frame(
                        width: taskViewModel.xPosition(for: taskViewModel.visibleWindow.upperBound, dayWidth: dayWidth),
                        alignment: .topLeading
                    )
                    .frame(minHeight: geo.size.height / 2)
                    //scroll to first task when loaded
                    .onAppear {
                        if let firstID = taskViewModel.tasks.first?.id {
                            withAnimation{
                                proxy.scrollTo(firstID, anchor: .center)
                            }
                        }
                    }
                }
            }
            .frame(height: geo.size.height / 2)
            .padding(.top, 100)
        }
    }
}

struct TimelineGridView: View {
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) var taskViewModel
    var body: some View {
        Canvas { context, size in
            let days = Int(taskViewModel.visibleWindow.upperBound.timeIntervalSince(taskViewModel.visibleWindow.lowerBound) / 86400)
            for d in 0...days {
                let x = CGFloat(d) * dayWidth
                var path = Path()
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                context.stroke(path, with: .color(.gray.opacity(0.5)))
            }
        }
    }
}

struct CurrentTimelineView: View {
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) var taskViewModel
    var body: some View {
        TimelineView(.periodic(from: .now, by: 60)) { timeline in
            Canvas { context, size in
                let x = taskViewModel.xPosition(for: timeline.date, dayWidth: dayWidth)
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
