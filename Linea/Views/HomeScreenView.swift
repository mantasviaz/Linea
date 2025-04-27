//
//  HomeScreenView.swift
//  Linea
//

import SwiftUI
import Observation
import UIKit

extension Notification.Name {
    static let homeTabSelected = Notification.Name("homeTabSelected")
}

extension Notification.Name {
    static let commitGroupNames = Notification.Name("commitGroupNames")
}

private struct ScrollXKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeScreenView: View {
    @State private var selectedTab = 0
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var scrollX: CGFloat = 0 // current horizontal offset of the timeline
    @State private var isSheetExpanded = false
    @State private var sheetDragOffset: CGFloat = 0

    init() {
        UIScrollView.appearance().bounces = false
    }
    var body: some View {
        CustomTabBarController(selectedTab: $selectedTab)
            .ignoresSafeArea(edges: .bottom)
    }
}

struct TimelineScrollView: View {
    var dayWidth: CGFloat
    var geoSize: GeometryProxy
    @Binding var scrollX: CGFloat
    @State private var didInitialScroll = false
    @Environment(TaskViewModel.self) var taskViewModel
    @Binding var selectedTask: Task?
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

                    
                    CurrentTimelineView(dayWidth: dayWidth)
                        .id("now")
                        .zIndex(0)

                    TimelineGridView(dayWidth: dayWidth)

                    VStack(alignment: .leading, spacing: 9) {
                        ForEach(taskViewModel.tasks, id: \.id) { task in
                            TaskBar(task: Binding(
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
    @Environment(TaskViewModel.self) private var taskViewModel
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
            [.day], from: taskViewModel.visibleWindow.lowerBound, to: taskViewModel.visibleWindow.upperBound
        ).day ?? 0
        LazyHStack(spacing: 0) {
            ForEach(0...total, id: \.self) { off in
                let d = Calendar.current.date(byAdding: .day, value: off, to: taskViewModel.visibleWindow.lowerBound)!
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

struct MonthHeaderView: View {
    let dayWidth: CGFloat
    let scrollX: CGFloat
    let viewWidth: CGFloat
    @Environment(TaskViewModel.self) private var vm

    private var leftDate: Date {
        let days = (scrollX / dayWidth).rounded(.toNearestOrAwayFromZero)
        return Calendar.current.date(
            byAdding: .day,
            value: Int(days),
            to: vm.windowOrigin
        )!
    }

    private var thisMonthStart: Date {
        Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: leftDate)
        )!
    }
    private var nextMonthStart: Date {
        Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: thisMonthStart
        )!
    }

    private var thisText: String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: thisMonthStart)
    }
    private var nextText: String {
        let f = DateFormatter()
        f.dateFormat = "LLLL yyyy"
        return f.string(from: nextMonthStart)
    }

    private var endX: CGFloat { vm.xPosition(for: nextMonthStart, dayWidth: dayWidth) }
    private var startX: CGFloat { endX - viewWidth }

    private var progress: CGFloat {
        guard scrollX >= startX else { return 0 }
        guard scrollX <= endX   else { return 1 }
        return (scrollX - startX) / (endX - startX)
    }

    var body: some View {
        ZStack(alignment: .leading) {
            // old month slides out
            Text(thisText)
                .font(.system(size: 22).weight(.bold))
                .offset(x: -progress * viewWidth)
                .padding(.leading, 15)

            // new month slides in
            Text(nextText)
                .font(.system(size: 22).weight(.bold))
                .offset(x: (1 - progress) * viewWidth)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

struct BottomSheet<Content: View>: View {
    
    @Binding var isExpanded: Bool
    @Binding var translation: CGFloat
    let collapsedY: CGFloat
    let showHandle: Bool
    let content: Content

    init(isExpanded: Binding<Bool>, translation: Binding<CGFloat>, collapsedY: CGFloat, showHandle: Bool = true, @ViewBuilder content: () -> Content) {
        self._isExpanded = isExpanded
        self._translation = translation
        self.collapsedY = collapsedY
        self.showHandle = showHandle
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if showHandle {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 2)
                    .padding(.top, -2)

                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(Color.gray.opacity(0.7))
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            content
                .padding(.horizontal, 15)
                .padding(.bottom, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}

struct TodayFocusView: View {
    @Environment(TaskViewModel.self) private var taskViewModel
    var onTap: (Task) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Focus")
                .font(.system(size: 21).weight(.bold))
                .padding(.top, -10)
            let now = Date()
            ForEach(taskViewModel.tasks.filter { $0.end >= now }) { task in
                FocusTask(task: task)
                    .id(task.group)
                    .onTapGesture { onTap(task) }
                Rectangle()
                    .fill(Color(red: 0.88, green: 0.88, blue: 0.88))
                    .frame(height: 1)
                    .padding(.horizontal, 14)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CustomTabBarController: UIViewControllerRepresentable {
    @Binding var selectedTab: Int

    func makeUIViewController(context: Context) -> UITabBarController {
        let tabBarController = UITabBarController()
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .gray // top border line
        tabBarController.tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance
        }
        // Home Tab
        let homeVC = UIHostingController(rootView: HomeTabView())
        homeVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "house"), tag: 0)
        // Add Tab
        let addVC = UIHostingController(rootView: AddTabView())
        addVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "add"), tag: 1)
        // Settings Tab
        let settingsVC = UIHostingController(rootView: SettingsTabView())
        settingsVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "settings"), tag: 2)

        tabBarController.viewControllers = [homeVC, addVC, settingsVC]
        tabBarController.selectedIndex = selectedTab
        tabBarController.delegate = context.coordinator
        return tabBarController
    }

    func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
        uiViewController.selectedIndex = selectedTab
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITabBarControllerDelegate {
        var parent: CustomTabBarController

        init(_ parent: CustomTabBarController) {
            self.parent = parent
        }

        func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
            parent.selectedTab = tabBarController.selectedIndex
            if parent.selectedTab == 0 {
                NotificationCenter.default.post(name: .homeTabSelected, object: nil)
            }
        }
    }
}

