//
//  Task.swift
//  Linea
//

import Foundation
import SwiftUI

struct Task: Identifiable, Equatable {
    let id: UUID
    var group: String
    var title: String
    var start: Date
    var end: Date
}


