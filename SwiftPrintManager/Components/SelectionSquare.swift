//
//  SelectionSquare.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct SelectionSquare: View {
    var isSelected: Bool
    
    var selectionAction: (SelectionAction) -> ()

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
            .button(.deSelected, onTap: selectionAction)
            .buttonStyle(PlainButtonStyle())
    }
    
    private func notSelectedView() -> some View {
        Image(systemName: "square")
            .foregroundStyle(Color.gray)
            .bold()
            .button(.selected, onTap: selectionAction)
            .buttonStyle(PlainButtonStyle())
    }
}

struct SelectionSquareContent: View {
    var isSelected: Bool
    
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
    }
    
    private func notSelectedView() -> some View {
        Image(systemName: "square")
            .foregroundStyle(Color.gray)
            .bold()
    }
}
