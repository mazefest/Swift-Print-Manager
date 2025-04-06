//
//  PrintItem.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct PrintItem: Identifiable, Equatable {
    var id: UUID = UUID()
    var text: String
    var lineNumber: Int
    var commented: Bool {
        text.contains("//")
    }

    static func == (lhs: PrintItem, rhs: PrintItem) -> Bool {
        lhs.text == rhs.text && lhs.lineNumber == rhs.lineNumber
    }
}