struct HomeTabView: View {
    @State private var editingTask: Task? = nil
    @State private var scrollX: CGFloat = 0
    @State private var isSheetExpanded = false
    @State private var selectedTask: Task? = nil
    @State private var showTaskDetailSheet = false
    @State private var sheetDragOffset: CGFloat = 0
    @State private var sheetPosition: Int = 1  // 0 = small, 1 = medium (start), 2 = expanded
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var showAddSheet = false
    @State private var addSheetDragOffset: CGFloat = 0
    @State private var showNewGroupSheet = false

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
                    TodayFocusView(onTap: { task in
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
                //MARKK:
                if let task = selectedTask, showTaskDetailSheet {
                    BottomSheet(isExpanded: .constant(true),
                                translation: $addSheetDragOffset,
                                collapsedY: collapsedY,
                                showHandle: false) {
                        TaskDetailView(task: task, showTaskDetailSheet: $showTaskDetailSheet, showAddSheet: $showAddSheet, editingTask: $editingTask)
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
                        AddTab(showAddSheet: $showAddSheet, showNewGroupSheet: $showNewGroupSheet, editingTask: editingTask)
                    }
                    .frame(width: geo.size.width, height: fullHeight, alignment: .top)
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    .offset(y: collapsedY + addSheetDragOffset - 35)
                    .transition(.move(edge: .bottom))
                    .zIndex(4)
                    .allowsHitTesting(!showNewGroupSheet)
                }
                if showNewGroupSheet {
                    BottomSheet(isExpanded: .constant(true),
                                translation: $addSheetDragOffset,
                                collapsedY: collapsedY,
                                showHandle: false) {
                        NewGroupView(showNewGroupSheet: $showNewGroupSheet)
                    }
                    .frame(width: geo.size.width, height: fullHeight, alignment: .top)
                    .ignoresSafeArea(edges: [.horizontal, .bottom])
                    .offset(y: collapsedY + addSheetDragOffset - 35)
                    .transition(.move(edge: .bottom))
                    .zIndex(5)
                }
            }
        }
    }
}

struct AddTab: View {
    @Binding var showAddSheet: Bool
    @Binding var showNewGroupSheet: Bool
    var editingTask: Task?
    @State var selectedGroup: String

