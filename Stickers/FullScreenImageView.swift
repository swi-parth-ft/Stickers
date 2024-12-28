//
//  FullScreenImageView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import SwiftUI

struct FullScreenImageView: View {
    let imageURL: URL?
    let namespace: Namespace.ID

    var body: some View {
        GeometryReader { geometry in
            if let imageURL = imageURL,
               let image = UIImage(contentsOfFile: imageURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .matchedTransitionSource(id: imageURL, in: namespace)
                    .background(Color.black.opacity(0.9))
                    .ignoresSafeArea()
            } else {
                Text("Failed to load image")
                    .foregroundColor(.red)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black)
    }
}
