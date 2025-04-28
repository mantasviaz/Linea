//
//  BottomSheetView.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/28/25.
//

import SwiftUI


struct BottomSheet<Content: View>: View {
    
    @Binding var isExpanded: Bool
    @Binding var translation: CGFloat
    let collapsedY: CGFloat
    let showHandle: Bool
    let content: Content

    init(isExpanded: Binding<Bool>, translation: Binding<CGFloat>, collapsedY: CGFloat, showHandle: Bool = true, @ViewBuilder content: () -> Content) {
        self._isExpanded = isExpanded
        self._translation = translation
        self.collapsedY = collapsedY
        self.showHandle = showHandle
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if showHandle {
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(height: 2)
                    .padding(.top, -2)

                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(Color.gray.opacity(0.7))
                    .padding(.top, 8)
                    .padding(.bottom, 8)
            }
            content
                .padding(.horizontal, 15)
                .padding(.bottom, 16)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}

