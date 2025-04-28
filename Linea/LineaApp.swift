//
//  LineaApp.swift
//  Linea
//

import SwiftUI
import GoogleSignIn

@main
struct LineaApp: App {
    @State var taskViewModel = TaskViewModel()
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoggedIn {
                    HomeScreenView()
                        .environment(taskViewModel)
                } else {
                    LoginView()
                        .environment(taskViewModel)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}

