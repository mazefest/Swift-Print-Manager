//
//  AppViewModel.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var rootDir: URL?
    
    @Published var allSelected: Bool = false
    @Published var allCommenetedSelected: Bool = false
    @Published var allUncommentedSelected: Bool = false
    
    @Published var printItemSectionViewModels: PrintItemSelectionSectionViewModelDictionary
    @Published var selectedPrintItemSectionViewModels: PrintItemSelectionSectionViewModelDictionary = [:]
    
    init(rootDir: URL? = nil,
         selectedFiles: [URL : [PrintItem]] = [:],
         selections: [URL : [PrintItem]] = [:]
    ) {
        self.rootDir = rootDir
        self.printItemSectionViewModels = [:]
        self.selectedPrintItemSectionViewModels = [:]
    }
    
    func onDirectorySelection(_ dir: URL) {
        rootDir = dir
        printItemSectionViewModels = [:]
        selectedPrintItemSectionViewModels = [:]
        
        probeDir(dir)
    }
    
    func refreshFiles() {
        guard let rootDir else { return }
        probeDir(rootDir)
    }
    
    func selectAll() {
        if printItemSectionViewModels.allSelected() {
            printItemSectionViewModels.deselectAllPrintItems()
        } else {
            printItemSectionViewModels.selectAllPrintItems()
        }
    }
    
    func selectAllUnCommented() {
        if printItemSectionViewModels.allUnCommentedSelected() {
            printItemSectionViewModels.deselectAllUnCommentedPrintItems()
        } else {
            printItemSectionViewModels.selectAllUnCommentedPrintItems()
        }
    }
    
    func selectAllCommented() {
        if printItemSectionViewModels.allCommentedSelected() {
            printItemSectionViewModels.deselectAllCommentedPrintItems()
        } else {
            printItemSectionViewModels.selectAllCommentedPrintItems()
        }
    }
    
    func applyModificationToSelectedItems(_ action: FileModificationAction) {
        selectedPrintItemSectionViewModels.forEach { file, viewModel in
            viewModel.items.forEach { printItem in
                modifyPrint(printItem.text, in: file, action: action)
            }
            probeFile(file)
        }
        selectedPrintItemSectionViewModels = [:]
        self.clearSelectionsToggles()
    }
    
    func clearSelectionsToggles() {
        self.allSelected = false
        self.allCommenetedSelected = false
        self.allUncommentedSelected = false
    }
    
    // MARK: private funcs
    func probeDir(_ dir: URL) {
        let urls = getAllFileURLs(in: dir)
        urls.forEach { url in
            probeFile(url)
        }
    }
    
    func probeFile(_ file: URL) {
        let prints = extractPrintStatements(from: file)
        if prints.count > 0 {
            printItemSectionViewModels[file] = .init(identifier: "master", file: file, items: prints)
            printItemSectionViewModels[file]?.addListener(self)
        } else {
            printItemSectionViewModels.removeValue(forKey: file)
        }
    }

    func getAllFileURLs(in directory: URL) -> [URL] {
        var allURLs: [URL] = []
        
        let fileManager = FileManager.default
        if let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) {
            for case let fileURL as URL in enumerator {
                allURLs.append(fileURL)
            }
        }
        
        return allURLs
    }
    
    private func extractPrintStatements(from file: URL) -> [PrintItem] {
        guard let contents = try? String(contentsOf: file) else { return [] }
        
        let lines = contents.components(separatedBy: .newlines)
        
        return lines.enumerated().compactMap { offset, item in
            if item.replacingOccurrences(of: "\\s", with: "", options: .regularExpression).hasPrefix("print(") {
                return .init(text: item, lineNumber: offset + 1)
            }
            
            if item.replacingOccurrences(of: "\\s", with: "", options: .regularExpression).hasPrefix("//print(") {
                return .init(text: item, lineNumber: offset + 1)
            }
            return nil
        }
    }
    
    private func modifyPrint(_ printLine: String, in file: URL, action: FileModificationAction) {
        guard file.startAccessingSecurityScopedResource() else {
            print("Failed to start security scoped access")
            return
        }
        defer { file.stopAccessingSecurityScopedResource() }
        
        guard let contents = try? String(contentsOf: file, encoding: .utf8) else {
            return
        }
        
        var lines = contents.components(separatedBy: .newlines)
        var readerLines = lines
        
        for i in 0..<readerLines.count {
            let fileLine = readerLines[i].trimmingCharacters(in: .whitespaces)
            let searchLine = printLine.trimmingCharacters(in: .whitespaces)
            
            if fileLine == searchLine {
                switch action {
                case .comment:
                    lines[i] = "// " + lines[i]
                case .uncomment:
                    lines[i] = lines[i].replacingOccurrences(of: "// ", with: "")
                case .delete:
                    // big issue here because what if ther were 2 that looked the same.
                    if let index = lines.firstIndex(where: {$0.trimmingCharacters(in: .whitespaces) == searchLine}) {
                        lines.remove(at: index)
                    }
                }
                
            }
        }
        
        let updatedContents = lines.joined(separator: "\n")
        
        do {
            try updatedContents.write(to: file, atomically: true, encoding: .utf8)
        } catch {
// //             print("Write failed: \(error.localizedDescription)")
        }
    }
    
    private func writePrintsToSwiftFile(_ prints: [String], at path: URL) {
        let header = "// This file is auto-generated.\n\nimport Foundation\n\nfunc debugPrintReport() {\n"
        let footer = "\n}\n"
        let body = prints.map { "    \($0)" }.joined(separator: "\n")
        
        let fileContent = header + body + footer
        
        try? FileManager.default.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? fileContent.write(to: path, atomically: true, encoding: .utf8)
    }
}

extension AppViewModel: PrintItemSelectionSectionViewModelDelegate {
    func printItemSelectionViewModelPrintItemSelectionDidChange(_ viewModel: PrintItemSelectionSectionViewModel, file: URL, printItem: PrintItem) {
        self.allSelected = printItemSectionViewModels.allSelected()
        self.allCommenetedSelected = printItemSectionViewModels.allCommentedSelected()
        self.allUncommentedSelected = printItemSectionViewModels.allUnCommentedSelected()
        
        if printItem.isSelected {
            if selectedPrintItemSectionViewModels[file] != nil {
                let printItem = printItem
                selectedPrintItemSectionViewModels[file]!.addPrintItem(printItem)
            } else {
                selectedPrintItemSectionViewModels[file] = .init(identifier: "selection", file: file, items: [printItem])
                selectedPrintItemSectionViewModels[file]!.addListener(self)
            }
        } else {
            selectedPrintItemSectionViewModels[file]?.removePrintItem(printItem)
            
            // Remove file if empty
            if selectedPrintItemSectionViewModels[file]?.items.isEmpty ?? false {
                selectedPrintItemSectionViewModels.removeValue(forKey: file)
            }
        }
    }
}
