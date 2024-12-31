//
//  FullScreenImageView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-27.
//

import SwiftUI
import VisionKit

var isLiveTextSupported: Bool {
    return ImageAnalyzer.isSupported
}




struct FullScreenImageView: View {
    let imageURLs: [URL]
    @State private var currentIndex: Int
    @State private var isZoomed: Bool = false
    let namespace: Namespace.ID

    init(imageURLs: [URL], selectedIndex: Int, namespace: Namespace.ID) {
        self.imageURLs = imageURLs
        self._currentIndex = State(initialValue: selectedIndex)
        self.namespace = namespace
        configurePageControlAppearance()
    }

    var body: some View {
        ZStack {
            (isZoomed ? Color.black : nil)
                .ignoresSafeArea()

            TabView(selection: $currentIndex) {
                ForEach(imageURLs.indices, id: \.self) { index in
                    GeometryReader { geometry in
                        if let image = UIImage(contentsOfFile: imageURLs[index].path) {
                            LiveTextImageView(image: image)
                                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it takes full available space
                                .cornerRadius(isZoomed ? 0 : 22)
                                .shadow(radius: 10)
                                .padding(isZoomed ? 0 : 7)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        isZoomed.toggle()
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

    private func configurePageControlAppearance() {
        let appearance = UIPageControl.appearance()
        appearance.currentPageIndicatorTintColor = .orange
        appearance.pageIndicatorTintColor = .gray
    }
}
