//
//  PrintItemSelectionSquare.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct PrintItemSelectionSquare: View {
    var items: [URL: [PrintItem]]
    var file: URL
    var printItem: PrintItem
    
    var onAction: (SelectionSquare.Action) -> ()
    
    var body: some View {
        SelectionSquare(
            isSelected: items.contains(file: file, printItem: printItem),
            onAction: onAction
        )
    }
}
