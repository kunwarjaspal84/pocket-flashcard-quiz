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
                    .disableAutocorrection(true)
                TextField("Category (Optional)", text: $category)
                    .disableAutocorrection(true)
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
            print("Saved deck: \(name), isHosted: \(targetDeck.isHosted), ID: \(targetDeck.id?.uuidString ?? "nil")")
        } catch {
            print("Error saving deck: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddDeckView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
