//
//  LineaApp.swift
//  Linea
//

import SwiftUI

@main
struct LineaApp: App {
    @State var taskViewModel = TaskViewModel()

    var body: some Scene {
        WindowGroup {
            //TODO: Change
            HomeScreenView()
                .environment(taskViewModel)
        }
    }
}
