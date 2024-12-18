import SwiftUI
import SwiftData

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = SharedItemManager()
    @State private var selectedTab: Tab = .url // Default to .text tab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("home")
                }
                .tag(Tab.home)
               
            
            SharedTextView(manager: manager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "text.alignleft")
                    Text("Text")
                }
                .tag(Tab.text)
            
            PhotosView(manager: manager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "photo.fill")
                    Text("Images")
                }
                .tag(Tab.image)
            
            LinksView(manager: manager, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "link")
                    Text("URLs")
                }
                .tag(Tab.url)
        }
        .onAppear {
            manager.fetchItems() // Fetch items when the view appears
        }
       
    }
}

enum Tab {
    case home
    case text
    case image
    case url
}
#Preview {
    ContentView()
}
