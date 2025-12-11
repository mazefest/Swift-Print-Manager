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
        VStack(alignment: .leading, spacing: 0.0) {
            
            HStack {
                Spacer()
                RootDirectoryIndicatorView(
                    rootDir: $viewModel.rootDir,
                    onRefresh: {
                        viewModel.refreshFiles()
                    },
                    onSelectDirectory: {
                        self.selectDirectory { url in
                            self.viewModel.rootDir = url
                        }
                    }
                )
                Spacer()
            }
            .padding(.bottom)
            
            Divider()

            HStack(spacing: 0.0) {
                printItemSelectionView()
                
                
                Divider()
                
                printItemStagingView()
            }
            
            Spacer()
        }
        .padding([.horizontal, .bottom])
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
        panel.directoryURL = FileManager.default.homeDirectoryForCurrentUser
        
        panel.begin { response in
            if response == .OK {
                if let url = panel.url, url.startAccessingSecurityScopedResource() {
                    // //                     print("Started security scoped access on directory: \(url.path)")
                    viewModel.onDirectorySelection(url)
                    completion(url)
                } else {
                    print("Failed to start security scoped access on selected directory.")
                    completion(nil)
                }
            }
        }
    }
    
    private func printItemSelectionView() -> some View {
        VStack(spacing: 0.0) {
            HStack {
                SelectionControlView(
                    allSelected: $viewModel.allSelected,
                    allCommentedSelected: $viewModel.allCommenetedSelected,
                    allUnCommentedSelected: $viewModel.allUncommentedSelected)  { action in
                        switch action {
                        case .all: viewModel.selectAll()
                        case .commented: viewModel.selectAllCommented()
                        case .uncommented: viewModel.selectAllUnCommented()
                        }
                    }
                Spacer()
            }
            .frame(height: 30.0)

            HStack {
                Text("Prints")
                    .padding(.leading, 4)
                    .padding(.vertical, 4)
                Spacer()
            }
            .background {
                Color(.darkGray)
            }
            PrintItemSelectionList(items: $viewModel.printItemSectionViewModels)
            FooterBarView { action in
                switch action {
                case .collapseAll:
                    viewModel.printItemSectionViewModels.collapseAll()
                case .expandAll:
                    viewModel.printItemSectionViewModels.expandAll()
                }
            }
        }
    }
    
    private func printItemStagingView() -> some View {
        VStack(spacing: 0.0) {
            HStack {
                Spacer()
                PrintControlView { action in
                    switch action {
                    case .comment: viewModel.applyModificationToSelectedItems(.comment)
                    case .uncomment: viewModel.applyModificationToSelectedItems(.uncomment)
                    case .delete: viewModel.applyModificationToSelectedItems(.delete)
                    }
                }
            }
            .frame(height: 30.0)
            HStack {
                Text("Staging")
                    .padding(.leading, 4)
                    .padding(.vertical, 4)
                Spacer()
            }
            .background {
                Color(.darkGray)
            }
            PrintItemSelectionList(items: $viewModel.selectedPrintItemSectionViewModels)
            
            FooterBarView { action in
                switch action {
                case .collapseAll:
                    viewModel.selectedPrintItemSectionViewModels.collapseAll()
                case .expandAll:
                    viewModel.selectedPrintItemSectionViewModels.expandAll()
                }
            }
        }
    }
}

#Preview {
    ContentView()
//    VStack {
//        Image(systemName: "plus")
//            .hoverButton {
//                
//            }
//            .bold()
//        RootDirectoryIndicatorView(rootDir: .constant(nil)) {
//        } onSelectDirectory: {
//            
//        }
//    }
    .frame(width: 800.0, height: 500.0)
    
}

struct RootDirectoryIndicatorView: View {
    @Binding var rootDir: URL?
    
    var onRefresh: () -> Void
    var onSelectDirectory: () -> Void
    
    var body: some View {
        Group {
            if let _ = rootDir {
                HStack {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .button {
                            self.onRefresh()
                        }
                        .buttonStyle(PlainButtonStyle())
                    VStack {
                        Text("\(rootDir?.lastPathComponent ?? "-")")
                        Text("\(rootDir?.description ?? "-")")
                            .font(.caption)
                            .foregroundStyle(Color.gray)
                    }
                }
                .padding()
            } else {
                HStack {
                    VStack {
                        Text("Select a directory")
                    }
                    Divider()
                        .frame(height: 40.0)
                    Image(systemName: "plus")
                        .buttonStyle(.plain)
                        .button {
                            self.onSelectDirectory()
                        }
                }
                .padding()
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                .frame(minWidth: 200.0, minHeight: 50.0)
                .foregroundStyle(Color(.darkGray))
        }
    }
}
