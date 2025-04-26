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
            //TODO: Change
            LoginView()
                .onOpenURL {
                    url in GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
