import SwiftUI
import CoreData

struct CardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let deck: Deck
    
    @FetchRequest private var cards: FetchedResults<Card>
    @State private var showingAddCard = false
    @State private var cardToDelete: Card?
    
    init(deck: Deck) {
        self.deck = deck
        self._cards = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Card.front, ascending: true)],
            predicate: NSPredicate(format: "deck == %@", deck)
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.init(hex: "#E6E6FA"), .init(hex: "#D8BFD8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                if cards.isEmpty {
                    Text("No cards in this deck")
                        .font(.system(.title2))
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(cards) { card in
                            CardRowView(card: card, isHosted: deck.isHosted)
                                .contextMenu {
                                    if !deck.isHosted {
                                        Button("Delete", role: .destructive) {
                                            cardToDelete = card
                                        }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle(deck.name ?? "")
            .toolbar {
                if !deck.isHosted {
                    Button(action: { showingAddCard = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(deck: deck)
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert("Delete Card", isPresented: Binding(
                get: { cardToDelete != nil },
                set: { if !$0 { cardToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let card = cardToDelete {
                        viewContext.delete(card)
                        try? viewContext.save()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this card?")
            }
        }
    }
}

struct CardRowView: View {
    let card: Card
    let isHosted: Bool
    
    var body: some View {
        NavigationLink {
            AddCardView(deck: card.deck!, card: isHosted ? nil : card)
                .environment(\.managedObjectContext, card.deck!.managedObjectContext!)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(card.front ?? "")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
                Text(card.back ?? "")
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                HStack {
                    Text("Tags: \(card.tags ?? "None")")
                        .font(.system(.caption))
                        .foregroundStyle(.blue)
                    Text("Difficulty: \(card.difficulty ?? "Unknown")")
                        .font(.system(.caption))
                        .foregroundStyle(.purple)
                }
            }
        }
    }
}

#Preview {
    CardListView(deck: {
        let context = PersistenceController.preview.container.viewContext
        let deck = Deck(context: context)
        deck.name = "Test Deck"
        let card = Card(context: context)
        card.front = "Big"
        card.back = "Large"
        card.tags = "Vocabulary"
        card.difficulty = "Beginner"
        card.deck = deck
        return deck
    }())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
