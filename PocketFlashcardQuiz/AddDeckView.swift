import SwiftUI
import CoreData

struct AddDeckView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var category = ""
    private var deck: Deck?
    
    init(deck: Deck? = nil) {
        self.deck = deck
        if let deck = deck {
            _name = State(initialValue: deck.name ?? "")
            _category = State(initialValue: deck.category ?? "")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Deck Name", text: $name)
                TextField("Category (Optional)", text: $category)
            }
            .navigationTitle(deck == nil ? "New Deck" : "Edit Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveDeck()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveDeck() {
        let targetDeck = deck ?? Deck(context: viewContext)
        targetDeck.name = name
        targetDeck.category = category.isEmpty ? nil : category
        targetDeck.createdAt = Date()
        targetDeck.id = UUID()
        targetDeck.isHosted = false
        
        do {
            try viewContext.save()
            print("Saved deck: \(name), isHosted: \(targetDeck.isHosted)")
        } catch {
            print("Error saving deck: \(error)")
        }
    }
}

#Preview {
    AddDeckView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
