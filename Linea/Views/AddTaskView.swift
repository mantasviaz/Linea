//
//  AddTaskView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/27/25.
//

import SwiftUI
import Foundation

struct AddTaskView: View {
    @Binding var showAddSheet: Bool
    @Binding var showNewGroupSheet: Bool
    var editingTask: LineaTask?
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
         editingTask: LineaTask?) {
        self._showAddSheet = showAddSheet
        self._showNewGroupSheet = showNewGroupSheet
        self.editingTask = editingTask

        if let t = editingTask {
            _title         = State(initialValue: t.title)
            _location      = State(initialValue: "")
            _selectedGroup = State(initialValue: t.group)
            _startDate     = State(initialValue: t.start)
            _endDate       = State(initialValue: t.end)
            let cal = Calendar.current
            let startCmp = cal.dateComponents([.hour, .minute, .second], from: t.start)
            let endCmp   = cal.dateComponents([.hour, .minute, .second], from: t.end)
            let hasStartTime = (startCmp.hour ?? 0) != 0 || (startCmp.minute ?? 0) != 0 || (startCmp.second ?? 0) != 0
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
                        let updated = LineaTask(id: original.id,
                                           group: selectedGroup,
                                           title: title,
                                           start: startDate,
                                           end: endDate,
                                                completed: original.completed)
                        taskViewModel.update(updated)
                    } else {
                        let newTask = LineaTask(id: UUID(),
                                           group: selectedGroup,
                                           title: title,
                                           start: startDate,
                                           end: endDate,
                                                completed: false)
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
                        GroupBar(group: key, color: value, selectedGroup: selectedGroup) { _ in
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
                        Text(taskViewModel.groups.isEmpty ? "Add Group" : "Edit")
                            .padding(.bottom, 2)
                            .foregroundStyle(Color.black)
                            .font(.system(size: 17))
                            .fontWeight(.semibold)
                            .frame(width: taskViewModel.groups.isEmpty ? 110 : 60, height: 34)
                            
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
            .onAppear {
                UIScrollView.appearance().bounces = true
            }
            .onDisappear {
                UIScrollView.appearance().bounces = false
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
            
            //TextField("Add Location", text: $location)
                //.font(.system(size: 17).weight(.semibold))
                //.padding(.top, 12)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 11)
        .padding(.trailing, 11)
    }
}
