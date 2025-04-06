//
//  ContentView2.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

struct ContentView2: View {
    @State var current: FileNode?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button {
                    selectProjectFolder { url in
                        self.current = buildFileTree(from: url!)
                    }
                } label: {
                    Text("Select")
                }
                
                Spacer()
            }
            if let current {
                HStack {
                    FileNavigatorView(node: current)
                    Spacer()
                }
                
            } else {
                EmptyView()
            }
            Spacer()
        }
        
    }
    
    func selectProjectFolder(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            completion(response == .OK ? panel.url : nil)
        }
    }
    
    func buildFileTree(from url: URL) -> FileNode {
        let root = FileNode(url: url)
        if root.isDirectory {
            let contents = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
            root.children = contents
                .filter { !$0.lastPathComponent.hasPrefix(".swift") } // skip hidden files
                .map { buildFileTree(from: $0) }
            root.children.forEach { node in
            }
        }
        return root
    }
}

struct FileNavigatorView: View {
    @ObservedObject var node: FileNode
    
    var body: some View {
        if node.isDirectory {
            DisclosureGroup(node.name) {
                ForEach(node.children) { child in
                    FileNavigatorView(node: child)
                        .padding(.leading)
                }
            }
        } else {
            Text(node.name)
                .padding(.leading, 20)
        }
    }
    
    func selectProjectFolder(completion: @escaping (URL?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.begin { response in
            completion(response == .OK ? panel.url : nil)
        }
    }
}
