//
//  PrintItemRowItem.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

struct PrintItemRowItem: View {
    @ObservedObject var printItem: PrintItem
    
    var body: some View {
        HStack {
            CheckBox(isChecked: Binding(
                get: { printItem.isSelected },
                set: { newValue in printItem.setIsSelected(newValue) }
            ))
            
            Text("\(printItem.lineNumber):")
                .font(.caption)
                .foregroundStyle(Color.gray)
            
            Text(printItem.text.trimmingCharacters(in: .whitespaces))
                .foregroundStyle(printItem.commented ? Color.gray : Color.white)
            
            Spacer()
            
        }
        .contentShape(Rectangle())
    }
}
