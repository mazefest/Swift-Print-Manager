//
//  Untitled.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/26/25.
//

import SwiftUI

typealias PrintItemSelectionSectionViewModelDictionary = [URL: PrintItemSelectionSectionViewModel]

extension PrintItemSelectionSectionViewModelDictionary {
    func allSelected() -> Bool {
        self.values.allSatisfy(\.allSelected)
    }
    
    func allCommentedSelected() -> Bool {
        let selections = self.values.compactMap { $0.allCommentedSelected }
        guard !selections.isEmpty else { return false }
        return selections.allSatisfy { $0 }
    }
    
    func allUnCommentedSelected() -> Bool {
        let selections = self.values.compactMap { $0.allUnCommentedSelected }
        guard !selections.isEmpty else { return false }
        return selections.allSatisfy { $0 }
    }
    
    func selectAllPrintItems() {
        self.values.forEach { $0.selectAllPrintItems() }
    }
    
    func deselectAllPrintItems() {
        self.values.forEach { $0.deSelectAllPrintItems() }
    }
    
    func selectAllCommentedPrintItems() {
        self.values.forEach { $0.selectAllCommentedPrintItems() }
    }
    
    func deselectAllCommentedPrintItems() {
        self.values.forEach { $0.deSelectAllCommentedPrintItems() }
    }
    
    func selectAllUnCommentedPrintItems() {
        self.values.forEach { $0.selectAllUnCommentedPrintItems() }
    }
    
    func deselectAllUnCommentedPrintItems() {
        self.values.forEach { $0.deSelectAllUnCommentedPrintItems() }
    }
    
    func collapseAll() {
        self.values.forEach { $0.collapseAll() }
    }
    
    func expandAll() {
        self.values.forEach { $0.expandAll() }
    }
}
