//
//  PrintItemSelectionSection.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

struct PrintItemSelectionSection: View {
    var file: URL
    @Binding var items: [URL: [PrintItem]]
    @Binding var selections: [URL: [PrintItem]]
    
    @State var isExpanded = true
    
    var selectionAction: (SelectionAction, PrintItem) -> Void
    
    var body: some View {
        Section {
            CollapsibleSectionView(isExpanded: $isExpanded) {
                
                ForEach(items[file] ?? []) { printItem in
                    PrintItemRowItem(
                        isSelected: $selections.contains(file: file, printItem: printItem),
                        printItem: printItem
                    ) { action in
                        self.selectionAction(action, printItem)
                    }
                    .padding(.leading)
                }
            }
        } header: {
            HStack {
                CheckBox(isChecked: $selections.contains(file: file, allItems: items))
                
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .contentShape(Rectangle())
                    .bold()
                    .button {
                        isExpanded.toggle()
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .animation(.linear, value: isExpanded)
                
                Image(systemName: "swift")
                    .foregroundStyle(Color.orange)
                
                Text(file.lastPathComponent)
                Spacer()
            }
        }
    }
}
