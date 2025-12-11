//
//  SelectionControlView.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct SelectionControlView: View {
    @Binding var allSelected: Bool
    @Binding var allCommentedSelected: Bool
    @Binding var allUnCommentedSelected: Bool
    
    var onAction: (Action) -> Void
    
    var actionItems: [Action] = Action.allCases

    var body: some View {
        HStack(spacing: 8) {
            ForEach(actionItems) { item in
                button(for: item)
                if item != actionItems.last {
                    Divider()
                        .frame(height: 14.0)
                }
            }
        }
    }
    
    private func button(for action: Action) -> some View {
        Button {
            onAction(action)
        } label: {
            HStack(spacing: 6) {
                switch action {
                case .all:
                    CheckBox(isChecked: Binding(
                        get: { allSelected },
                        set: { _ in onAction(action) }
                    ))
                case .commented:
                    CheckBox(isChecked: Binding(
                        get: { allCommentedSelected },
                        set: { _ in onAction(action) }
                    ))
                case .uncommented:
                    CheckBox(isChecked: Binding(
                        get: { allUnCommentedSelected },
                        set: { _ in onAction(action) }
                    ))
                }
                
                Text(action.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(nsColor: .labelColor))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension SelectionControlView {
    enum Action: CaseIterable, Identifiable {
        var id: Self { self }
        case all
        case commented
        case uncommented
        
        var title: String {
            switch self {
            case .all: "All"
            case .commented: "Commented"
            case .uncommented: "Uncommented"
            }
        }
    }
    
}
