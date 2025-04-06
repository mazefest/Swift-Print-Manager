//
//  SelectionSquare.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct SelectionSquare: View {
    var isSelected: Bool
    
    var onAction: (Action) -> ()
    
    enum Action {
        case deSelected
        case selected
    }
    
    var body: some View {
        if isSelected {
            selectedView()
        } else {
            notSelectedView()
        }
    }
    
    private func selectedView() -> some View {
        Image(systemName: "checkmark.square")
            .foregroundStyle(Color.blue, Color.gray)
            .bold()
            .button {
                onAction(.deSelected)
            }
            .buttonStyle(PlainButtonStyle())
    }
    
    private func notSelectedView() -> some View {
        Image(systemName: "square")
            .foregroundStyle(Color.gray)
            .bold()
            .button {
                onAction(.selected)
            }
            .buttonStyle(PlainButtonStyle())
    }
}
