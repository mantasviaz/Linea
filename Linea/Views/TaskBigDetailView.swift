//
//  TaskBigDetailView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/27/25.
//

import SwiftUI
import Foundation

struct TaskBigDetailView: View {
    @Binding var task: LineaTask
    @Binding var showTaskDetailSheet: Bool
    @Binding var showAddSheet: Bool
    @Binding var editingTask: LineaTask?
    @Environment(TaskViewModel.self) var taskViewModel: TaskViewModel
    @State private var showDeleteConfirmation = false

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
                        showDeleteConfirmation = true
                    }
                    .padding(.leading, -11)
                    .padding(.top, 15)
            }
            

            
            
            HStack {
                Capsule()
                    .frame(width: 8, height: 90)
                    .foregroundColor(task.group.isEmpty ? Color(red: 0.87, green: 0.87, blue: 0.87) : taskViewModel.groups[task.group]?.darkerCustom())
                    .padding(.top, 10)
                VStack(alignment: .leading){
                    Text(task.group.isEmpty ? task.title : "\(task.group) - \(task.title)")
                        .font(.system(size: 28).weight(.bold))
                        //.lineLimit(1)
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
                .padding(.top, 10)

                .frame(maxWidth: .infinity, alignment: .leading)
                
                
            }
            .padding(.top, -10)
            
            Button(action: {
                withAnimation (.interactiveSpring){
                    task.completed.toggle()
                    showTaskDetailSheet = false
                }
                
                
            }) {
                Text(task.completed ? "Mark as Incomplete" : "Mark as Completed")
                    .foregroundStyle(task.completed ? Color(red: 0, green: 0.48, blue: 1) : .white)
                    .font(.system(size: 17).weight(.semibold))
                    .padding(12)
                    .padding(.horizontal, 5)
                    .background(task.completed ? .white : Color(red: 0, green: 0.48, blue: 1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(task.completed ? Color(red: 0, green: 0.48, blue: 1) : .clear, lineWidth: 2)
                    )
                    .cornerRadius(14)
                    .padding(.top, 8)
                    
            }


        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 11)
        .padding(.trailing, 11)
        .confirmationDialog("Are you sure you want to delete?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                withAnimation(.interactiveSpring) {
                    taskViewModel.delete(task)
                    showTaskDetailSheet = false
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}
