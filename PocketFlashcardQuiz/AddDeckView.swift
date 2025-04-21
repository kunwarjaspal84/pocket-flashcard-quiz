import SwiftUI
import CoreData

struct AddDeckView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var category: String
    private let deck: Deck?
    
    init(deck: Deck? = nil) {
        self.deck = deck
        self._name = State(initialValue: deck?.name ?? "")
        self._category = State(initialValue: deck?.category ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Deck Details")) {
                    TextField("Name", text: $name)
                    TextField("Category (optional)", text: $category)
                }
            }
            .navigationTitle(deck == nil ? "New Deck" : "Edit Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let targetDeck = deck ?? Deck(context: viewContext)
                        if deck == nil {
                            targetDeck.id = UUID()
                            targetDeck.createdAt = Date()
                        }
                        targetDeck.name = name.isEmpty ? "Untitled" : name
                        targetDeck.category = category.isEmpty ? nil : category
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Error saving deck: \(error)")
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddDeckView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
