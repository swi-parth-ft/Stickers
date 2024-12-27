import SwiftData
import Foundation

@MainActor
class SharedItemManager: ObservableObject {
    private var container: ModelContainer?

    @Published var items: [SharedItem] = []

    init() {
        initializeModelContainer()
        //fetchItems()
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
        
        let newItem = SharedItem(content: content, caption: caption)
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
    
    func fetchThumbnails() -> [URL] {
            guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.parthant.Stickers") else {
                print("Error accessing shared container")
                return []
            }
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: containerURL, includingPropertiesForKeys: nil)
                return fileURLs.filter { $0.lastPathComponent.hasPrefix("thumbnail_") } // Filter for thumbnails
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
}
