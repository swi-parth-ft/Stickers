import SwiftData
import UIKit
import Foundation


@MainActor
class SharedItemManager: ObservableObject {
    private var container: ModelContainer?
    @Published var thumbnails: [URL] = []
    @Published var items: [SharedItem] = []
    @Published var gridSize: CGFloat = 100
    @Published var categories: [String] {
        didSet {
            let sharedDefaults = UserDefaults(suiteName: "group.com.parthant.Stickers")
            sharedDefaults?.set(categories, forKey: "categories")
        }
    }
        @Published var selectedCategory: String? = nil

    init() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.parthant.Stickers")
            self.categories = sharedDefaults?.array(forKey: "categories") as? [String] ?? ["Screenshots", "General", "Work", "Personal", "Important"]
            initializeModelContainer()
          //  fetchItems()
        
    fetchItems()
    }

    private func saveCategoriesToUserDefaults() {
            let sharedDefaults = UserDefaults(suiteName: "group.com.parthant.Stickers")
            sharedDefaults?.set(categories, forKey: "categories")
        }
    
    func initializeModelContainer() {
        do {
            let schema = Schema([SharedItem.self])
            let configuration = ModelConfiguration("group.com.parthant.Stickers")
            self.container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("Error initializing ModelContainer: \(error)")
        }
    }

    func fetchItems() {
        guard let container = container else { return }
        let context = container.mainContext
        
        do {
            let descriptor = FetchDescriptor<SharedItem>()
            self.items = try context.fetch(descriptor)
            print(items)
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }

    func saveItem(content: SharedContent, caption: String) {
        guard let container = container else { return }
        let context = container.mainContext
        
        let newItem = SharedItem(content: content, caption: caption, category: self.selectedCategory ?? "General")
        context.insert(newItem)
        
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Failed to save item: \(error)")
        }
    }

    func fetchImages() -> [URL] {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
            print("Error accessing shared container")
            return []
        }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
            return fileURLs.filter { $0.pathExtension == "jpg" } // Filter for JPG files
        } catch {
            print("Failed to fetch images: \(error)")
            return []
        }
    }
    
    func fetchThumbnails(for category: String) -> [URL] {
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
                print("Error accessing shared container")
                return []
            }
            
            do {
                // Fetch all thumbnails in the shared container
                let fileURLs = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
                let thumbnails = fileURLs.filter { $0.lastPathComponent.hasPrefix("thumbnail_") }
                
                // Filter thumbnails that belong to the specified category
                let categoryThumbnails = items.compactMap { item -> URL? in
                    guard let contentData = item.content, // Ensure content is not nil
                          let sharedContent = try? JSONDecoder().decode(SharedContent.self, from: contentData), // Decode content
                          item.category == category else {
                        return nil
                    }
                    
                    // Handle different content cases
                    switch sharedContent {
                    case .imageURL(let imageURL), .url(let imageURL): // Handle both .imageURL and .url cases
                        let thumbnailName = "thumbnail_" + imageURL.lastPathComponent
                        return thumbnails.first(where: { $0.lastPathComponent == thumbnailName })
                    default:
                        return nil
                    }
                }
                
                return categoryThumbnails
            } catch {
                print("Failed to fetch thumbnails: \(error)")
                return []
            }
        }

        func getFullImageURL(for thumbnailURL: URL) -> URL? {
            let fileName = thumbnailURL.lastPathComponent.replacingOccurrences(of: "thumbnail_", with: "")
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
                print("Error accessing shared container")
                return nil
            }
            return containerURL.appendingPathComponent(fileName)
        }
    
    func addCategory(_ category: String) {
            guard !categories.contains(category) else { return }
            categories.append(category) // Updates the @Published property
    }
    
    func deleteItem(_ item: SharedItem) {
        guard let container = container else { return }
        let context = container.mainContext
        
        context.delete(item)
        
        do {
            try context.save()
            fetchItems()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }
    
    func deleteImage(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            
            // Trigger UI update by re-fetching and updating items
            DispatchQueue.main.async {
                self.items = self.items.filter { item in
                    guard let content = item.content,
                          let sharedContent = try? JSONDecoder().decode(SharedContent.self, from: content) else {
                        return true
                    }
                    
                    switch sharedContent {
                    case .imageURL(let imageURL), .url(let imageURL):
                        return imageURL != url
                    default:
                        return true
                    }
                }
            }
        } catch {
            print("Failed to delete image: \(error)")
        }
    }
    
    func updateCategory(for thumbnailURL: URL, to newCategory: String) {
        guard let container = container else { return }
        let context = container.mainContext

        // Debug: Log the thumbnail URL being processed
        print("Updating category for thumbnail URL:", thumbnailURL.absoluteString)

        // Find the corresponding SharedItem
        if let item = items.first(where: { item in
            // Ensure content is not nil
            guard let content = item.content else {
                print("Item has no content")
                return false
            }

            // Decode the content into SharedContent
            guard let sharedContent = try? JSONDecoder().decode(SharedContent.self, from: content) else {
                print("Failed to decode SharedContent for item:", item)
                return false
            }

            // Match the thumbnail URL with the stored image URL
            switch sharedContent {
            case .imageURL(let imageURL), .url(let imageURL):
                let expectedThumbnailName = "thumbnail_" + imageURL.lastPathComponent
                let actualThumbnailName = thumbnailURL.lastPathComponent
                
                // Debug: Log the names being compared
                print("Expected Thumbnail Name:", expectedThumbnailName)
                print("Actual Thumbnail Name:", actualThumbnailName)
                
                return expectedThumbnailName == actualThumbnailName
            default:
                print("Unsupported content type")
                return false
            }
        }) {
            // Update the category
            item.category = newCategory

            // Save the changes to the context
            do {
                try context.save()
                fetchItems() // Refresh the items
                print("Category updated successfully to:", newCategory)
            } catch {
                print("Failed to update category:", error)
            }
        } else {
            print("No matching item found for the thumbnail URL")
        }
    }
    
    func updateCategoryforLinks(for url: URL, to newCategory: String) {
        guard let container = container else { return }
        let context = container.mainContext

        // Find the corresponding SharedItem
        if let item = items.first(where: { item in
            guard let content = item.content,
                  let sharedContent = try? JSONDecoder().decode(SharedContent.self, from: content) else {
                return false
            }

            switch sharedContent {
            case .url(let itemURL):
                return itemURL == url
            default:
                return false
            }
        }) {
            // Update the category
            item.category = newCategory

            // Save changes to the context
            do {
                try context.save()
                fetchItems() // Refresh the items
            } catch {
                print("Failed to update category:", error)
            }
        } else {
            print("No matching item found for the URL")
        }
    }
    
    func showCategoryPicker(for deletingCategory: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Select a Category",
                                      message: "Choose a category to move items to:",
                                      preferredStyle: .actionSheet)

        for category in categories where category != deletingCategory {
            alert.addAction(UIAlertAction(title: category, style: .default) { _ in
                self.deleteCategory(deletingCategory, withOption: .moveToCategory(category))
            })
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    func promptForCategoryDeletion(_ category: String, from viewController: UIViewController) {
        let alert = UIAlertController(title: "Delete Category",
                                      message: "What would you like to do with items in the '\(category)' category?",
                                      preferredStyle: .actionSheet)

        // Move to another category
        alert.addAction(UIAlertAction(title: "Move to Another Category", style: .default) { _ in
            self.showCategoryPicker(for: category, from: viewController)
        })

        // Move to Uncategorized
        alert.addAction(UIAlertAction(title: "Move to Uncategorized", style: .default) { _ in
            self.deleteCategory(category, withOption: .moveToUncategorized)
        })

        // Delete items
        alert.addAction(UIAlertAction(title: "Delete Items", style: .destructive) { _ in
            self.deleteCategory(category, withOption: .deleteItems)
        })

        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }
    
    func deleteCategory(_ category: String, withOption option: CategoryDeletionOption) {
        guard let container = container else { return }
        let context = container.mainContext

        // Filter items belonging to the category
        let itemsToDelete = items.filter { $0.category == category }

        switch option {
        case .moveToCategory(let newCategory):
            for item in itemsToDelete {
                item.category = newCategory
            }
        case .moveToUncategorized:
            for item in itemsToDelete {
                item.category = "General"
            }
        case .deleteItems:
            for item in itemsToDelete {
                context.delete(item)
            }
        }

        // Remove the category
        categories.removeAll { $0 == category }

        // Save changes
        do {
            try context.save()
            saveCategoriesToUserDefaults()
            fetchItems()
        } catch {
            print("Failed to delete category: \(error)")
        }
    }
}
