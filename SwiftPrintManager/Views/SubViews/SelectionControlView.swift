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
        HStack {
            ForEach(actionItems) { item in
                button(for: item)
                Divider()
                    .frame(height: 10.0)
            }
        }
    }
    
    private func button(for action: Action) -> some View {
        HStack {
            switch action {
            case .all:
                CheckBox(isChecked: Binding(
                    get: { allSelected },
                    set: { newValue in
                        onAction(action)
                    }
                ))
            case .commented:
                CheckBox(isChecked: Binding(
                    get: { allCommentedSelected },
                    set: { newValue in
                        onAction(action)
                    }
                ))
            case .uncommented:
                CheckBox(isChecked: Binding(
                    get: { allUnCommentedSelected },
                    set: { newValue in
                        onAction(action)
                    }
                ))
            }
            
            Text(action.title)
        }
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
