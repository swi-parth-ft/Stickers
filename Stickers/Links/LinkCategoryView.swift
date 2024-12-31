//
//  LinkCategoryView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-30.
//

import SwiftUI

struct LinkCategoryView: View {
    @StateObject private var manager = SharedItemManager()
    @Binding var selectedTab: Tab
    @State private var isAddingNewFolder = false
    @State private var newFolderName: String = ""
    @State private var categoryToDelete: String?
    @State private var isShowingDeleteOptions = false
    @State private var isShowingCategoryPicker = false
    @State private var selectedTargetCategory: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.categories, id: \.self) { cat in
                    NavigationLink {
                        LinksView(manager: manager, selectedTab: $selectedTab, cat: cat)
                    } label: {
                        Text(cat)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            categoryToDelete = cat
                            isShowingDeleteOptions = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Links")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddingNewFolder.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNewFolder) {
                AddFolderView(newFolderName: $newFolderName, onAdd: { folderName in
                    manager.addCategory(folderName)
                    isAddingNewFolder = false
                })
            }
            .confirmationDialog(
                "Delete Category",
                isPresented: $isShowingDeleteOptions,
                titleVisibility: .visible
            ) {
                if let category = categoryToDelete {
                    Button("Move Items to Another Category") {
                        isShowingCategoryPicker = true
                    }
                    Button("Move to Uncategorized") {
                        manager.deleteCategory(category, withOption: .moveToUncategorized)
                    }
                    Button("Delete Items", role: .destructive) {
                        manager.deleteCategory(category, withOption: .deleteItems)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("What would you like to do with items in the '\(categoryToDelete ?? "")' category?")
            }
            .sheet(isPresented: $isShowingCategoryPicker) {
                CategoryPickerView(
                    categories: manager.categories.filter { $0 != categoryToDelete },
                    onSelect: { targetCategory in
                        if let category = categoryToDelete {
                            manager.deleteCategory(category, withOption: .moveToCategory(targetCategory))
                            isShowingCategoryPicker = false
                        }
                    }
                )
            }
            .onAppear {
                manager.fetchItems()
            }
        }
    }
}


struct CategoryPickerView: View {
    let categories: [String]
    var onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss // Add this to access the dismiss action

    var body: some View {
        NavigationView {
            List {
                ForEach(categories, id: \.self) { category in
                    Button {
                        onSelect(category)
                        dismiss() // Dismiss the sheet after selecting a category
                    } label: {
                        Text(category)
                    }
                }
            }
            .navigationTitle("Choose Category")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss() // Use the dismiss environment value
                    }
                }
            }
        }
    }
}
