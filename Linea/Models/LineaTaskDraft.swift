//
//  LineaTaskDraft.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 5/25/25.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit
struct LineaTaskDraft: Identifiable {
    let id = UUID()
    var title: String
    var start: Date        // combined date + CURRENT time
    var end: Date          // combined date + parsed time
    var group: String
}
