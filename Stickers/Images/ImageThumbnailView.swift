//
//  ImageThumbnailView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//


//
//  ImageThumbnailView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import SwiftUI

struct ImageThumbnailView: View {
    let imageURL: URL
    let gridSize: CGFloat

    @State private var image: UIImage?
    @StateObject private var manager = SharedItemManager()
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: gridSize, height: gridSize)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .clipped()
//                    .contextMenu { // Add a context menu for deletion
//                                            Button(role: .destructive) {
//                                                manager.deleteImage(at: imageURL)
//                                            } label: {
//                                                Label("Delete", systemImage: "trash")
//                                            }
//                                        }
            } else {
                Color.gray
                    .frame(width: gridSize, height: gridSize)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .onAppear(perform: loadImage)
            }
        }
    }

    private func loadImage() {
        if let cachedImage = ImageCache.shared.object(forKey: imageURL as NSURL) {
            image = cachedImage
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: imageURL), let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        ImageCache.shared.setObject(uiImage, forKey: imageURL as NSURL)
                        image = uiImage
                    }
                }
            }
        }
    }
}
