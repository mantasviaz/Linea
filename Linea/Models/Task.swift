//
//  Task.swift
//  Linea
//

import Foundation

struct Task: Identifiable {
    let id: UUID
    var group: String
    var title: String
    var start: Date
    var end: Date
}
