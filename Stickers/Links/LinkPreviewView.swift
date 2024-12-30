//
//  LinkPreviewView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI
import LinkPresentation

struct LinkPreviewView: View {
    let url: URL
    let caption: String
    @State private var metadata: LPLinkMetadata?
    @State private var isLoading = true
    @State private var showCaption = false
    
    var body: some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: 8) {
                // Show Preview Image if Available
                ZStack(alignment: .topTrailing) {
                    ZStack {
                        if let imageProvider = metadata?.imageProvider {
                            LinkPreviewImageView(imageProvider: imageProvider)
                                .frame(width: UIScreen.main.bounds.width * 0.45, height: 150)
                                .clipped()
                                .cornerRadius(12)
                        } else {
                            ZStack {
                                Image(systemName: "link")
                                    .font(.system(size: 30))
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.45, height: 150)
                            .cornerRadius(12)
                        }
                        
                        if showCaption {
                            Text(caption)
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(8)
                                .padding(8)
                        }
                    }
                    
                    if !caption.isEmpty {
                        Button {
                            withAnimation {
                                showCaption.toggle()
                            }
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .padding(8)
                        }
                    }
                }
                
                // Title and URL Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(metadata?.title ?? "Loading...")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(metadata?.url?.host ?? url.host ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(caption)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding([.horizontal, .bottom], 8)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .padding()
        }
        .buttonStyle(PlainButtonStyle()) // Removes default button styling
        .onAppear {
            fetchMetadata()
        }
    }
    
    private func fetchMetadata() {
        LinkMetadataFetcher.fetchMetadata(for: url) { metadata in
            DispatchQueue.main.async {
                self.metadata = metadata
                self.isLoading = false
            }
        }
    }
}

struct LinkPreviewImageView: View {
    let imageProvider: NSItemProvider
    
    @State private var image: UIImage?
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        ProgressView()
                    )
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        _ = imageProvider.loadObject(ofClass: UIImage.self) { object, error in
            if let image = object as? UIImage {
                DispatchQueue.main.async {
                    self.image = image
                }
            }
        }
    }
}
