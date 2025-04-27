//
//  LineaApp.swift
//  Linea
//

import SwiftUI
import GoogleSignIn

@main
struct LineaApp: App {
    @State var taskViewModel = TaskViewModel()

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(taskViewModel)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}


