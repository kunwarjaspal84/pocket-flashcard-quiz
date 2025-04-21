import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        PersistenceController.createSampleData(context: viewContext)
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
        
        if !inMemory {
            let context = container.viewContext
            if !UserDefaults.standard.bool(forKey: "hasAddedSampleData") {
                PersistenceController.createSampleData(context: context)
                UserDefaults.standard.set(true, forKey: "hasAddedSampleData")
            }
        }
    }
    
    private static func createSampleData(context: NSManagedObjectContext) {
        let deck1 = Deck(context: context)
        deck1.id = UUID()
        deck1.name = "Test Vocabulary"
        deck1.category = "General"
        deck1.createdAt = Date()
        
        let card1 = Card(context: context)
        card1.id = UUID()
        card1.front = "Big"
        card1.back = "Large"
        card1.tags = "Vocabulary"
        card1.mastery = 0.0
        card1.interval = 1.0
        card1.deck = deck1
        
        let deck2 = Deck(context: context)
        deck2.id = UUID()
        deck2.name = "Spanish"
        deck2.category = "Language"
        deck2.createdAt = Date()
        
        let card2 = Card(context: context)
        card2.id = UUID()
        card2.front = "Hola"
        card2.back = "Hello"
        card2.tags = "Vocabulary"
        card2.mastery = 0.0
        card2.interval = 1.0
        card2.deck = deck2
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
