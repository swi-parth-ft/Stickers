//
//  AddFolderView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-30.
//

import SwiftUI

struct AddFolderView: View {
    @Binding var newFolderName: String
    var onAdd: (String) -> Void

    var body: some View {
        NavigationView {
            Form {
                TextField("Folder Name", text: $newFolderName)
            }
            .navigationTitle("Add New Folder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        newFolderName = ""
                      //  UIApplication.shared.endEditing()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !newFolderName.isEmpty {
                            onAdd(newFolderName)
                            newFolderName = ""
                        }
                    }
                }
            }
        }
    }
}
