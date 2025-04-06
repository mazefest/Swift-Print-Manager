//
//  BubbleLabelView.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct BubbleLabelView: View {
    var text: String
    var color: Color
    var style: BubbleLabelStyle = .text
    
    enum BubbleLabelStyle {
        case text
        case image(String)
    }
    
    init(text: String, color: Color, type: BubbleLabelStyle) {
        self.text = text
        self.color = color
        self.style = type
    }

    var body: some View {
        label()
            .coloredSquareBackground(color: color)
    }
    
    @ViewBuilder
    func label() -> some View {
        switch style {
        case .text:
            textLabel()
        case .image(let imageName):
            imageLabel(imageName: imageName)
        }
    }
    
    func textLabel() -> some View {
        Text(text)
            .lineLimit(1)
            .styledFont()
            .foregroundStyle(Color.white)
    }

    func imageLabel(imageName: String) -> some View {
        HStack {
            Image(systemName: imageName)
                .foregroundStyle(Color.white)
            Text(text)
                .lineLimit(1)
                .styledFont()
                .foregroundStyle(Color.white)
        }
    }
}
