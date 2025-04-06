//
//  CollapsibleSectionView.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

struct CollapsibleSectionView<Content: View>: View {
    @Binding var isExpanded: Bool
    
    var content: () -> Content
    
    var body: some View {
        if isExpanded {
            content()
        }
    }
}