    @State private var title: String
    @State private var location: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var showStartTimePicker: Bool
    @State private var showEndTimePicker: Bool
    @State private var group = ""
    
    init(showAddSheet: Binding<Bool>,
         showNewGroupSheet: Binding<Bool>,
         editingTask: Task?) {
        self._showAddSheet = showAddSheet
        self._showNewGroupSheet = showNewGroupSheet
        self.editingTask = editingTask

        if let t = editingTask {
            _title         = State(initialValue: t.title)
            _location      = State(initialValue: "")
            _selectedGroup = State(initialValue: t.group)
            _startDate     = State(initialValue: t.start)
            _endDate       = State(initialValue: t.end)
            // determine whether the task already has explicit times
            let cal = Calendar.current
            let startCmp = cal.dateComponents([.hour, .minute, .second], from: t.start)
            let endCmp   = cal.dateComponents([.hour, .minute, .second], from: t.end)
            let hasStartTime = (startCmp.hour ?? 0) != 0 || (startCmp.minute ?? 0) != 0 || (startCmp.second ?? 0) != 0
            // default “no‑time” end is 23:59 → treat any other end‑time as explicit
            let hasEndTime = !((endCmp.hour ?? 23) == 23 && (endCmp.minute ?? 59) == 59)
            _showStartTimePicker = State(initialValue: hasStartTime)
            _showEndTimePicker   = State(initialValue: hasEndTime)
        } else {
            _title         = State(initialValue: "")
            _location      = State(initialValue: "")
            _selectedGroup = State(initialValue: "")
            _startDate     = State(initialValue: Calendar.current.startOfDay(for: Date()))
            _endDate       = State(initialValue: Calendar.current.date(bySettingHour: 23,
                                                                       minute: 59,
                                                                       second: 0,
                                                                       of: Date())!)
            _showStartTimePicker = State(initialValue: false)
            _showEndTimePicker   = State(initialValue: false)
        }
    }


