//
//  GroupBar.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/27/25.
//
import SwiftUI
import Foundation

struct GroupBar: View {
    
    var group: String
    var color: Color
    var selectedGroup: String?
    var onSelect: (String) -> Void

    var isSelected: Bool {
        selectedGroup == group
    }

    var body: some View {
        let verifiedColor = color.appropriateTextColor(darkTextColor: Color(red: 0.38, green: 0.38, blue: 0.39), lightTextColor: Color.white)
        let verifiedSelectedColor = color.appropriateTextColor(darkTextColor: Color.black, lightTextColor: Color.white)
        Text(group)
            .foregroundStyle(isSelected ? verifiedSelectedColor : verifiedColor)
            .font(.system(size: 17))
            .fontWeight(isSelected ? .bold : .regular)
            .padding(.horizontal, 12)
            .frame(minWidth: 80)
            .frame(height: 34)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .shadow(
                        color: isSelected ? Color.clear : Color.black.opacity(0.15),
                        radius: 2,
                        x: 0,
                        y: 2
                    )
            )
            .opacity(isSelected ? 1 : 0.7)
            .animation(.easeInOut(duration: 0.1), value: isSelected)
            .onTapGesture {
                onSelect(group)
            }
    }
}
