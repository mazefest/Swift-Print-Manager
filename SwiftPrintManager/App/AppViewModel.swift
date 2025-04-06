//
//  AppViewModel.swift
//  SwiftPrintManager
//
//  Created by Colby Mehmen on 4/6/25.
//

import SwiftUI

class AppViewModel: ObservableObject {
    @Published var rootDir: URL?
    @Published var selectedFiles: [URL: [PrintItem]] = [:]
    @Published var selections: [URL: [PrintItem]] = [:]
    
    init(rootDir: URL? = nil, selectedFiles: [URL : [PrintItem]] = [:], selections: [URL : [PrintItem]] = [:]) {
        self.rootDir = rootDir
        self.selectedFiles = selectedFiles
        self.selections = selections
    }
    
    func onDirectorySelection(_ dir: URL) {
        rootDir = dir
        probeDir(dir)
    }
    
    func refreshFiles() {
        guard let rootDir else { return }
        probeDir(rootDir)
    }
    
    func selectAll() {
        if selectedFiles == selections {
            selections = [:]
        } else {
            selections = selectedFiles
        }
    }
    
    func selectAll(commented: Bool) {
        let items = selectedFiles.filter(commented: commented)
        if self.selections.contains(items) {
            self.selections = selections.remove(items)
        } else {
            self.selections = selections.combine(items)
        }
    }
    
    func applyModificationToSelectedItems(_ action: FileModificationAction) {
        selections.forEach { url, prints in
            prints.forEach { printItem in
                modifyPrint(printItem.text, in: url, action: action)
            }
            
            probeFile(url)
        }
        self.selections = [:]
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
            selectedFiles[file] = prints
        } else {
            selectedFiles.removeValue(forKey: file)
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
            print("Could not read file")
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
            print("File successfully written")
        } catch {
            print("Write failed: \(error.localizedDescription)")
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
