//
//  SharedTextView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI

struct SharedTextView: View {
    @ObservedObject var manager: SharedItemManager
    @Binding var selectedTab: Tab
    
    /// A computed property that filters only `.text` items.
    private var textItems: [SharedItem] {
        manager.items.filter { item in
            guard let content = item.decodedContent() else { return false }
            switch content {
            case .text:
                return true
            default:
                return false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(textItems, id: \.id) { item in
                if let content = item.decodedContent(),
                   case .text(let text) = content
                {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(text)
                            .font(.headline)
                        
                        if let caption = item.caption, !caption.isEmpty {
                            Text(caption)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Text Items")
        }
    }
}
