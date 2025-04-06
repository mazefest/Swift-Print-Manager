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
        HStack {
            ForEach(items) { item in
                button(for: item)
            }
        }
    }
    
    private func button(for action: PrintAction) -> some View {
        Text(action.title)
            .button {
                self.onAction(action)
            }
    }
}
