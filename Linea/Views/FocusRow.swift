//
//  FocusRow.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/27/25.
//

import SwiftUI
import Foundation

struct FocusRow: View {
    @Binding var task: LineaTask
    @Environment(TaskViewModel.self) private var taskViewModel
    
    var body: some View {
        let now = Date()
        let interval = task.end.timeIntervalSince(now)
        HStack {
            Capsule()
                .frame(width: 6, height: 40)
                .foregroundColor(task.group.isEmpty ? Color(red: 0.87, green: 0.87, blue: 0.87) : taskViewModel.groups[task.group]?.darkerCustom())
            VStack(alignment: .leading){
                Text(task.group.isEmpty ? task.title : "\(task.group) - \(task.title)")
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
        .padding(.horizontal, 8)
        .padding(.bottom, -6)
        .padding(.top, -6)
    }
}
