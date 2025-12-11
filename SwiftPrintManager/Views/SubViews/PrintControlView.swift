//
//  PrintControlView.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct PrintControlView: View {
    var onAction: (PrintAction) -> Void
    
    var items: [PrintAction] = PrintAction.allCases
    
    enum PrintAction: CaseIterable, Identifiable {
        var id: Self { self }
        case comment
        case uncomment
        case delete
        
        var title: String {
            switch self {
            case .comment: "Comment"
            case .uncomment: "Uncomment"
            case .delete: "Delete"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                button(for: item)
            }
        }
    }
    
    private func button(for action: PrintAction) -> some View {
        Button {
            self.onAction(action)
        } label: {
            Text(action.title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(nsColor: .labelColor))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(nsColor: .controlAccentColor).opacity(0.1))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(Color(nsColor: .controlAccentColor).opacity(0.3), lineWidth: 1)
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension PrintControlView.PrintAction {
    var fileModificationAction: FileModificationAction {
        switch self {
        case .comment: .comment
        case .uncomment: .uncomment
        case .delete: .delete
        }
    }
}
