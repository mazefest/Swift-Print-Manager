//
//  FileSelectionSquare.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct FileSelectionSquare: View {
    var items: [URL: [PrintItem]]
    var file: URL
    
    var onAction: (SelectionSquare.Action) -> ()
    
    var body: some View {
        SelectionSquare(
            isSelected: items.contains(file: file),
            onAction: onAction
        )
    }
}
