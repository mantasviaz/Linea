//
//  TabHomeView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//
import SwiftUI
import Foundation
import AVFoundation
import UIKit

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
    @Binding var isPlusExpanded: Bool
    
    @State private var showScanner        = false
    @State private var isProcessingScan   = false
    @State private var capturedImage: UIImage? = nil
    @State private var gptResult: String? = nil
    

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

                ZStack(alignment: .top) {
                    // ── First auxiliary button ──────────────────────────────────────────────
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {

                            isPlusExpanded = false
                            showScanner    = true
                        }
                    }) {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(.black.opacity(0.05), lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "text.viewfinder")
                                    .font(.system(size: 15).weight(.medium))
                                    .foregroundStyle(.black)
                                    .padding(.leading, 0.5)
                                    .padding(8)
                                
                            )
                            .overlay(alignment: .leading) {
                                Text("Scan for Tasks")
                                    .font(.system(size: 15).weight(.medium))
                                    .foregroundStyle(.black)
                                    .fixedSize()
                                    .padding(.leading, 52)
                                    .opacity(isPlusExpanded ? 1 : 0)
                                    .allowsHitTesting(false)
                            }
                    }
                    .offset(y: isPlusExpanded ? -48 : 0)
                    .opacity(isPlusExpanded ? 1 : 0)

                    // ── Second auxiliary button ────────────────────────────────────────────
                    Button(action: {
                        // TODO: add action for second auxiliary button
                    }) {
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .inset(by: 0.5)
                                    .stroke(.black.opacity(0.05), lineWidth: 1)
                            )
                            .overlay(
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.body)
                                    .foregroundStyle(.black)
                                    .padding(8)
                            )
                            .overlay(alignment: .leading) {
                                Text("Filter")
                                    .font(.system(size: 15).weight(.medium))
                                    .foregroundStyle(.black)
                                    .fixedSize()
                                    .padding(.leading, 52)
                                    .opacity(isPlusExpanded ? 1 : 0)
                                    .allowsHitTesting(false)

                            }
                    }
                    .offset(y: isPlusExpanded ? -92 : 0)
                    .opacity(isPlusExpanded ? 1 : 0)

                    // ── Main PLUS button ───────────────────────────────────────────────────
                    Button(action: {
                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.8)) {
                            if isPlusExpanded {
                                editingTask = nil
                                showAddSheet = true
                                showTaskDetailSheet = false
                            }
                            isPlusExpanded.toggle()
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
                                    .rotationEffect(.degrees(isPlusExpanded ? (showAddSheet ? 0 : 180) : 0))
                            )
                            .overlay(alignment: .leading) {
                                Text("New Task")
                                    .font(.system(size: 15).weight(.medium))
                                    .foregroundStyle(.black)
                                    .fixedSize()
                                    .padding(.leading, 56)
                                    .opacity(isPlusExpanded ? 1 : 0)
                                    .allowsHitTesting(false)
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
                .offset(y: sheetOffset - 57)
                .animation(.spring(response: 0.35,
                                   dampingFraction: 0.8,
                                   blendDuration: 0.8),
                           value: isPlusExpanded)
                .zIndex(99)

                if isPlusExpanded {
                    Color.white
                        .opacity(0.7)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.35,
                                                  dampingFraction: 0.8,
                                                  blendDuration: 0.8)) {
                                isPlusExpanded = false
                            }
                        }
                        .ignoresSafeArea()
                        .zIndex(98)
                }
                

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
            if showScanner {
                // dim everything behind the sheet
                Color.white.opacity(0.8)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35,
                                              dampingFraction: 0.8,
                                              blendDuration: 0.8)) {
                            showScanner       = false
                            gptResult         = nil
                            isProcessingScan  = false
                            capturedImage     = nil
                        }
                    }
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(150)

                CameraScanSheet(
                    showScanner: $showScanner,
                    isProcessing: $isProcessingScan,
                    resultText: $gptResult,
                    onCapture: { img in
                        // show spinner and kick off upload
                        capturedImage   = img
                        isProcessingScan = true
                        Task {
                            await sendImageToGPT(img)
                            isProcessingScan = false
                        }
                    },
                    showNewGroupSheet: $showNewGroupSheet
                    )
                    .transition(.move(edge: .bottom))
                    .zIndex(151)
            }
        }
    }
}

extension TabHomeView {
    func sendImageToGPT(_ image: UIImage) async {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else { return }
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let imgData = image.jpegData(compressionQuality: 0.85)?.base64EncodedString() ?? ""
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text",  "text": """
Please extract the assignments listed in this image. For EACH one, return:
{
  "assignment_name": "...",
  "due_date": "...",
  "due_time": "..."
}
If due time is not specified, leave it as null. Return JSON only. DO NOT HALLUCINATE
""" ],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(imgData)"]]
                    ]
                ]
            ]
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                let choices = json["choices"] as? [[String: Any]],
                let message = choices.first?["message"] as? [String: Any],
                let content = message["content"] as? String {
                await MainActor.run { self.gptResult = content }
            } else {
                await MainActor.run { self.gptResult = String(data: data, encoding: .utf8) }
            }
        } catch {
            print(error)
            await MainActor.run { self.gptResult = "Error: \(error.localizedDescription)" }
        }
    }
}



