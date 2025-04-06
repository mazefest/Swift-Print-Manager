//
//  CheckBox.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

struct CheckBox: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Toggle(isOn: $isChecked) {
            EmptyView()
        }
        .toggleStyle(.checkbox)
        .labelsHidden()
    }
}
