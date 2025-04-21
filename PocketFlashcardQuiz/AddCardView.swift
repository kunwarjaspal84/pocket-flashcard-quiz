import SwiftUI
import CoreData

struct AddCardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let deck: Deck
    let card: Card?
    
    @State private var front: String
    @State private var back: String
    @State private var tags: String
    
    init(deck: Deck, card: Card? = nil) {
        self.deck = deck
        self.card = card
        self._front = State(initialValue: card?.front ?? "")
        self._back = State(initialValue: card?.back ?? "")
        self._tags = State(initialValue: card?.tags ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Front", text: $front)
                    TextField("Back", text: $back)
                    TextField("Tags (optional)", text: $tags)
                }
            }
            .navigationTitle(card == nil ? "New Card" : "Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let targetCard = card ?? Card(context: viewContext)
                        targetCard.id = targetCard.id ?? UUID()
                        targetCard.front = front
                        targetCard.back = back
                        targetCard.tags = tags.isEmpty ? nil : tags
                        targetCard.mastery = targetCard.mastery
                        targetCard.interval = targetCard.interval
                        targetCard.deck = deck
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Error saving card: \(error)")
                        }
                    }
                    .disabled(front.isEmpty || back.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddCardView(deck: {
        let context = PersistenceController.preview.container.viewContext
        let deck = Deck(context: context)
        deck.name = "Test Deck"
        return deck
    }())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
