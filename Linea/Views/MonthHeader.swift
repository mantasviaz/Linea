//
//  MonthHeader.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI
import Foundation

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
