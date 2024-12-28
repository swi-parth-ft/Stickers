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

    var body: some View {
        NavigationStack {
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
                        ForEach(thumbnails, id: \.self) { thumbnailURL in
                            NavigationLink {
                                FullScreenImageView(
                                    imageURL: manager.getFullImageURL(for: thumbnailURL),
                                    namespace: transitionNamespace
                                )
                                .navigationTransition(.zoom(sourceID: thumbnailURL, in: transitionNamespace))
                            } label: {
                                ImageThumbnailView(imageURL: thumbnailURL, gridSize: columnWidth)
                                    .matchedTransitionSource(id: thumbnailURL, in: transitionNamespace)
                            }
                            // Disable tapping on NavigationLink if pinch is in progress:
                            .disabled(isPinching)
                        }
                    }
                    .padding(spacing)       // Add padding around the grid
                    .background(Color.white)
                    // Use a highPriorityGesture to ensure pinch takes precedence over taps:
                    .highPriorityGesture(
                        MagnificationGesture(minimumScaleDelta: 0.02)  // Adjust threshold as needed
                            .updating($isPinching) { _, state, _ in
                                // As soon as we detect a pinch, set isPinching to true
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
                thumbnails = manager.fetchThumbnails()
            }
        }
    }
}
