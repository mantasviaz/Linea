//
//  TabHomeView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//
import SwiftUI
import Foundation

struct TabHomeView: View {
    @State private var editingTask: LineaTask? = nil
    @State private var scrollX: CGFloat = 0

    @State private var isSheetExpanded = false
    @State private var selectedTask: LineaTask? = nil
    @State private var showTaskDetailSheet = false
    @State private var sheetDragOffset: CGFloat = 0
    @State private var sheetPosition: Int = 1  // 0 = small, 1 = medium (start), 2 = expanded
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var showAddSheet = false
    @State private var addSheetDragOffset: CGFloat = 0
    @State private var showNewGroupSheet = false

    @State private var showColorSelectSheet = false
    @State private var selectedGroupKeyForColor: String = ""
    @State private var tempColorForGroup: Color = .gray
    @State private var colorSelectDragOffset: CGFloat = 0
    @State private var origColor: Color = .gray

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                let dayWidth = geo.size.width / 7.123
                VStack(spacing: 0) {
                    Rectangle().fill(Color.gray.opacity(0.4)).frame(height: 1)
                    TimelineScrollView(dayWidth: dayWidth, geoSize: geo, scrollX: $scrollX, selectedTask: $selectedTask, showTaskDetailSheet: $showTaskDetailSheet, showAddSheet: $showAddSheet)
                        .frame(height: geo.size.height / 1.1)
                        .overlay(alignment: .topLeading) {
                            ZStack(alignment: .topLeading) {
                                MonthHeaderView(dayWidth: dayWidth, scrollX: scrollX, viewWidth: geo.size.width)
                                    .offset(x: 0, y: -70)
                                DateHeaderView(dayWidth: dayWidth)
                                    .offset(x: -scrollX, y: -41)
                                    .allowsHitTesting(false)
                            }
                        }
                }
                .padding(.top, 72)
                let timelineHeight = geo.size.height / 1.865 + 75
                let collapsedY = timelineHeight
                let fullHeight = geo.size.height
                let smallY = fullHeight - 40
                let sheetOffset: CGFloat = {
                    switch sheetPosition {
                    case 2: return 0
                    case 1: return collapsedY
                    default: return smallY
                    }
                }() + sheetDragOffset

                Button(action: {
                    withAnimation(.interactiveSpring) {
                        editingTask = nil
                        showAddSheet = true
                        showTaskDetailSheet = false
                    }
                }) {
                    Rectangle()
                      .foregroundColor(.white)
                      .frame(width: 44, height: 44)
                      .cornerRadius(14)
                      .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                      .overlay(
                        RoundedRectangle(cornerRadius: 14)
                          .inset(by: 0.5)
                          .stroke(.black.opacity(0.05), lineWidth: 1)
                      )
                      .overlay(
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .padding(12)

                      )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .offset(y: sheetOffset - 57)
                .zIndex(3)
                

                BottomSheet(isExpanded: $isSheetExpanded, translation: $sheetDragOffset, collapsedY: collapsedY) {
                    FocusView(onTap: { task in
                        withAnimation(.interactiveSpring) {
                            selectedTask = task
                            showTaskDetailSheet = true
                        }
                    })
                }
                .frame(width: geo.size.width, height: fullHeight, alignment: .top)
                .ignoresSafeArea(edges: [.horizontal, .bottom])
                .offset(y: {
                    switch sheetPosition {
                    case 2: return 0
                    case 1: return collapsedY
                    default: return smallY
                    }
                }() + sheetDragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            sheetDragOffset = value.translation.height
                        }
                        .onEnded { value in
                            withAnimation(.interactiveSpring()) {
                                if value.translation.height < -100 {
                                    // dragged up: move one state up
                                    sheetPosition = min(sheetPosition + 1, 2)
                                } else if value.translation.height > 100 {
                                    // dragged down: move one state down
                                    sheetPosition = max(sheetPosition - 1, 0)
                                }
                                sheetDragOffset = 0
                            }
                        }
                )
                if let task = selectedTask, showTaskDetailSheet {
                    BottomSheet(isExpanded: .constant(true),
                                translation: $addSheetDragOffset,
                                collapsedY: collapsedY,
                                showHandle: false) {
                        TaskBigDetailView(task: Binding(
                            get: {
                                taskViewModel.tasks.first(where: { $0.id == task.id }) ?? task
                            },
                            set: { taskViewModel.update($0) }
                        ), showTaskDetailSheet: $showTaskDetailSheet, showAddSheet: $showAddSheet, editingTask: $editingTask)
                    }
                    .frame(width: geo.size.width, height: fullHeight, alignment: .top)
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    .offset(y: collapsedY)
                    .transition(.move(edge: .bottom))
                    .zIndex(6)
                }
                
                
                if showAddSheet {
                    BottomSheet(isExpanded: .constant(true),
                                translation: $addSheetDragOffset,
                                collapsedY: collapsedY,
                                showHandle: false) {
                        AddTaskView(showAddSheet: $showAddSheet, showNewGroupSheet: $showNewGroupSheet, editingTask: editingTask)
                    }
                    .frame(width: geo.size.width, height: fullHeight, alignment: .top)
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    .offset(y: collapsedY + addSheetDragOffset)
                    .transition(.move(edge: .bottom))
                    .zIndex(4)
                    .allowsHitTesting(!showNewGroupSheet)
                }
                if showNewGroupSheet {
                    BottomSheet(isExpanded: .constant(true),
                                translation: $addSheetDragOffset,
                                collapsedY: collapsedY,
                                showHandle: false) {
                        EditGroupView(showNewGroupSheet: $showNewGroupSheet, showColorPicker: $showColorSelectSheet, selectedGroupKey: $selectedGroupKeyForColor, tempColor: $tempColorForGroup, origColor: $origColor)
                    }
                    .frame(width: geo.size.width, height: fullHeight - collapsedY, alignment: .top)
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    .offset(y: collapsedY + addSheetDragOffset)
                    .transition(.move(edge: .bottom))
                    .zIndex(5)
                }
                if showColorSelectSheet {
                    BottomSheet(isExpanded: .constant(true),
                                translation: $colorSelectDragOffset,
                                collapsedY: collapsedY,
                                showHandle: false) {
                        ColorSelectView(
                            showColorPicker: $showColorSelectSheet,
                            selectedGroupKey: $selectedGroupKeyForColor,
                            tempColor: $tempColorForGroup,
                            origColor: $origColor
                        )
                    }
                    .frame(width: geo.size.width, height: fullHeight, alignment: .top)
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    .offset(y: collapsedY + colorSelectDragOffset)
                    .transition(.move(edge: .bottom))
                    .zIndex(7)
                }
            }
        }
    }
}
