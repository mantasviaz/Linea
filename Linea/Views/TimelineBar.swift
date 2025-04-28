//
//  TimelineBar.swift
//  Linea
//
//
//

import SwiftUI
import Observation
import UIKit

struct TimelineBar: View {
    @Binding var task: LineaTask
    var dayWidth: CGFloat
    @Environment(TaskViewModel.self) var taskViewModel
    @State private var isDraggingStart = false
    @State private var textWidth: CGFloat = 0

    var body: some View {
        let startX = taskViewModel.xPosition(for: task.start, dayWidth: dayWidth)
        let width = taskViewModel.xPosition(for: task.end, dayWidth: dayWidth) - startX
        let group = task.group
        let color = task.completed ? Color(red: 0.96, green: 0.96, blue: 0.96) : taskViewModel.groups.first(where: { $0.key == group })?.value ?? Color(red: 0.87, green: 0.87, blue: 0.87)
        
        
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 2)
                .frame(width: width, height: 45)
            VStack(alignment: .leading) {
                Text(task.group.isEmpty ? task.title : "\(task.group) - \(task.title)")
                    .font(.system(size: 13).weight(.bold))
                    .lineLimit(1)
                    .foregroundStyle(textWidth > width - 10 ? .black : color.appropriateTextColor(darkTextColor: .black, lightTextColor: .white))
                Text(formattedTimelineDateRange(start: task.start, end: task.end))
                    .foregroundStyle(textWidth > width - 10 ? .black : color.appropriateTextColor(darkTextColor: .black, lightTextColor: .white))
                    .lineLimit(1)
            }
            .fixedSize()
            .background(GeometryReader { geo in
                Color.clear.preference(key: TextWidthKey.self, value: geo.size.width)
            })
            .onPreferenceChange(TextWidthKey.self) { widthValue in
                textWidth = widthValue
            }
            .offset(x: textWidth > width - 10 ? width + 8 : 12)
                
        }
        .offset(x: startX)
    }
}

private struct TextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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

func formattedTimelineDateRange(start: Date, end: Date) -> AttributedString {
    var result = AttributedString("")
    
    let calendar = Calendar.current
    let sameDay = calendar.isDate(start, inSameDayAs: end)
    
    let monthDayFormatter = DateFormatter()
    monthDayFormatter.dateFormat = "MMM d"
    
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "h:mm a"
    
    var startDate = AttributedString(monthDayFormatter.string(from: start) + " ")
    startDate.font = .system(size: 9, weight: .semibold)
    
    var arrow = AttributedString(" → ")
    arrow.font = .system(size: 9)
    
    var endDate = AttributedString(monthDayFormatter.string(from: end) + " ")
    endDate.font = .system(size: 9, weight: .semibold)
    
    var endTime = AttributedString(timeFormatter.string(from: end))
    endTime.font = .system(size: 9)
    
    result = startDate + arrow + endDate + endTime
    
    return result
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

func formattedBiggerDateRange(start: Date, end: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale.current
    
    let calendar = Calendar.current
    let sameDay = calendar.isDate(start, inSameDayAs: end)
    
    if sameDay {
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return "\(dateFormatter.string(from: start)) \n→ \(dateFormatter.string(from: end))"
    } else {
        let startFormatter = DateFormatter()
        startFormatter.dateFormat = "MMM d, h:mm a"
        
        let endFormatter = DateFormatter()
        endFormatter.dateFormat = "MMM d, h:mm a"
        
        return "\(startFormatter.string(from: start)) \n→ \(endFormatter.string(from: end))"
    }
}

//#Preview {
//    TimelineBar()
//}
