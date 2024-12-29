//
//  FullScreenImageView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import SwiftUI

struct FullScreenImageView: View {
    let imageURLs: [URL]
    @State private var currentIndex: Int
    @State private var isZoomed: Bool = false // State to toggle between zoomed and normal view
    let namespace: Namespace.ID

    init(imageURLs: [URL], selectedIndex: Int, namespace: Namespace.ID) {
        self.imageURLs = imageURLs
        self._currentIndex = State(initialValue: selectedIndex)
        self.namespace = namespace
        configurePageControlAppearance() // Configure indicator appearance
    }

    var body: some View {
        ZStack {
            // Background color changes based on zoom state
            (isZoomed ? Color.black : nil)
                .ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(imageURLs.indices, id: \.self) { index in
                    GeometryReader { geometry in
                        if let image = UIImage(contentsOfFile: imageURLs[index].path) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .padding(isZoomed ? 0 : 20) // Add padding if not zoomed
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .cornerRadius(isZoomed ? 0 : 22)
                               
                                .shadow(radius: 10)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isZoomed.toggle() // Toggle zoom state
                                    }
                                }
                                .matchedTransitionSource(id: imageURLs[index], in: namespace)
                        } else {
                            Text("Failed to load image")
                                .foregroundColor(.red)
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Helper method to configure the appearance of page control indicators
    private func configurePageControlAppearance() {
        let appearance = UIPageControl.appearance()
        appearance.currentPageIndicatorTintColor = .orange // Active indicator color
        appearance.pageIndicatorTintColor = .gray         // Inactive indicator color
    }
}
