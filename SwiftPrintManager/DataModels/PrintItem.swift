//
//  PrintItem.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

protocol PrintItemDelegate {
    func printItemSelectionChanged(_ printItem: PrintItem, isSelected: Bool)
}

class PrintItem: ObservableObject, Identifiable {
    var id: UUID
    var text: String
    var lineNumber: Int
    @Published var isSelected: Bool
    
    var delegate: [PrintItemDelegate] = []
    
    var commented: Bool {
        text.contains("//")
    }
    
    init(id: UUID = UUID(), text: String, lineNumber: Int, isSelected: Bool = false) {
        self.id = id
        self.text = text
        self.lineNumber = lineNumber
        self.isSelected = isSelected
    }
    
    func setIsSelected(_ isSelected: Bool) {
        self.isSelected = isSelected
        notifyPrintItemSelectedChanged(isSelected: isSelected)
    }
    
    func addListener(_ listener: PrintItemDelegate) {
        delegate.append(listener)
    }
    
    func removeListener(_ listener: PrintItemDelegate) {
        delegate.removeAll { ObjectIdentifier($0 as AnyObject) == ObjectIdentifier(listener as AnyObject) }
    }
    
    func notifyPrintItemSelectedChanged(isSelected: Bool) {
        delegate.forEach {
            $0.printItemSelectionChanged(self, isSelected: isSelected)
        }
    }
}
    
extension PrintItem: Equatable {
    static func == (lhs: PrintItem, rhs: PrintItem) -> Bool {
        lhs.text == rhs.text && lhs.lineNumber == rhs.lineNumber
    }
}

extension PrintItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(lineNumber)
    }
}
