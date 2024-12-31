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
    
    @GestureState private var pinchScale: CGFloat = 1.0 // Scale state for pinch gesture
    @GestureState private var isPinching: Bool = false  // Flag to detect active pinching
    
    @Namespace private var transitionNamespace // Namespace for the zoom transition
    let selectedCategory: String
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    // Use a helper function to calculate grid configuration
                    let gridItems = createGridItems(for: geometry.size.width, gridSize: gridSize)

                    LazyVGrid(columns: gridItems, spacing: 2) {
                        ForEach(thumbnails, id: \.self) { thumbnailURL in
                            buildThumbnailView(thumbnailURL: thumbnailURL)
                        }
                    }
                    .padding(2)       // Add padding around the grid
                    .background(Color.white)
                    // Use a highPriorityGesture to ensure pinch takes precedence over taps:
                    .highPriorityGesture(
                        MagnificationGesture(minimumScaleDelta: 0.02)  // Adjust threshold as needed
                            .updating($isPinching) { _, state, _ in
                                state = true
                            }
                            .updating($pinchScale) { currentState, gestureState, _ in
                                gestureState = currentState
                            }
                            .onEnded { finalScale in
                                withAnimation(.easeInOut) {
                                    let newSize = gridSize * finalScale
                                    gridSize = max(50, min(300, newSize))
                                }
                            }
                    )
                }
            }
            .navigationTitle("Saved Images")
            .onAppear {
                thumbnails = manager.fetchThumbnails(for: selectedCategory)
                manager.fetchItems()
            }
        }
    }

    // Helper function to calculate grid items
    private func createGridItems(for width: CGFloat, gridSize: CGFloat) -> [GridItem] {
        let columns = Int(width / gridSize)
        let spacing: CGFloat = 2
        return Array(repeating: GridItem(.fixed(gridSize), spacing: spacing), count: columns)
    }

    // Helper function to build thumbnail view
    private func buildThumbnailView(thumbnailURL: URL) -> some View {
        NavigationLink {
            FullScreenImageView(
                imageURLs: thumbnails.map { manager.getFullImageURL(for: $0)! }, // Get full-resolution URLs
                selectedIndex: thumbnails.firstIndex(of: thumbnailURL) ?? 0,    // Start at the tapped image
                namespace: transitionNamespace
            )
            .navigationTransition(.zoom(sourceID: thumbnailURL, in: transitionNamespace))
        } label: {
            ImageThumbnailView(imageURL: thumbnailURL, gridSize: gridSize)
                .matchedTransitionSource(id: thumbnailURL, in: transitionNamespace)
                .contextMenu {
                                    Button(role: .destructive) {
                                        manager.deleteImage(at: thumbnailURL)
                                        thumbnails = manager.fetchThumbnails(for: selectedCategory)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
        }
        .disabled(isPinching)
    }
}