    private func resetFields() {
        title = ""
        location = ""
        selectedGroup = ""
        startDate = Calendar.current.startOfDay(for: Date())
        endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 0, of: Date())!
        showStartTimePicker = false
        showEndTimePicker = false
        group = ""
    }

    @Environment(TaskViewModel.self) private var taskViewModel
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Button(action: {
                    withAnimation(.interactiveSpring) {showAddSheet.toggle()}
                    resetFields()
                }) {
                    Text("Cancel")
                        .font(.system(size: 17))
                        .padding(.leading, -11)
                        .padding(.top, 15)
                }
                Spacer()
                Button(action: {
                    if let original = editingTask {
                        let updated = Task(id: original.id,
                                           group: selectedGroup,
                                           title: title,
                                           start: startDate,
                                           end: endDate)
                        taskViewModel.update(updated)
                    } else {
                        let newTask = Task(id: UUID(),
                                           group: selectedGroup,
                                           title: title,
                                           start: startDate,
                                           end: endDate)
                        taskViewModel.update(newTask)
                    }
                    withAnimation(.interactiveSpring) { showAddSheet.toggle()
                    resetFields()
                    }
                }) {
                    Text(editingTask == nil ? "Add" : "Update")
                        .font(.system(size: 17).weight(.bold))
                        .padding(.trailing, -11)
                        .padding(.top, 15)
                }
                .disabled(title.isEmpty)
            }
            TextField("Title", text: $title)
                .font(.system(size: 26).weight(.bold))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(taskViewModel.groups), id: \.key) { key, value in
                        GroupTab(group: key, color: value, selectedGroup: selectedGroup) { _ in
                            if selectedGroup == key {
                                selectedGroup = ""
                            } else {
                                selectedGroup = key
                            }
                        }
                    }
                    Button(action: {
                        showNewGroupSheet = true
                    }) {
                        Text("Edit")
                            .padding(.bottom, 2)
                            .foregroundStyle(Color.black)
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .frame(width: 60, height: 34)
                            
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray)
                                    .opacity(0.2)
                                    .shadow(color: Color.black.opacity(0.5),
                                        radius: 2,
                                        x: 0,
                                        y: 2
                                    )
                            )
                            .opacity(0.7)
                        
                    }
                }
                .padding(.bottom, 4)
                .padding(.horizontal, 4)
            }
            .padding(.leading, -4)
            
            Rectangle().fill(Color(red: 0.88, green: 0.88, blue: 0.88)).frame(height: 1)
            
            HStack {
                Text("Starts")
                    .font(.system(size: 17).weight(.semibold))
                    .foregroundStyle(Color(red: 0.13, green: 0.13, blue: 0.15))
                Spacer()
                if showStartTimePicker {
                    DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                } else {
                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                        .labelsHidden()
                        .padding(.top, 1)
                }


                Button(action: {
                    withTransaction(Transaction(animation: nil)) {
                        showStartTimePicker.toggle()
                    }
                }) {
                    if !showStartTimePicker {
                        Text(showStartTimePicker ? "" : "+ Add Time")
                            .font(.system(size: 17).weight(.regular))
                            .foregroundStyle(Color(red: 0, green: 0.48, blue: 1))
                            .padding(.horizontal, 3)
                    } else {
                    }
                    
                }

            }
            
            HStack {
                Text("Ends")
                    .font(.system(size: 17).weight(.semibold))
                    .foregroundStyle(Color(red: 0.13, green: 0.13, blue: 0.15))
                Spacer()
                if showEndTimePicker {
                    DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                        .labelsHidden()
                } else {
                    DatePicker("", selection: $endDate, displayedComponents: [.date])
                        .labelsHidden()
                        .padding(.top, 1)
                }


                Button(action: {
                    withTransaction(Transaction(animation: nil)) {
                        showEndTimePicker.toggle()
                    }
                }) {
                    if !showEndTimePicker {
                        Text(showEndTimePicker ? "" : "+ Add Time")
                            .font(.system(size: 17).weight(.regular))
                            .foregroundStyle(Color(red: 0, green: 0.48, blue: 1))
                            .padding(.horizontal, 3)
                    } else {
                    }
                }

            }
            
            Rectangle().fill(Color(red: 0.88, green: 0.88, blue: 0.88)).frame(height: 1)
            
            TextField("Add Location", text: $location)
                .font(.system(size: 17).weight(.semibold))
                .padding(.top, 12)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 11)
        .padding(.trailing, 11)
    }
}

struct GroupTab: View {
    
    var group: String
    var color: Color
    var selectedGroup: String?
    var onSelect: (String) -> Void

    var isSelected: Bool {
        selectedGroup == group
    }

    var body: some View {
        let verifiedColor = color.appropriateTextColor(darkTextColor: Color(red: 0.38, green: 0.38, blue: 0.39), lightTextColor: Color.white)
        let verifiedSelectedColor = color.appropriateTextColor(darkTextColor: Color.black, lightTextColor: Color.white)
        Text(group)
            .foregroundStyle(isSelected ? verifiedSelectedColor : verifiedColor)
            .font(.system(size: 17))
            .fontWeight(isSelected ? .bold : .regular)
            .padding(.horizontal, 12)
            .frame(minWidth: 80)
            .frame(height: 34)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .shadow(
                        color: isSelected ? Color.clear : Color.black.opacity(0.15),
                        radius: 2,
                        x: 0,
                        y: 2
                    )
            )
            .opacity(isSelected ? 1 : 0.7)
            .animation(.easeInOut(duration: 0.1), value: isSelected)
            .onTapGesture {
                onSelect(group)
            }
    }
}

struct AddTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Add")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            }
            .navigationTitle("Add")
        }
    }
}

struct SettingsTabView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .foregroundColor(.black)
            }
            .navigationTitle("Settings")
        }
    }
}

struct FocusTask: View {
    let task: Task
    @Environment(TaskViewModel.self) private var taskViewModel
    
