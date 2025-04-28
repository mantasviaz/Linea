//
//  ColorSelectView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI
import Foundation

struct ColorSelectView: View {
    @Binding var showColorPicker: Bool
    @Binding var selectedGroupKey: String
    @Binding var tempColor: Color
    @Binding var origColor: Color
    @Environment(TaskViewModel.self) private var taskViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack{
                Button(action: {
                    withAnimation(.interactiveSpring) {showColorPicker.toggle()}
                }) {
                    Text("Cancel")
                        .font(.system(size: 17))
                        .padding(.leading, -11)
                        .padding(.top, 15)
                }
                
                Spacer()
                
                Button("Done") {
                    withAnimation(.interactiveSpring) {showColorPicker.toggle()}
                }
                .font(.system(size: 17).weight(.bold))
                .padding(.trailing, -11)
                .padding(.top, 15)
                .disabled(tempColor == origColor)
            }

            HStack {
                Text("Preset Colors")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                
                ForEach(Array(taskViewModel.colors.values), id: \.self) { color in
                    Rectangle()
                        .fill(color)
                        .frame(width: 24, height: 24)
                        .cornerRadius(4)
                        .onTapGesture {
                            tempColor = color
                            taskViewModel.updateGroupColor(name: selectedGroupKey,
                                                           color: color)
                            showColorPicker = false
                        }
                        .padding(.trailing, 5)

                    
                }
            }
            ColorPicker(selection: $tempColor, supportsOpacity: false) {
                Text("Custom Color")
                    .font(.system(size: 17, weight: .semibold))
            }
                .onChange(of: tempColor) { newcolor in
                    taskViewModel.updateGroupColor(name: selectedGroupKey,
                                                   color: newcolor)
                }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 11)
    }
}
