//
//  HoverButtonViewModifer.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/28/25.
//

import SwiftUI

struct HoverButtonViewModifer: ViewModifier {
    @State private var isHovered = false
    
    var color: Color = .gray//Color(.darkGray)
    var onTap: () -> Void
    
    func body(content: Content) -> some View {
        Button {
            onTap()
        } label: {
            content
                .foregroundStyle(color)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundStyle(isHovered ? color.opacity(0.3) : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

extension View {
    func hoverButton(onTap: @escaping () -> Void) -> some View {
        modifier(HoverButtonViewModifer(onTap: onTap))
    }
}

#Preview(body: {
    VStack {
        Image(systemName: "plus")
            .hoverButton {
                
            }
    }
    .frame(width: 300.0, height: 300.0)
})