    var body: some View {
        let now = Date()
        let interval = task.end.timeIntervalSince(now)
        HStack {
            Capsule()
                .frame(width: 6, height: 40)
                .foregroundColor(taskViewModel.groups[task.group]?.darkerCustom())
            VStack(alignment: .leading){
                Text(task.title)
                    .font(.system(size: 13).weight(.bold))
                    .lineLimit(1)
                    .padding(.bottom, -2)
                Text("\(formattedDateRange(start: task.start, end: task.end))")
                    .font(.system(size: 9))
                    .lineLimit(1)
            }
            Spacer()
            Group {
                if Calendar.current.isDate(task.end, inSameDayAs: now) {
                    Text("Due Today")
                        .font(.system(size: 10).weight(.semibold))
                        .lineLimit(1)
                        .foregroundColor(Color(red: 0.95, green: 0.29, blue: 0.25))
                } else if Calendar.current.isDate(task.end, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: now)!) {
                    Text("Due Tomorrow")
                        .font(.system(size: 10).weight(.semibold))
                        .lineLimit(1)
                        .foregroundColor(Color(red: 1, green: 0.58, blue: 0))
                }
            }
        }
        .id(task.group)
        .padding(.horizontal, 8)
        .padding(.bottom, -6)
        .padding(.top, -6)
    }
}



//TODO: Figure out this function
extension Color {
    func darkerCustom() -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        if uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let average = (r + g + b) / 3
            let vibrancyBoost: CGFloat = 0.2

            
            let lightnessThreshold: CGFloat = 0.85
            if (r + g + b) / 3 > lightnessThreshold {
                r *= 0.98
                g *= 0.98
                b *= 0.98
            }


            return Color(red: r, green: g, blue: b, opacity: a)
        } else {
            return self
        }
    }
}



/// Single editable row inside the *New Group* sheet.
private struct GroupRowView: View {
    @Environment(TaskViewModel.self) private var vm
    /// The key when this row was created – used to rename later.
    @State private var originalName: String
    /// Live‑editable text shown in the field.
    @State private var name: String
    /// Current color swatch for the row.
    var color: Color
    /// Callbacks provided by the parent view.
    var oncolorTap: () -> Void
    var onDelete: () -> Void

    init(name: String,
         color: Color,
         oncolorTap: @escaping () -> Void,
         onDelete: @escaping () -> Void) {
        _originalName = State(initialValue: name)
        _name             = State(initialValue: name)
        self.color       = color
        self.oncolorTap  = oncolorTap
        self.onDelete     = onDelete
    }

    var body: some View {
        HStack(spacing: 12) {
            TextField("Group Name", text: $name)
                .textFieldStyle(.roundedBorder)

            Rectangle()
                .fill(color)
                .frame(width: 24, height: 24)
                .cornerRadius(4)
                .onTapGesture(perform: oncolorTap)

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.system(size: 20))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .commitGroupNames)) { _ in
            vm.renameGroup(oldName: originalName, newName: name)
            originalName = name
        }
    }
}

struct NewGroupView: View {
    @Binding var showNewGroupSheet: Bool

    @State private var showColorPicker = false
    @State private var selectedGroupKey = ""
    @State private var tempColor = Color.gray

    @Environment(TaskViewModel.self) private var taskViewModel

