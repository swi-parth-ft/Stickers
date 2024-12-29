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
//            List(manager.items, id: \.id) { item in
//                VStack(alignment: .leading) {
//                    if let content = item.decodedContent() {
//                        switch content {
//                        case .text(let text):
//                            Text(text)
//                                .font(.headline)
//                            
//                        case .imageURL(let imageURL):
//                            if let uiImage = UIImage(contentsOfFile: imageURL.path) {
//                                Image(uiImage: uiImage)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(height: 100)
//                            } else {
//                                Text("Image could not be loaded")
//                                    .font(.subheadline)
//                                    .foregroundColor(.red)
//                            }
//                            
//                        case .url(let url):
//                            Link(url.absoluteString, destination: url)
//                                .font(.headline)
//                        }
//                        
//                        if let caption = item.caption, !caption.isEmpty {
//                            Text(caption)
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                    } else {
//                        Text("No content available")
//                            .font(.headline)
//                            .foregroundColor(.red)
//                    }
//                    
//                    Text(item.timestamp, style: .date)
//                        .font(.footnote)
//                        .foregroundColor(.secondary)
//                }
//            }
//            Button("Add Item") {
//                // Example: Saving a new text item
//                manager.saveItem(content: .text("New Shared Item"), caption: "Demo caption")
//            }
//            .padding()
        }
        .onAppear {
            manager.fetchItems() // Fetch items when the view appears
        }
    }
}

#Preview {
    HomeView()
}
