
import SwiftUI

struct FoldersView: View {
    
    @StateObject var manager: SharedItemManager
    private var categoryCounts: [String: Int] {
        Dictionary(grouping: manager.items, by: { $0.category })
            .mapValues { $0.count }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(manager.categories, id: \.self) { category in
                        folderCard(for: category)
                    }
                }
            }
            .navigationTitle("Folders")
        }
    }
    
    // Helper View for Folder Card
    private func folderCard(for category: String) -> some View {
        ZStack {
            folderBackground()
            // Use FolderItemsPreviewView here and pass recent 3 items for the category
                        if let recentItems = getRecentItems(for: category) {
                            FolderItemsPreviewView(sharedItems: recentItems)
                                .padding(.horizontal, 10)
                        }
            folderContent(for: category)
        }
        .padding()
    }
    
    // Background Image
    private func folderBackground() -> some View {
        Image(.folder)
            .resizable()
            .scaledToFill()
            .frame(height: 237)
    }
    
    // Content Overlay
    private func folderContent(for category: String) -> some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.gray.opacity(0.5)) // Updated to avoid `.quaternary` if unsupported
                    .frame(height: 84)
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(category)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(categoryCounts[category, default: 0]) items")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
            }
        }
        .padding(.horizontal, 5)
        .frame(height: 237)
    }
    
    // Helper Method: Get Recent 3 Items for a Category
      private func getRecentItems(for category: String) -> [SharedItem]? {
          let itemsForCategory = manager.items
              .filter { $0.category == category }
              .sorted { $0.timestamp > $1.timestamp } // Sort by most recent
          
          if itemsForCategory.isEmpty {
              return [SharedItem(), SharedItem(), SharedItem()]
          }
          return Array(itemsForCategory.prefix(3)) // Return the first 3 items
      }
}

#Preview {
    FoldersView(manager: SharedItemManager())
}