    var body: some View {
        VStack(spacing: 12) {

            HStack {
                Button("Done") {
                    // Dismiss keyboard to trigger onCommit in text fields
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                    NotificationCenter.default.post(name: .commitGroupNames, object: nil)
                    withAnimation(.interactiveSpring) { showNewGroupSheet = false }
                }
                .font(.system(size: 17).weight(.bold))

                Spacer()
            }
            .padding(.top, 15)

            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 8) {
                    ForEach(Array(taskViewModel.groups).sorted(by: { $0.key < $1.key }), id: \.key) { key, color in
                        GroupRowView(
                            name: key,
                            color: color,
                            oncolorTap: {
                                selectedGroupKey = key
                                tempColor = color
                                showColorPicker = true
                            },
                            onDelete: {
                                taskViewModel.deleteGroup(name: key)
                            }
                        )
                    }

                    // add‑group row
                    Button {
                        taskViewModel.addGroup(name: "", color: .gray)
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Group")
                        }
                        .font(.system(size: 17).weight(.semibold))
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 11)
        .frame(maxHeight: .infinity)
        .layoutPriority(1)
        // color‑picker sheet
        .sheet(isPresented: $showColorPicker) {
            VStack(spacing: 16) {
                ColorPicker("Custom Color",
                            selection: $tempColor,
                            supportsOpacity: false)
                    .onChange(of: tempColor) { newcolor in
                        taskViewModel.updateGroupColor(name: selectedGroupKey,
                                                       color: newcolor)
                    }

                Text("Preset Colors")
                    .font(.headline)

                // preset swatches
                HStack {
                    ForEach(Array(taskViewModel.colors.values), id: \.self) { color in
                        Rectangle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                            .cornerRadius(4)
                            .onTapGesture {
                                tempColor = color
                                taskViewModel.updateGroupColor(name: selectedGroupKey,
                                                               color: color)
                                showColorPicker = false
                            }
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct TaskDetailView: View {
    var task: Task
    @Binding var showTaskDetailSheet: Bool
    @Binding var showAddSheet: Bool
    @Binding var editingTask: Task?
    @Environment(TaskViewModel.self) private var taskViewModel

    var body: some View {
        let now = Date()
        let interval = task.end.timeIntervalSince(now)
        VStack(spacing: 16) {
            HStack{
                Image("close")
                    .padding(.leading, -11)
                    .padding(.top, 15)
                    .onTapGesture {
                        withAnimation(.interactiveSpring)
                        {showTaskDetailSheet.toggle()}
                    }
            
                Spacer()
                
                Image(systemName: "pencil")
                    .font(.system(size: 20).weight(.bold))
                    .foregroundStyle(Color(red: 0.37, green: 0.37, blue: 0.3).opacity(1.0))
                    .onTapGesture{
                        withAnimation(.interactiveSpring) {
                            editingTask = task
                            showTaskDetailSheet.toggle()
                            showAddSheet.toggle()
                        }
                    }
                    .padding(.top, 17)
                    .padding(.trailing, 25)
                
                Image(systemName: "trash")
                    .font(.system(size: 18).weight(.bold))
                    .foregroundStyle(Color.red)
                    .fontWeight(.bold)
                    .onTapGesture {
                        withAnimation(.interactiveSpring) {
                            taskViewModel.delete(task)
                            showTaskDetailSheet = false
                        }
                    }
                    .padding(.leading, -11)
                    .padding(.top, 15)
            }
            

            
            
            HStack {
                Capsule()
                    .frame(width: 8, height: 90)
                    .foregroundColor(taskViewModel.groups[task.group]?.darkerCustom())
                    .padding(.top, 10)
                VStack(alignment: .leading){
                    Text(task.title)
                        .font(.system(size: 28).weight(.bold))
                        .lineLimit(1)
                        .padding(.bottom, -2)
                    HStack{
                        Text("\(formattedBiggerDateRange(start: task.start, end: task.end))")
                            .font(.system(size: 17))
                        Group {
                            if Calendar.current.isDate(task.end, inSameDayAs: now) {
                                Text("Due Today")
                                    .font(.system(size: 17).weight(.semibold))
                                    .lineLimit(1)
                                    .padding(.top, 20.8)
                                    .foregroundColor(Color(red: 0.95, green: 0.29, blue: 0.25))
                            } else if Calendar.current.isDate(task.end, inSameDayAs: Calendar.current.date(byAdding: .day, value: 1, to: now)!) {
                                Text("Due Tomorrow")
                                    .font(.system(size: 17).weight(.semibold))
                                    .lineLimit(1)
                                    .foregroundColor(Color(red: 1, green: 0.58, blue: 0))
                                    .padding(.top, 20.8)
                            }
                        }
                    }

                }
                .padding(.bottom, 15)
                .padding(.top, 25)

                .frame(maxWidth: .infinity, alignment: .leading)
                
                
            }
            .padding(.top, -10)
            
            
            Text("Mark as Completed")
                .foregroundStyle(.white)
                .font(.system(size: 17).weight(.semibold))
                .background(){
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 213, height: 45)
                      .background(Color(red: 0, green: 0.48, blue: 1))
                      .cornerRadius(14)
                }
                .padding(.top, 8)

            
            

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 11)
        .padding(.trailing, 11)
    }
}
