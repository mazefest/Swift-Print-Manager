//
//  PrintItemRowItem.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

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
