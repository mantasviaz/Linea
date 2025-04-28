//
//  DateHeader.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//
import SwiftUI
import Foundation

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
