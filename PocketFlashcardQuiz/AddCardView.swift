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
    @State private var difficulty: String
    private let difficulties = ["Beginner", "Intermediate", "Advanced"]
    
    init(deck: Deck, card: Card? = nil) {
        self.deck = deck
        self.card = card
        if let card = card {
            _front = State(initialValue: card.front ?? "")
            _back = State(initialValue: card.back ?? "")
            _tags = State(initialValue: card.tags ?? "")
            _difficulty = State(initialValue: card.difficulty ?? "Beginner")
        } else {
            _front = State(initialValue: "")
            _back = State(initialValue: "")
            _tags = State(initialValue: "")
            _difficulty = State(initialValue: "Beginner")
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Front", text: $front)
                TextField("Back", text: $back)
                TextField("Tags (Optional)", text: $tags)
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(difficulties, id: \.self) { level in
                        Text(level).tag(level)
                    }
                }
            }
            .navigationTitle(card == nil ? "New Card" : "Edit Card")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCard()
                        dismiss()
                    }
                    .disabled(front.isEmpty || back.isEmpty)
                }
            }
        }
    }
    
    private func saveCard() {
        let targetCard = card ?? Card(context: viewContext)
        targetCard.front = front
        targetCard.back = back
        targetCard.tags = tags.isEmpty ? nil : tags
        targetCard.difficulty = difficulty
        targetCard.mastery = targetCard.mastery // Preserve existing
        targetCard.interval = targetCard.interval
        targetCard.lastReviewed = targetCard.lastReviewed
        targetCard.deck = deck
        if targetCard.id == nil {
            targetCard.id = UUID()
        }
        
        do {
            try viewContext.save()
            print("Saved card: front=\(front), difficulty=\(difficulty), ID=\(targetCard.id?.uuidString ?? "nil")")
        } catch {
            print("Error saving card: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddCardView(deck: Deck())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
