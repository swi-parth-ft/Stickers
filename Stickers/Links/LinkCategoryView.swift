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
            .onAppear {
                manager.fetchItems()
            }
        }
    }
}


