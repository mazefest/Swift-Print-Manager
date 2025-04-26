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
            
            controlBarView
            
            Divider()
            
            if let _ = viewModel.rootDir {
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            SelectionControlView { action in
                                switch action {
                                case .all: viewModel.selectAll()
                                case .commented: viewModel.selectAllCommented()
                                case .uncommented: viewModel.selectAllUnCommented()
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
                                case .comment: viewModel.applyModificationToSelectedItems(.comment)
                                case .uncomment: viewModel.applyModificationToSelectedItems(.uncomment)
                                case .delete: viewModel.applyModificationToSelectedItems(.delete)
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
                PrintItemSelectionList(items: $viewModel.printItemSectionViewModels)

                // Selected Files
                PrintItemSelectionList(items: $viewModel.selectedPrintItemSectionViewModels)
            }
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400.0, minHeight: 400.0)
    }
    
    private var controlBarView: some View {
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
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        panel.begin { response in
            if response == .OK {
                if let url = panel.url, url.startAccessingSecurityScopedResource() {
                    print("Started security scoped access on directory: \(url.path)")
                    viewModel.onDirectorySelection(url)
                    completion(url)
                } else {
                    print("Failed to start security scoped access on selected directory.")
                    completion(nil)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
