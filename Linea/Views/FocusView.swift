//
//  FocusView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI
import Foundation

struct FocusView: View {
    @Environment(TaskViewModel.self) private var taskViewModel
    var onTap: (LineaTask) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Focus")
                .font(.system(size: 21).weight(.bold))
                .padding(.top, -10)
            let now = Date()
            ForEach(taskViewModel.tasks.filter { $0.end >= now && $0.completed == false}) { task in
                FocusRow(task: Binding(
                    get: {
                        taskViewModel.tasks.first(where: { $0.id == task.id }) ?? task
                    },
                    set: { taskViewModel.update($0) }
                ))
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
