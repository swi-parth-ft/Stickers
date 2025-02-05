//
//  Links.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI

struct LinksView: View {
    @StateObject var manager: SharedItemManager
    @Binding var selectedTab: Tab
    @State private var selectedProvider: String = "All"
    let cat: String
    
    // Grid layout: 2 columns with adaptive width
    
    var filteredLinks: [SharedItem] {
        manager.items.filter { item in
            if let content = item.decodedContent(), case .url(let url) = content {
                let category = categorizeLink(url: url)
                return (selectedProvider == "All" || category == selectedProvider) && item.category == cat
            }
            
            return false
        }
    }
    
    func categorizeLink(url: URL) -> String {
        let host = url.host?.lowercased() ?? ""
        
        if host.contains("threads.net") {
            return "Threads"
        } else if host.contains("twitter.com") || host.contains("x.com") {
            return "Twitter"
        } else if host.contains("instagram.com") {
            return "Instagram"
        } else {
            return "Web"
        }
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(filteredLinks, id: \.id) { item in
                        if let content = item.decodedContent(), case .url(let url) = content {
                            LinkPreviewView(url: url, caption: item.caption ?? "")
                                .contextMenu {
                                    Menu {
                                        ForEach(manager.categories, id: \.self) { category in
                                            Button {
                                                manager.updateCategoryforLinks(for: url, to: category)
                                            } label: {
                                                Label(category, systemImage: "folder")
                                            }
                                        }
                                    } label: {
                                        Label("Move Category", systemImage: "arrow.right.square")
                                    }
                                    
                                    Button(role: .destructive) {
                                        manager.deleteItem(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        manager.deleteItem(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .onAppear {
                manager.fetchItems()
            }
            .navigationTitle("\(selectedProvider) Links")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("All") {
                            selectedProvider = "All"
                        }
                        
                        Button("Threads") {
                            selectedProvider = "Threads"
                        }
                        
                        Button("Twitter") {
                            selectedProvider = "Twitter"
                        }
                        
                        Button("Instagram") {
                            selectedProvider = "Instagram"
                        }
                        
                        Button("Web") {
                            selectedProvider = "Web"
                        }
                        
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}
