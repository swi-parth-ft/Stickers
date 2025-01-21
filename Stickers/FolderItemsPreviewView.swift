//
//  FolderItemsPreviewView.swift
//  Stickers
//
//  Created by Parth Antala on 2025-01-21.
//

import SwiftUI
import LinkPresentation

struct FolderItemsPreviewView: View {
    let sharedItems: [SharedItem]

    var body: some View {
        ZStack {
           

            HStack(spacing: -40) { // Overlapping cards
                ForEach(sharedItems, id: \.id) { item in
                    SharedItemCard(sharedItem: item)
                        .rotationEffect(Angle(degrees: rotationAngle(for: item)))
                }
            }
            .padding()
        }
    }

    private func rotationAngle(for item: SharedItem) -> Double {
        switch sharedItems.firstIndex(where: { $0.id == item.id }) {
        case 0: return -20
        case 1: return 15
        case 2: return -30
        default: return 0
        }
    }
}

struct FolderItemCard: View {
    let icon: String
    let iconColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 100)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
            
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black)
                    .frame(height: 120)
                Spacer()
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(iconColor)
            }
            .padding(7)
            .frame(height: 100)

        }
    }
}


struct SharedItemCard: View {
    var sharedItem: SharedItem

    var body: some View {
        switch sharedItem.decodedContent() {
        case .text:
            TextCard(sharedItem: sharedItem)
        case .imageURL:
            ImageCard(sharedItem: sharedItem)
        case .url:
            URLCard(sharedItem: sharedItem)
        default:
            DefaultCard(sharedItem: sharedItem)
        }
    }
}

struct DefaultCard: View {
    var sharedItem: SharedItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 150)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)

           


            VStack {
                Text("Unknown")
                    .font(.headline)
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "questionmark.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(width: 120, height: 150)


        }
    }
}

struct TextCard: View {
    var sharedItem: SharedItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 150)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)

            VStack {
                if let content = sharedItem.decodedContent(), case .text(let text) = content {
                                   Text(text) // Display the text content
                                       .font(.body)
                                       .foregroundColor(.white)
                                      // .lineLimit(3) // Limit lines to avoid overflow
                                       .multilineTextAlignment(.center)
                                       .padding()
                                       .frame(width: 110, height: 140)

                               } else {
                                   Text("No Text Available")
                                       .font(.caption)
                                       .foregroundColor(.gray)
                                       .multilineTextAlignment(.center)
                                       .padding()
                               }
            
            }
            .padding()
            .frame(height: 150)

        }
    }
}

struct ImageCard: View {
    var sharedItem: SharedItem
    @State private var image: UIImage?

    private func loadThumbnail(from imageURL: URL) {
        if let cachedImage = ImageCache.shared.object(forKey: imageURL as NSURL) {
            image = cachedImage // Use cached image if available
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                if let data = try? Data(contentsOf: imageURL),
                   let uiImage = UIImage(data: data) {
                    DispatchQueue.main.async {
                        ImageCache.shared.setObject(uiImage, forKey: imageURL as NSURL)
                        image = uiImage
                    }
                }
            }
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 150)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)

            if let content = sharedItem.decodedContent(), case .imageURL(let url) = content {
                if let loadedImage = image {
                    Image(uiImage: loadedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 140)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    ProgressView() // Loading indicator
                        .frame(width: 40, height: 40)
                }
            } else {
                Text("No Image")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .onAppear {
            if let content = sharedItem.decodedContent(), case .imageURL(let url) = content {
                loadThumbnail(from: url)
            }
        }
    }
}
struct URLCard: View {
    var sharedItem: SharedItem
    @State private var metadata: LPLinkMetadata? // Holds the fetched metadata

    private func fetchMetadata(url: URL) {
        let provider = LPMetadataProvider()
        provider.startFetchingMetadata(for: url) { result, error in
            if let metadata = result, error == nil {
                DispatchQueue.main.async {
                    self.metadata = metadata
                }
            } else {
                print("Failed to fetch metadata: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    var body: some View {
        ZStack {
            // Background card
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 120, height: 150)
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)

            if let content = sharedItem.decodedContent(), case .url(let url) = content {
                // Display fetched metadata image or default link icon
                if let imageProvider = metadata?.imageProvider {
                    LinkPreviewImageView(imageProvider: imageProvider)
                        .frame(width: 110, height: 140)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    VStack {
                        Image(systemName: "link")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)

                       
                    }
                    .padding(5)
                }
            } else {
                // Fallback for invalid or missing URL
                VStack {
                    Image(systemName: "link")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.gray)

                    Text("Invalid URL")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(5)
            }
        }
        .onAppear {
            // Fetch metadata when the view appears
            if let content = sharedItem.decodedContent(), case .url(let url) = content {
                fetchMetadata(url: url)
            }
        }
    }
}

#Preview {
    FolderItemsPreviewView(sharedItems: [SharedItem(), SharedItem(), SharedItem()])
}
