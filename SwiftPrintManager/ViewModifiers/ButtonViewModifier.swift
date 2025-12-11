//
//  ButtonViewModifier.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct ButtonViewModifier: ViewModifier {
    var onTap: () -> Void
    
    func body(content: Content) -> some View {
        Button {
            onTap()
        } label: {
            content
        }
    }
}

extension View {
    public func button(onTap: @escaping () -> Void) -> some View {
        self.modifier(ButtonViewModifier(onTap: onTap))
    }
    
    public func button<Item: Identifiable>(_ item: Item, onTap: @escaping (Item) -> ()) -> some View {
        self.modifier(ButtonViewModifier(onTap: {
            onTap(item)
        }))
    }
}
