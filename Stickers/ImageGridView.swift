//
//  ImageGridView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import SwiftUI

extension URL: Identifiable {
    public var id: String {
        self.absoluteString
    }
}

struct ImageGridView: View {
    @StateObject private var manager = SharedItemManager()
    @State private var thumbnails: [URL] = []
    @State private var gridSize: CGFloat = 100 // Initial grid item size
    @State private var selectedImageURL: URL? // For full-screen viewing
    @GestureState private var pinchScale: CGFloat = 1.0 // Scale state for pinch gesture

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    // Calculate number of columns dynamically based on available width
                    let columns = Int(geometry.size.width / gridSize)
                    let spacing: CGFloat = 2 // Tiny white space between images
                    let totalSpacing = CGFloat(columns - 1) * spacing
                    let columnWidth = (geometry.size.width - totalSpacing) / CGFloat(columns)

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(columnWidth), spacing: spacing), count: columns),
                        spacing: spacing
                    ) {
                        ForEach(thumbnails, id: \.self) { url in
                            ImageThumbnailView(imageURL: url, gridSize: columnWidth)
                                .onTapGesture {
                                    selectedImageURL = manager.getFullImageURL(for: url)
                                }
                        }
                    }
                    .padding(spacing) // Add padding around the grid
                    .background(Color.white) // Match iOS Photos app background
                    .gesture(
                        MagnificationGesture()
                            .updating($pinchScale) { currentState, gestureState, _ in
                                gestureState = currentState
                            }
                            .onEnded { finalScale in
                                let newSize = gridSize * finalScale
                                gridSize = max(50, min(300, newSize))
                            }
                    )
                    .scaleEffect(pinchScale)
                    .animation(.easeInOut, value: gridSize)
                }
                .navigationTitle("Saved Images")
                .onAppear {
                    thumbnails = manager.fetchThumbnails()
                }
                .fullScreenCover(item: $selectedImageURL) { url in
                               FullScreenImageView(imageURL: url)
                           }
            }
        }
    }
}
