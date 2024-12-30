import SwiftData
import Foundation


@MainActor
class SharedItemManager: ObservableObject {
    private var container: ModelContainer?

    @Published var items: [SharedItem] = []
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
          //  fetchItems()
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
//    func fetchThumbnails() -> [URL] {
//            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
//                print("Error accessing shared container")
//                return []
//            }
//            do {
//                let fileURLs = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
//                return fileURLs.filter { $0.lastPathComponent.hasPrefix("thumbnail_") } // Filter for thumbnails
//            } catch {
//                print("Failed to fetch thumbnails: \(error)")
//                return []
//            }
//        }

        func getFullImageURL(for thumbnailURL: URL) -> URL? {
            let fileName = thumbnailURL.lastPathComponent.replacingOccurrences(of: "thumbnail_", with: "")
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
                print("Error accessing shared container")
                return nil
            }
            return containerURL.appendingPathComponent(fileName)
        }
    
    func addCategory(_ category: String) {
            // Add a new category if it doesn't already exist
            guard !categories.contains(category) else { return }
            categories.append(category)
        }
}
