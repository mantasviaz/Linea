//
//  HomeScreenView.swift
//  Linea
//

import SwiftUI
import Observation

private struct ScrollXKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeScreenView: View {
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var scrollX: CGFloat = 0 // current horizontal offset of the timeline

    init() {
       UIScrollView.appearance().bounces = false
    }
    var body: some View {
        GeometryReader { geo in
            //change based on selected weekly vs not
            let dayWidth = geo.size.width / 7.123
            
            VStack(spacing: 0) {
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                
                TimelineScrollView(dayWidth: dayWidth, scrollX: $scrollX)
                    .frame(height: geo.size.height / 1.98)
                    .overlay(alignment: .topLeading) {
                        DateHeaderView(dayWidth: dayWidth)
                            .offset(x: -scrollX, y: -41)
                            .allowsHitTesting(false)
                    }

                
                Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 2)
            }
            
            .padding(.top, 72)
        }
    }
}

struct TimelineScrollView: View {
    var dayWidth: CGFloat
    @Binding var scrollX: CGFloat
    @Environment(TaskViewModel.self) var taskViewModel

    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ScrollViewReader { proxy in
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                scrollX = -geo.frame(in: .global).minX
                            }
                            .onChange(of: geo.frame(in: .global).minX) { newVal in
                                scrollX = -newVal
                            }
                    }
                    .frame(width: 1, height: 1)

                    
                    CurrentTimelineView(dayWidth: dayWidth)
                        .id("now")
                        .zIndex(2)

                    TimelineGridView(dayWidth: dayWidth)

                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(taskViewModel.tasks, id: \.id) { task in
                            TaskBar(task: Binding(
                                get: { taskViewModel.tasks.first(where: { $0.id == task.id })! },
                                set: { taskViewModel.update($0) }
                            ), dayWidth: dayWidth)
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                }
                .frame(
                    width: taskViewModel.xPosition(
                        for: taskViewModel.visibleWindow.upperBound,
                        dayWidth: dayWidth
                    ),
                    alignment: .topLeading
                )
                .frame(minHeight: 250)
                .onAppear {
                    DispatchQueue.main.async {
                        proxy.scrollTo("now", anchor: UnitPoint(x: 0.5, y: 0))
                    }
                }
            }
        }
    }
}


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

struct DateHeaderView: View {
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) private var taskVM
    private let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f
    }()
    private let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "d"
        return f
    }()

    var body: some View {
        let total = Calendar.current.dateComponents(
            [.day], from: taskVM.visibleWindow.lowerBound, to: taskVM.visibleWindow.upperBound
        ).day ?? 0
        LazyHStack(spacing: 0) {
            ForEach(0...total, id: \.self) { off in
                let d = Calendar.current.date(byAdding: .day, value: off, to: taskVM.visibleWindow.lowerBound)!
                VStack(alignment: .leading, spacing: -1) {
                    Text(weekdayFormatter.string(from: d))
                        .font(.system(size: 10))
                    Text(dayFormatter.string(from: d))
                        .font(.system(size: 17))
                }
                .frame(width: dayWidth, alignment: .leading)
            }
        }
        .padding(.leading, 2)
        .frame(height: 40)         // intrinsic vertical size
        .background(Color(.systemBackground))
    }
}




struct CurrentTimelineView: View {
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



#Preview {
    @Previewable @State var taskViewModel = TaskViewModel()
    HomeScreenView()
        .environment(taskViewModel)
}
