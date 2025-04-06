//
//  PrintItemSelectionList.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct PrintItemSelectionList: View {
    @Binding var items: [URL: [PrintItem]]
    @Binding var selections: [URL: [PrintItem]]
    
    var body: some View {
        List {
            ForEach(Array(items.keys.sorted(by: {$0.lastPathComponent < $1.lastPathComponent})), id: \.self) { file in
                
                PrintItemSelectionSection(file: file, items: $items, selections: $selections) { action, printItem in
                    switch action {
                    case .deSelected: deSelected(file: file, printItem: printItem)
                    case .selected: selected(file: file, printItem: printItem)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func deSelected(file: URL, printItem: PrintItem? = nil) {
        if let printItem {
            selections[file]?.removeAll { $0 == printItem }
            if selections[file]?.count == 0 {
                selections.removeValue(forKey: file)
            }
        } else {
            selections.removeValue(forKey: file)
        }
        
    }
    
    private func selected(file: URL, printItem: PrintItem? = nil) {
        if let printItem {
            selections[file, default: []].append(printItem)
        } else {
            selections[file] = items[file]
        }
    }
}

extension Binding where Value == [URL: [PrintItem]] {
    func contains(file: URL, printItem: PrintItem) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                self.wrappedValue[file, default: []].contains(printItem)
            },
            set: { newValue in
                if newValue {
                    if !self.wrappedValue[file, default: []].contains(printItem) {
                        self.wrappedValue[file, default: []].append(printItem)
                    }
                } else {
                    self.wrappedValue[file]?.removeAll { $0 == printItem }
                    if self.wrappedValue[file]?.isEmpty == true {
                        self.wrappedValue.removeValue(forKey: file)
                    }
                }
            }
        )
    }
    
    func contains(file: URL, allItems: [URL: [PrintItem]]) -> Binding<Bool> {
        Binding<Bool>(
            get: {
                self.wrappedValue.contains(file: file)
            },
            set: { newValue in
                if newValue {
                    self.wrappedValue[file] = allItems[file]
                } else {
                    self.wrappedValue.removeValue(forKey: file)
                }
            }
        )
    }
}
