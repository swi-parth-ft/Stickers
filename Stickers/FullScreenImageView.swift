//
//  FullScreenImageView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//


//
//  FullScreenImageView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import SwiftUI

struct FullScreenImageView: View {
    let imageURL: URL
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            if let image = UIImage(contentsOfFile: imageURL.path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color.black)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
            } else {
                Text("Failed to load image")
                    .foregroundColor(.red)
                    .onTapGesture {
                        dismiss()
                    }
            }
        }
    }
}