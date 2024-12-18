//
//  HomeView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var manager = SharedItemManager()
    
    var body: some View {
        VStack {
            List(manager.items, id: \.id) { item in
                VStack(alignment: .leading) {
                    if let content = item.decodedContent() {
                        switch content {
                        case .text(let text):
                            Text(text)
                                .font(.headline)
                            
                            
                        case .image(let imageData):
                            if let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                            }
                        case .url(let url):
                            Link(url.absoluteString, destination: url)
                                .font(.headline)
                        }
                        
                        Text(item.caption ?? "")
                    } else {
                        Text("No content available")
                            .font(.headline)
                    }
                    
                    Text(item.timestamp, style: .date)
                        .font(.subheadline)
                }
            }
            Button("Add Item") {
                // Example: Saving a new text item
                manager.saveItem(content: .text("New Shared Item"), caption: "demo")
            }
            .padding()
        }
        .onAppear {
            manager.fetchItems() // Fetch items when the view appears
        }
    }
}

#Preview {
    HomeView()
}
