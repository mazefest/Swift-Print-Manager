//
//  SelectionControlView.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct SelectionControlView: View {
    var onAction: (Action) -> Void
    
    var items: [Action] = Action.allCases
    
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
    
    var body: some View {
        HStack {
            ForEach(items) { item in
                button(for: item)
            }
        }
    }
    
    private func button(for action: Action) -> some View {
        Text(action.title)
            .button {
                self.onAction(action)
            }
    }
}
