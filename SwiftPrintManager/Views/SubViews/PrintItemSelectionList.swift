//
//  PrintItemSelectionList.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct PrintItemSelectionList: View {
    @Binding var items: [URL: PrintItemSelectionSectionViewModel]
    
    var body: some View {
        List {
            ForEach(Array(items.keys.sorted(by: {$0.lastPathComponent < $1.lastPathComponent})), id: \.self) { file in
                PrintItemSelectionSection(viewModel: items[file]!)
            }
        }
        .listStyle(.plain)
    }
}
