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
            // Header Section
            headerSection()
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 16)
                .background {
                    Rectangle()
                        .fill(Color(nsColor: .separatorColor).opacity(0.3))
                }
            
            Divider()
                .background(Color(nsColor: .separatorColor))

            // Main Content Area
            HStack(spacing: 0.0) {
                printItemSelectionView()
                
                Divider()
                    .background(Color(nsColor: .separatorColor))
                
                printItemStagingView()
            }
            
            Spacer()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .frame(minWidth: 400.0, minHeight: 400.0)
    }
    
    private func headerSection() -> some View {
        HStack {
            Spacer()
            RootDirectoryIndicatorView(
                rootDir: $viewModel.rootDir,
                onRefresh: viewModel.refreshFiles,
                onSelectDirectory: onSelectDirectory
            )
            Spacer()
        }
    }
    
    private func onSelectDirectory() {
        self.selectDirectory { url in
            self.viewModel.rootDir = url
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
            // Toolbar
            HStack(spacing: 12) {
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
            .frame(height: 36)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Rectangle()
                    .fill(Color(nsColor: .controlBackgroundColor))
            }
            
            Divider()
                .background(Color(nsColor: .separatorColor))

            // Section Header
            sectionHeader(title: "Prints")
            
            // Content List
            PrintItemSelectionList(items: $viewModel.printItemSectionViewModels)
            
            // Footer
            Divider()
                .background(Color(nsColor: .separatorColor))
            FooterBarView { action in
                switch action {
                case .collapseAll:
                    viewModel.printItemSectionViewModels.collapseAll()
                case .expandAll:
                    viewModel.printItemSectionViewModels.expandAll()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Rectangle()
                    .fill(Color(nsColor: .controlBackgroundColor))
            }
        }
    }
    
    private func printItemStagingView() -> some View {
        VStack(spacing: 0.0) {
            // Toolbar
            HStack(spacing: 12) {
                Spacer()
                PrintControlView { action in
                    switch action {
                    case .comment: viewModel.applyModificationToSelectedItems(.comment)
                    case .uncomment: viewModel.applyModificationToSelectedItems(.uncomment)
                    case .delete: viewModel.applyModificationToSelectedItems(.delete)
                    }
                }
            }
            .frame(height: 36)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background {
                Rectangle()
                    .fill(Color(nsColor: .controlBackgroundColor))
            }
            
            Divider()
                .background(Color(nsColor: .separatorColor))

            // Section Header
            sectionHeader(title: "Staging")
            
            // Content List
            PrintItemSelectionList(items: $viewModel.selectedPrintItemSectionViewModels)
            
            // Footer
            Divider()
                .background(Color(nsColor: .separatorColor))
            FooterBarView { action in
                switch action {
                case .collapseAll:
                    viewModel.selectedPrintItemSectionViewModels.collapseAll()
                case .expandAll:
                    viewModel.selectedPrintItemSectionViewModels.expandAll()
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Rectangle()
                    .fill(Color(nsColor: .controlBackgroundColor))
            }
        }
    }
    
    private func sectionHeader(title: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .default))
                .foregroundColor(Color(nsColor: .secondaryLabelColor))
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Rectangle()
                .fill(Color(nsColor: .quaternaryLabelColor).opacity(0.1))
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
                HStack(spacing: 12) {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(nsColor: .controlAccentColor))
                    }
                    .buttonStyle(.plain)
                    .help("Refresh")
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(rootDir?.lastPathComponent ?? "-")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(nsColor: .labelColor))
                            .lineLimit(1)
                        Text(rootDir?.path ?? "-")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color(nsColor: .secondaryLabelColor))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            } else {
                Button(action: onSelectDirectory) {
                    HStack(spacing: 8) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 14, weight: .medium))
                        Text("Select a directory")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(Color(nsColor: .controlAccentColor))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .strokeBorder(Color(nsColor: .separatorColor), lineWidth: 1)
                }
        }
        .frame(minWidth: 280)
    }
}
