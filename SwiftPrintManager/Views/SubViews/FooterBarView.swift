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
        HStack(spacing: 8) {
            Button {
                onAction(.collapseAll)
            } label: {
                Text("Collapse All")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(nsColor: .secondaryLabelColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 12.0)
            
            Button {
                onAction(.expandAll)
            } label: {
                Text("Expand All")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(nsColor: .secondaryLabelColor))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
}
