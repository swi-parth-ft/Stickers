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
    
    var body: some View {
        NavigationStack {
           
                List {
                    ForEach(manager.categories, id: \.self) { cat in
                        NavigationLink {
                            LinksView(manager: manager, selectedTab: $selectedTab, cat: cat)
                        } label: {
                            Text(cat)
                        }
                    }
                }
            
            .onAppear {
              
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


