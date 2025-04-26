//
//  FooterBarView.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/26/25.
//

import SwiftUI

struct FooterBarView: View {
    var onAction: (Action) -> Void
    enum Action {
        case collapseAll
        case expandAll
    }
    var body: some View {
        HStack {
            Text("Collapse All")
                .styledFont(size: 10)
                .foregroundStyle(Color.gray)
                .button {
                    onAction(.collapseAll)
                }
                .buttonStyle(PlainButtonStyle())
            Divider()
                .frame(height: 8.0)
            Text("Expand All")
                .styledFont(size: 10)
                .foregroundStyle(Color.gray)
                .button {
                    onAction(.expandAll)
                }
                .buttonStyle(PlainButtonStyle())
            Spacer()
        }
    }
}
