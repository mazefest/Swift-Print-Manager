//
//  ContentView.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/2/25.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject var viewModel: AppViewModel = .init()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    selectDirectory { dir in
                        guard let dir else { return }
                        viewModel.onDirectorySelection(dir)
                    }
                } label: {
                    Text("Add Project")
                }
                
                Spacer()
                
                if let _ = viewModel.rootDir {
                    HStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .button {
                                viewModel.refreshFiles()
                            }
                            .buttonStyle(PlainButtonStyle())
                        VStack {
                            Text("\(viewModel.rootDir?.lastPathComponent ?? "-")")
                            Text("\(viewModel.rootDir?.description ?? "-")")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                            
                        }
                    }
                }
                Spacer()
            }
            
            Divider()
            
            if let _ = viewModel.rootDir {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            SelectionControlView { action in
                                switch action {
                                case .all: viewModel.selectAll()
                                case .commented: viewModel.selectAll(commented: true)
                                case .uncommented: viewModel.selectAll(commented: false)
                                }
                            }
                            
                            Spacer()
                            
                            if viewModel.selections.count > 0 {
                                Text("\(self.viewModel.selections.flatMap(\.value).count) Selected Prints")
                                    .foregroundStyle(Color.gray)
                                    .font(.caption)
                            }
                            
                            PrintControlView { action in
                                switch action {
                                case .comment: viewModel.commentSelectedItems()
                                case .uncomment: viewModel.unCommentSelectedItems()
                                case .delete: viewModel.deleteSelectedItems()
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.vertical, 1)
                .padding(.bottom, 4)
            }
            HStack {
                // All Files
                PrintItemSelectionList(
                    items: $viewModel.selectedFiles,
                    selections: $viewModel.selections
                )
                
                // Selected Files
                PrintItemSelectionList(
                    items: $viewModel.selections,
                    selections: $viewModel.selections
                )
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400.0, minHeight: 400.0)
    }
    
    private func selectFiles(completion: @escaping ([URL]) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.plainText, .swiftSource]
        
        panel.begin { response in
            if response == .OK {
                completion(panel.urls)
            }
        }
    }
    
    private func selectDirectory(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowedContentTypes = [.plainText, .swiftSource]
        
        panel.begin { response in
            if response == .OK {
                completion(panel.url)
            }
        }
    }
}

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
    
    func commentSelectedItems() {
        selections.forEach { key, prints in
            prints.forEach { printItem in
                commentOutPrint(printItem.text, in: key)
            }
            
            probeFile(key)
        }
        self.selections = [:]
    }
    
    func unCommentSelectedItems() {
        
    }
    
    func deleteSelectedItems() {
        
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
    
    private func commentOutPrint(_ printLine: String, in file: URL) {
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
        for i in 0..<lines.count {
            if lines[i].trimmingCharacters(in: .whitespaces) == printLine.trimmingCharacters(in: .whitespaces) {
                lines[i] = "// " + lines[i]
                break
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

#Preview {
    ContentView()
}
