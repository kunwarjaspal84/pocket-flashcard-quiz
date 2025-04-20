import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Sample Deck
        let deck = Deck(context: viewContext)
        deck.id = UUID()
        deck.name = "Test Vocabulary"
        deck.category = "General"
        deck.createdAt = Date()
        
        // Sample Card
        let card = Card(context: viewContext)
        card.id = UUID()
        card.front = "Big"
        card.back = "Large"
        card.tags = "Vocabulary"
        card.mastery = 0.0
        card.interval = 1.0
        card.deck = deck
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PocketFlashcardQuiz")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
