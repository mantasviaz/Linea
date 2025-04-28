//
//  LineaTask.swift
//  Linea
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

@Model
final class LineaTask: ObservableObject, Identifiable, Equatable {
    @Attribute(.unique) var id: UUID
    var group: String
    var title: String
    var start: Date
    var end: Date
    var completed: Bool
    var isFromGoogle: Bool

    init(id: UUID = UUID(), group: String, title: String, start: Date, end: Date, completed: Bool, isFromGoogle: Bool = false) {
        self.id = id
        self.group = group
        self.title = title
        self.start = start
        self.end = end
        self.completed = completed
        self.isFromGoogle = isFromGoogle
    }

    static func == (lhs: LineaTask, rhs: LineaTask) -> Bool {
        lhs.id == rhs.id
    }
}

@Model
final class GroupColor: Identifiable {
    @Attribute(.unique) var name: String
    var red: Double
    var green: Double
    var blue: Double

    init(name: String, color: Color) {
        self.name = name
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: nil)
        self.red = Double(r)
        self.green = Double(g)
        self.blue = Double(b)
    }

    var swiftUIColor: Color {
        Color(red: red, green: green, blue: blue)
    }
}
