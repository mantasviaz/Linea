//
//  TimelineScrollView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI
import Foundation

struct TimelineScrollView: View {
    var dayWidth: CGFloat
    var geoSize: GeometryProxy
    @Binding var scrollX: CGFloat
    @State private var didInitialScroll = false
    @Environment(TaskViewModel.self) var taskViewModel
    @Binding var selectedTask: LineaTask?
    @Binding var showTaskDetailSheet: Bool
    @Binding var showAddSheet: Bool

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

                    
                    CurrentLine(dayWidth: dayWidth)
                        .id("now")
                        .zIndex(0)
                    
                    //TODO: Decide if want
                    //TimelineGridView(dayWidth: dayWidth)

                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(taskViewModel.tasks, id: \.id) { task in
                            TimelineBar(task: Binding(
                                get: {
                                    taskViewModel.tasks.first(where: { $0.id == task.id }) ?? task
                                },
                                set: { taskViewModel.update($0) }
                            ), dayWidth: dayWidth)
                            .onTapGesture {
                                withAnimation(.interactiveSpring) {
                                    selectedTask = task
                                    showTaskDetailSheet = true
                                    showAddSheet = false
                                }
                            }
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, geoSize.size.height / 2.5)
                }
                .onReceive(NotificationCenter.default.publisher(for: .homeTabSelected)) { _ in
                    proxy.scrollTo("now", anchor: UnitPoint(x: 0.5011, y: 0))
                }
                .frame(
                    width: taskViewModel.xPosition(
                        for: taskViewModel.visibleWindow.upperBound,
                        dayWidth: dayWidth
                    ),
                    alignment: .topLeading
                )
                // keep the content pinned to the top and let it only shrink upward
                .frame(minHeight: geoSize.size.height, alignment: .top)
                .onAppear {
                    if !didInitialScroll {
                        DispatchQueue.main.async {
                            proxy.scrollTo("now", anchor: UnitPoint(x: 0.5011, y: 0))
                        }
                        didInitialScroll = true
                    }
                }
            }
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }

    }
}
