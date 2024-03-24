//
//  Item.swift
//  ChattyChat
//
//  Created by Stef Kors on 24/03/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    var message: String

    init(timestamp: Date, message: String) {
        self.timestamp = timestamp
        self.message = message
    }
}
