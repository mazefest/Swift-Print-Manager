//
//  Dictionary+Ext.swift
//  DeadPrint
//
//  Created by Colby Mehmen on 4/5/25.
//

import SwiftUI

extension Dictionary where Key == URL, Value == [PrintItem] {
    
    func combine(_ dict: [URL: [PrintItem]]) -> Self {
        var result = self
        for (url, items) in dict {
            var existingItems = result[url] ?? []
            for item in items {
                if !existingItems.contains(item) {
                    existingItems.append(item)
                }
            }
            result[url] = existingItems
        }
        return result
    }
    
    func remove(_ dict: [URL: [PrintItem]]) -> Self {
        var result = self
        for (url, items) in dict {
            guard var existingItems = result[url] else { continue }
            existingItems.removeAll { items.contains($0) }
            if existingItems.isEmpty {
                result.removeValue(forKey: url)
            } else {
                result[url] = existingItems
            }
        }
        return result
    }
    
    func contains(_ dict: [URL: [PrintItem]]) -> Bool {
        for (url, items) in dict {
            guard let existingItems = self[url] else {
                return false
            }
            for item in items {
                if !existingItems.contains(item) {
                    return false
                }
            }
        }
        return true
    }
    
    func contains(file: URL, printItem: PrintItem) -> Bool {
        return self[file]?.contains(printItem) ?? false
    }
    
    func contains(file: URL) -> Bool {
        return self[file] != nil
    }
    
    func filter(commented: Bool) -> Self {
        var result: [URL: [PrintItem]] = [:]
        for (file, items) in self {
            let items = items.filter(commented: commented)
            if items.count > 0 {
                result[file] = items
            }
        }
        return result
    }
}

extension Array<PrintItem> {
    func filter(commented: Bool) -> Self {
        self.filter { $0.commented == commented }
    }
}
