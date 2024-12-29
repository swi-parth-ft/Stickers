//
//  CategoryListView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-29.
//


import SwiftUI

struct CategoryListView: View {
    @StateObject private var manager = SharedItemManager()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(manager.categories, id: \.self) { category in
                    NavigationLink(destination: ImageGridView(selectedCategory: category)) {
                        Text(category)
                    }
                }
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
    
    private func addCategory() {
        // Present an alert or sheet to add a new category
        let newCategory = "New Category" // Replace with your logic to capture input
        manager.addCategory(newCategory)
    }
}