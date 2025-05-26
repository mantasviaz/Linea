//
//  Import.swift
//  Linea
//
//  Created by Mantas Viazmitinas on 5/25/25.
//

import Foundation
import SwiftUI
import SwiftData
import UIKit

struct Import: Codable {
    let assignment_name: String
    let start_date: String   // “MM/DD”
    let due_date: String   // “MM/DD”
    let start_time: String   // “h:mmA”
    let due_time: String   // “h:mmA”
}

