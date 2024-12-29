//
//  FallbackLinkView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//


import SwiftUI

/// A view that displays a simple fallback for a link if metadata is unavailable
struct FallbackLinkView: View {
    let url: URL

    var body: some View {
        HStack {
            // Placeholder icon
            Image(systemName: "link")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.gray)
                .padding()

            // URL text
            VStack(alignment: .leading) {
                Text(url.absoluteString)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .lineLimit(1)

                Text("No preview available")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground)) // Background color
        .cornerRadius(12)
    }
}