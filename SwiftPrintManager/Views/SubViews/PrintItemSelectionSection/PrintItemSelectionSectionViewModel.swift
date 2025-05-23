//
//  PrintItemSelectionSectionViewModel.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/23/25.
//

import SwiftUI

class PrintItemSelectionSectionViewModel: ObservableObject {
    let identifier: String
    let file: URL
    
    @Published var items: [PrintItem]
    
    @Published var isExpanded: Bool = true
    @Published var allSelected: Bool = false
    
    var allCommentedSelected: Bool? {
        let commentedItems = items.filter(\.commented)
        guard !commentedItems.isEmpty else { return nil }
        return commentedItems.allSatisfy(\.isSelected)
    }
    
    var allUnCommentedSelected: Bool? {
        let uncommentedItems = items.filter { !$0.commented }
        guard !uncommentedItems.isEmpty else { return nil }
        return uncommentedItems.allSatisfy(\.isSelected)
    }
    
    var delegate: [PrintItemSelectionSectionViewModelDelegate] = []
    
    init(identifier: String, file: URL, items: [PrintItem]) {
        self.identifier = identifier
        self.file = file
        self.items = items
        
        items.forEach { printItem in
            printItem.addListener(self)
        }
        
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func selectAllPrintItems() {
        items.forEach { printItem in
            printItem.setIsSelected(true)
        }
        allSelected = true
    }
    
    func deSelectAllPrintItems() {
        items.forEach { printItem in
            printItem.setIsSelected(false)
        }
        allSelected = false
    }
    
    func selectAllCommentedPrintItems() {
        let commentedItems = items.filter(\.commented)
        guard !commentedItems.isEmpty else { return }
        commentedItems.forEach { $0.setIsSelected(true) }
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func deSelectAllCommentedPrintItems() {
        let commentedItems = items.filter(\.commented)
        guard !commentedItems.isEmpty else { return }
        commentedItems.forEach { $0.setIsSelected(false) }
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func selectAllUnCommentedPrintItems() {
        let uncommentedItems = items.filter { !$0.commented }
        guard !uncommentedItems.isEmpty else { return }
        uncommentedItems.forEach { $0.setIsSelected(true) }
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func deSelectAllUnCommentedPrintItems() {
        let uncommentedItems = items.filter { !$0.commented }
        guard !uncommentedItems.isEmpty else { return }
        uncommentedItems.forEach { $0.setIsSelected(false) }
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func addPrintItem(_ printItem: PrintItem) {
        guard !items.contains(printItem) else { return }
        printItem.addListener(self)
        self.items.append(printItem)
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func removePrintItem(_ printItem: PrintItem) {
        guard let index = items.firstIndex(of: printItem) else { return }
        items.remove(at: index)
        self.allSelected = items.allSatisfy(\.isSelected)
    }
    
    func addListener(_ listener: PrintItemSelectionSectionViewModelDelegate) {
        delegate.append(listener)
    }
    
    func removeListener(_ listener: PrintItemSelectionSectionViewModelDelegate) {
        delegate.removeAll(where: { ObjectIdentifier($0 as AnyObject) == ObjectIdentifier(listener as AnyObject) })
    }
    
    func notifyListenersPrintItemSelectionChanged(file: URL, printItem: PrintItem) {
        delegate.forEach {
            $0.printItemSelectionViewModelPrintItemSelectionDidChange(self, file: file, printItem: printItem)
        }
    }
    
    func collapseAll() {
        self.isExpanded = false
    }
    
    func expandAll() {
        self.isExpanded = true
    }
}

extension PrintItemSelectionSectionViewModel: PrintItemDelegate {
    func printItemSelectionChanged(_ printItem: PrintItem, isSelected: Bool) {
        print("\(self.identifier): print item changed")
        self.allSelected = items.allSatisfy(\.isSelected)
        self.notifyListenersPrintItemSelectionChanged(file: file, printItem: printItem)
    }
}

protocol PrintItemSelectionSectionViewModelDelegate {
    func printItemSelectionViewModelPrintItemSelectionDidChange(_ viewModel: PrintItemSelectionSectionViewModel, file: URL, printItem: PrintItem)
}
