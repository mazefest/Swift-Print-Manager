//
//  PrintItemSelectionSection.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

struct PrintItemSelectionSection: View {
    @ObservedObject var viewModel: PrintItemSelectionSectionViewModel
    
    var body: some View {
        Section {
            CollapsibleSectionView(isExpanded: $viewModel.isExpanded) {
                ForEach(Array(viewModel.items.enumerated()), id: \.1.id) { index, printItem in
                    HStack {
                        PrintItemRowItem(printItem: printItem)
                    }
                    .padding(.leading)
                }
            }
        } header: {
            HStack {
                // i want this check box to be highlighted when all items are selected. viewModel.allSelected is a computed property that
                // check if all items are selected. When all items are seleted in the set on line 31, it never update
                CheckBox(isChecked: Binding(
                    get: {
                        viewModel.allSelected
                    },
                    set: { newValue in
                        if newValue {
                            viewModel.selectAllPrintItems()
                        } else {
                            viewModel.deSelectAllPrintItems()
                        }
                    }
                ))
                
                Image(systemName: viewModel.isExpanded ? "chevron.down" : "chevron.right")
                    .contentShape(Rectangle())
                    .bold()
                    .button {
                        viewModel.isExpanded.toggle()
                    }
                    .buttonStyle(.plain)
                    .font(.caption)
                    .animation(.linear, value: viewModel.isExpanded)
                
                Image(systemName: "swift")
                    .foregroundStyle(Color.orange)
                
                Text(viewModel.file.lastPathComponent)
                Spacer()
            }
        }
    }
}
