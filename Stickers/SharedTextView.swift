//
//  SharedTextView.swift
//  Stickers
//
//  Created by Parth Antala on 2024-12-18.
//

import SwiftUI

struct SharedTextView: View {
    @StateObject var manager: SharedItemManager
       @Binding var selectedTab: Tab
       
       var body: some View {
           List(manager.items.filter { item in
               if let content = item.decodedContent() {
                   switch content {
                   case .text:
                       return true
                   default:
                       return false
                   }
               }
               return false
           }, id: \.id) { item in
               if let content = item.decodedContent(), case .text(let text) = content {
                   Text(text)
                       .font(.headline)
                   
                   Text(item.caption ?? "")
               }
           }
       }
}

