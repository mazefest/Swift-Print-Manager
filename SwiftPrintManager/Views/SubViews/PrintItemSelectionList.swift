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
                Section {
                    ForEach(items[file] ?? []) { printItem in
                        HStack {
                            
                            PrintItemSelectionSquare(items: selections, file: file, printItem: printItem) { action in
                                switch action {
                                case .deSelected: deSelected(file: file, printItem: printItem)
                                case .selected: selected(file: file, printItem: printItem)
                                }
                            }

                            Text("\(printItem.lineNumber):")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                            Text(printItem.text.trimmingCharacters(in: .whitespaces))
                                .foregroundStyle(printItem.commented ? Color.gray : Color.white)
                            
                            Spacer()
                        }
                        .padding(.leading)
                    }
                } header: {
                    HStack {
                        FileSelectionSquare(items: selections, file: file) { action in
                            switch action {
                            case .deSelected: deSelected(file: file)
                            case .selected: selected(file: file)
                            }
                        }
                        
                        Text(file.lastPathComponent)
                        Spacer()
                    }
                }
            }
        }
    }
    
    private func deSelected(file: URL, printItem: PrintItem? = nil) {
        if let printItem {
            selections[file]?.removeAll { $0 == printItem }
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
