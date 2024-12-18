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
    // Grid layout: 2 columns with adaptive width
    
    var filteredLinks: [SharedItem] {
        manager.items.filter { item in
            if let content = item.decodedContent(), case .url(let url) = content {
                let category = categorizeLink(url: url)
                return selectedProvider == "All" || category == selectedProvider
            }
            return false
        }
    }
    
    var categorizedLinks: [String: [SharedItem]] {
        Dictionary(grouping: filteredLinks) { item in
            if let content = item.decodedContent(), case .url(let url) = content {
                return categorizeLink(url: url) // Categorize URL
            }
            return "Other"
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
                        }
                    }
                }
                .padding(.horizontal, 8)
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

struct MissingLinkPreviewView: View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .cornerRadius(8)
                .overlay(
                    Image(systemName: "link")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                )
            
            Text("Link Preview Unavailable")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .frame(maxHeight: 200)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

#Preview {
    LinksView(manager: SharedItemManager(), selectedTab: .constant(.url))
}
