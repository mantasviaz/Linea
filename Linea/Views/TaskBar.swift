//
//  TaskBar.swift
//  Linea
//
//
//

import SwiftUI
import Observation
import UIKit

struct TaskBar: View {
    @Binding var task: Task
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var isDraggingStart = false

    var body: some View {
        let startX = taskViewModel.xPosition(for: task.start, dayWidth: dayWidth)
        let width = taskViewModel.xPosition(for: task.end, dayWidth: dayWidth) - startX
        let group = task.group
        let color = taskViewModel.groups.first(where: { $0.key == group })?.value ?? Color(red: 0.88, green: 0.88, blue: 0.88)
        
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
            VStack(alignment: .leading){
                Text(task.title)
                    .font(.system(size: 13).weight(.bold))
                    .lineLimit(1)
                    .foregroundStyle(color.appropriateTextColor(darkTextColor: .black, lightTextColor: .white))
                Text("\(formattedDateRange(start: task.start, end: task.end))")
                    .font(.system(size: 9))
                    .foregroundStyle(color.appropriateTextColor(darkTextColor: .black, lightTextColor: .white))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)

                
        }
        .frame(width: width, height: 45)
        .offset(x: startX)
    }
}

extension Color {
    func appropriateTextColor(darkTextColor: Color, lightTextColor: Color) -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        return luminance > 0.6 ? darkTextColor : lightTextColor
    }
}

func formattedDateRange(start: Date, end: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    
    let calendar = Calendar.current
    let sameDay = calendar.isDate(start, inSameDayAs: end)
    
    if sameDay {
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return "\(dateFormatter.string(from: start)) → \(dateFormatter.string(from: end))"
    } else {
        let startFormatter = DateFormatter()
        startFormatter.dateFormat = "MMM d, h:mm a"
        
        let endFormatter = DateFormatter()
        endFormatter.dateFormat = "MMM d, h:mm a"
        
        return "\(startFormatter.string(from: start)) → \(endFormatter.string(from: end))"
    }
}

//#Preview {
//    TaskBar()
//}
