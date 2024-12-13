import SwiftData
import SwiftUI
import Foundation

@MainActor
class SharedItemManager: ObservableObject {
    private var container: ModelContainer?

    @Published var items: [SharedItem] = []

    init() {
        initializeModelContainer()
        fetchItems()
    }

    // Initialize the ModelContainer using App Group for shared storage
    func initializeModelContainer() {
        do {
            // Create the schema with SharedItem included
            let schema = Schema([SharedItem.self])

            // Configure the ModelContainer with App Group
            let configuration = ModelConfiguration("group.com.parthant.Stickers")

            // Initialize the container with the schema and configuration
            self.container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            print("Error initializing ModelContainer: \(error)")
        }
    }

    func fetchItems() {
        guard let container = container else { return }
        let context = container.mainContext
        
        do {
            // Create a FetchDescriptor for SharedItem
            let descriptor = FetchDescriptor<SharedItem>()
            let fetchedItems = try context.fetch(descriptor)
            
            // Map fetched items to ensure decoded content is used
            self.items = fetchedItems.map { item in
                return item
            }
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }


    func saveItem(content: SharedContent) {
        guard let container = container else { return }
        let context = container.mainContext
        
        let newItem = SharedItem(content: content)
        context.insert(newItem)
        
        do {
            // Save the new item to the context
            try context.save()
            fetchItems() // Refresh the list after saving
        } catch {
            print("Failed to save item: \(error)")
        }
    }
    
  
}
