//
//  PhotosView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI

struct PhotosView: View {
    @StateObject var manager: SharedItemManager
        @Binding var selectedTab: Tab
        
        var body: some View {
            List(manager.items.filter { item in
                if let content = item.decodedContent() {
                    switch content {
                    case .image:
                        return true
                    default:
                        return false
                    }
                }
                return false
            }, id: \.id) { item in
                if let content = item.decodedContent(), case .image(let imageData) = content, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                    
                    Text(item.caption ?? "")
                }
            }
        }
}


