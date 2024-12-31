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

    @State private var categoryToDelete: String? // Tracks the category to delete
    @State private var isShowingDeleteOptions = false // Show delete confirmation dialog
    @State private var isShowingCategoryPicker = false // Show category picker dialog

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: createGridItems(for: gridSize), spacing: 20) {
                    ForEach(manager.categories, id: \.self) { category in
                        buildCategoryItem(for: category)
                            .contextMenu {
                                Menu {
                                    Button("Move Items to Another Category") {
                                        categoryToDelete = category
                                        isShowingCategoryPicker = true
                                    }
                                    Button("Move Items to Uncategorized") {
                                        manager.deleteCategory(category, withOption: .moveToUncategorized)
                                    }
                                    Button("Delete Items", role: .destructive) {
                                        manager.deleteCategory(category, withOption: .deleteItems)
                                    }
                                } label: {
                                    Label("Delete Category", systemImage: "trash")
                                }
                            }
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
            .sheet(isPresented: $isShowingCategoryPicker) {
                if let category = categoryToDelete {
                    CategoryPickerView(
                        categories: manager.categories.filter { $0 != category },
                        onSelect: { targetCategory in
                            manager.deleteCategory(category, withOption: .moveToCategory(targetCategory))
                            isShowingCategoryPicker = false
                        }
                    )
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
        NavigationLink {
            ImageGridView(selectedCategory: category)
                .navigationTransition(.zoom(sourceID: category, in: transitionNamespace))
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    let thumbnails = Array(manager.fetchThumbnails(for: category).prefix(3))

                    // First Image: Centered
                    if thumbnails.indices.contains(0) {
                        ImageThumbnailView(imageURL: thumbnails[0], gridSize: 100)
                            .zIndex(3) // Ensure this is on top
                    }

                    // Second Image: Rotated -15 degrees
                    if thumbnails.indices.contains(1) {
                        ImageThumbnailView(imageURL: thumbnails[1], gridSize: 100)
                            .rotationEffect(.degrees(-15))
                            .zIndex(2)
                    }

                    // Third Image: Rotated 15 degrees
                    if thumbnails.indices.contains(2) {
                        ImageThumbnailView(imageURL: thumbnails[2], gridSize: 100)
                            .rotationEffect(.degrees(15))
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
