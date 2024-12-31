//
//  CategoryListView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-29.
//

import SwiftUI

struct CategoryListView: View {
    @StateObject private var manager = SharedItemManager()
    private let gridSize: CGFloat = 120 // Grid item size
    @Namespace private var transitionNamespace // Namespace for the zoom transition
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: createGridItems(for: gridSize), spacing: 20) {
                    ForEach(manager.categories, id: \.self) { category in
                        buildCategoryItem(for: category)
                    }
                }
                .padding(16)
            }
            .onAppear {
                manager.fetchItems()
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addCategory) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    // Helper function to create grid items
    private func createGridItems(for size: CGFloat) -> [GridItem] {
        let spacing: CGFloat = 16
        return Array(repeating: GridItem(.adaptive(minimum: size), spacing: spacing), count: 2) // 2 columns minimum
    }

    private func buildCategoryItem(for category: String) -> some View {
        NavigationLink { ImageGridView(selectedCategory: category).navigationTransition(.zoom(sourceID: category, in: transitionNamespace)) } label: {
            VStack(spacing: 8) {
                ZStack {
                    let thumbnails = Array(manager.fetchThumbnails(for: category).prefix(3))

                    // First Image: Centered
                    if thumbnails.indices.contains(0) {
                        ImageThumbnailView(imageURL: thumbnails[0], gridSize: 100)
                            .zIndex(3) // Ensure this is on top
                    }

                    // Second Image: Rotated -45 degrees
                    if thumbnails.indices.contains(1) {
                        ImageThumbnailView(imageURL: thumbnails[1], gridSize: 100)
                            .rotationEffect(.degrees(-15))
                          //  .offset(x: -8, y: -8) // Slight offset for better visibility
                            .zIndex(2)
                    }

                    // Third Image: Rotated 45 degrees
                    if thumbnails.indices.contains(2) {
                        ImageThumbnailView(imageURL: thumbnails[2], gridSize: 100)
                            .rotationEffect(.degrees(15))
                         //   .offset(x: 8, y: 8) // Slight offset for better visibility
                            .zIndex(1)
                    }
                }
                .frame(width: gridSize, height: gridSize)
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 5)

                Text(category)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(maxWidth: gridSize)
            }
            .frame(maxWidth: .infinity)
            .matchedTransitionSource(id: category, in: transitionNamespace)
        }
    }

    private func addCategory() {
        // Present an alert or sheet to add a new category
        let newCategory = "New Category" // Replace with your logic to capture input
        manager.addCategory(newCategory)
    }
}
