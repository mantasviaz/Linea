//
//  Untitled.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 4/27/25.
//

import SwiftUI
import Foundation

struct TabSettingsView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @Environment(TaskViewModel.self) var taskViewModel
    @Binding var selectedTab: Int
    @State var showDeleteConfirmation: Bool = false
    
    var body: some View {
        VStack(spacing: 40) {
            Button(action: {
                authViewModel.signOutFromGoogle()
                logoutAndResetApp()
            }) {
                Text("Log Out")
                    .foregroundStyle(.white)
                    .font(.system(size: 17).weight(.semibold))
                    .background {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 213, height: 45)
                            .background(Color(red: 0, green: 0.48, blue: 1))
                            .cornerRadius(14)
                    }
            }
            
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Text("Delete All Tasks")
                    .foregroundStyle(.white)
                    .font(.system(size: 17).weight(.semibold))
                    .background {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: 213, height: 45)
                            .background(Color.red)
                            .cornerRadius(14)
                    }
            }
        }
        .confirmationDialog("Are you sure you want to delete all tasks?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                withAnimation(.interactiveSpring) {
                    taskViewModel.deleteAllEvents()
                    showDeleteConfirmation = false
                    selectedTab = 0
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func logoutAndResetApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }

        window.rootViewController = UIHostingController(
            rootView: LoginView()
                .environment(TaskViewModel())
        )
        window.makeKeyAndVisible()
    }
}
