//
//  EditGroupView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/27/25.
//

import SwiftUI
import Foundation


struct EditGroupView: View {

    @Binding var showNewGroupSheet: Bool
    @Binding var showColorPicker: Bool
    @Binding var selectedGroupKey: String
    @Binding var tempColor: Color
    @Binding var origColor: Color
    

    @Environment(TaskViewModel.self) private var taskViewModel

    var body: some View {
        
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                    NotificationCenter.default.post(name: .commitGroupNames, object: nil)
                    withAnimation(.interactiveSpring) { showNewGroupSheet = false }
                }
                .font(.system(size: 17).weight(.bold))
                .padding(.trailing, -11)
            }
            .padding(.top, 15)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(Array(taskViewModel.groups).sorted(by: { $0.key < $1.key }), id: \.key) { key, color in
                        GroupRow(
                            name: key,
                            color: color,
                            oncolorTap: {
                                selectedGroupKey = key
                                tempColor = color
                                withAnimation(.interactiveSpring) {
                                    showColorPicker = true
                                }
                                origColor = color
                            },
                            onDelete: {
                                taskViewModel.deleteGroup(name: key)
                            }
                        )
                    }

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
            .onAppear {
                UIScrollView.appearance().bounces = true
            }
            .onDisappear {
                UIScrollView.appearance().bounces = false
            }

            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, 11)

    }
}
