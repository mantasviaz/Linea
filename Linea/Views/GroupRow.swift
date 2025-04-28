//
//  GroupRow.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI
import Foundation

struct GroupRow: View {
    @Environment(TaskViewModel.self) private var vm
    @State private var originalName: String
    @State private var name: String
    var color: Color
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
