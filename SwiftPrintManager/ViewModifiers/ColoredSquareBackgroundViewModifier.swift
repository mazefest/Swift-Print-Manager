//
//  ColoredSquareBackgroundViewModifier.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct SquareBackgroundViewModifier: ViewModifier {
    var color: Color
    var cornerRadius: Double
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .foregroundStyle(color)
            }
    }
}

extension View {
    func coloredSquareBackground(color: Color, cornerRadius: Double = 5.0) -> some View {
        self.modifier(SquareBackgroundViewModifier(color: color, cornerRadius: cornerRadius))
    }
}
