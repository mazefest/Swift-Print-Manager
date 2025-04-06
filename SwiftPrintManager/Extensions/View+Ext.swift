//
//  View+Ext.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import Foundation
import SwiftUI

extension View {
    func styledFont(size: Double = 17.0) -> some View {
        self.font(.system(size: size, weight: .semibold, design: .rounded))
    }
}
