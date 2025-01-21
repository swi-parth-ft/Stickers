import SwiftUI

struct ContentView: View {
    @StateObject private var manager = SharedItemManager()
    @State private var selectedTab: Tab = .home // Default to the Home tab

    var body: some View {
        VStack(spacing: 0) {
            // Content area
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .text:
                    SharedTextView(manager: manager, selectedTab: $selectedTab)
                case .image:
                    CategoryListView()
                case .url:
                    LinkCategoryView(selectedTab: $selectedTab)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black) // Content background color

            // Custom TabBar
            HStack {
                TabBarItem(icon: "house.fill", isSelected: selectedTab == .home, selectedColor: .orange) {
                    selectedTab = .home
                }
                TabBarItem(icon: "text.alignleft", isSelected: selectedTab == .text, selectedColor: .orange) {
                    selectedTab = .text
                }
                TabBarItem(icon: "photo.fill", isSelected: selectedTab == .image, selectedColor: .orange) {
                    selectedTab = .image
                }
                TabBarItem(icon: "link", isSelected: selectedTab == .url, selectedColor: .orange) {
                    selectedTab = .url
                }
            }
            .padding()
            .padding(.bottom, 20)
            .background(
                            RoundedRectangle(cornerRadius: 20) // TabBar background with rounded corners
                                .fill(Color.black)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: -2)
                        )
             // Remove any default padding at the bottom


        }
        .ignoresSafeArea(edges: .bottom) // Ignore the safe area at the bottom

        .onAppear {
            manager.fetchItems() // Fetch items when the view appears
        }
    }
}

// TabBarItem: A reusable view for a tab bar button
struct TabBarItem: View {
    let icon: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(selectedColor)
                        .frame(width: 50, height: 50)
                }
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Enum to define the tabs
enum Tab {
    case home
    case text
    case image
    case url
}

#Preview {
    ContentView()
}
