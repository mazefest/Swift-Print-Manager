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
                        PrintItemRowItem(
                            isSelected: $selections.contains(file: file, printItem: printItem),
                            printItem: printItem
                        ) { action in
                            switch action {
                            case .deSelected: deSelected(file: file, printItem: printItem)
                            case .selected: selected(file: file, printItem: printItem)
                            }
                        }
                        .padding(.leading)
                        
                    }
                } header: {
                    HStack {
                        CheckBox(isChecked: $selections.contains(file: file, allItems: items))
                        
                        Image(systemName: "swift")
                            .foregroundStyle(Color.orange)
                        
                        Text(file.lastPathComponent)
                        Spacer()
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

// Row Item
extension PrintItemSelectionList {
    struct PrintItemRowItem: View {
        @Binding var isSelected: Bool
        var printItem: PrintItem
        var selectionAction: ((SelectionAction) -> Void)
        
        var body: some View {
            HStack {
                CheckBox(isChecked: $isSelected)

                Text("\(printItem.lineNumber):")
                    .font(.caption)
                    .foregroundStyle(Color.gray)
                
                Text(printItem.text.trimmingCharacters(in: .whitespaces))
                    .foregroundStyle(printItem.commented ? Color.gray : Color.white)
                
                Spacer()
                
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selectionAction(isSelected ? .deSelected : .selected)
            }
            
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
                print("new value: \(newValue)")
                if newValue {
                    self.wrappedValue[file] = allItems[file]
                } else {
                    self.wrappedValue.removeValue(forKey: file)
                }
            }
        )
    }
}

