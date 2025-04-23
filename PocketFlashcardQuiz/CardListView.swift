import SwiftUI
import CoreData

struct CardListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var deck: Deck
    
    @FetchRequest private var cards: FetchedResults<Card>
    @State private var editMode: EditMode = .inactive
    @State private var selectedCards: Set<Card> = []
    @State private var showingAddCard = false
    @State private var showingEditDeck = false
    
    init(deck: Deck) {
        self.deck = deck
        self._cards = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Card.front, ascending: true)],
            predicate: NSPredicate(format: "deck == %@", deck),
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#E6E6FA"), Color(hex: "#D8BFD8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                List {
                    if deck.isHosted {
                        HStack {
                            Text("Hosted")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.orange)
                                .clipShape(Capsule())
                            Spacer()
                        }
                    }
                    ForEach(cards) { card in
                        CardRowView(
                            card: card,
                            isSelected: selectedCards.contains(card),
                            editMode: editMode,
                            onSelect: {
                                if editMode.isEditing {
                                    if selectedCards.contains(card) {
                                        selectedCards.remove(card)
                                    } else {
                                        selectedCards.insert(card)
                                    }
                                }
                            }
                        )
                    }
                    .onDelete(perform: deck.isHosted ? nil : deleteCards)
                }
                .listStyle(.plain)
                .environment(\.editMode, $editMode)
            }
            .navigationTitle(deck.name ?? "Untitled")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !deck.isHosted {
//                        Button(action: {
//                            showingEditDeck = true
//                        }) {
//                            Image(systemName: "pencil")
//                                .font(.system(size: 16, weight: .bold))
//                                .foregroundStyle(.white)
//                                .padding(8)
//                                .background(.blue)
//                                .clipShape(Circle())
//                        }
                        if !cards.isEmpty {
                            Button(action: {
                                editMode = editMode.isEditing ? .inactive : .active
                                selectedCards.removeAll()
                            }) {
                                Text(editMode.isEditing ? "Done" : "Edit")
                            }
                        }
                        Button(action: {
                            showingAddCard = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(8)
                                .background(.blue)
                                .clipShape(Circle())
                        }
                    }
                }
                if editMode.isEditing && !selectedCards.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            deleteSelectedCards()
                            editMode = .inactive
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(deck: deck)
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingEditDeck) {
                AddDeckView(deck: deck)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                print("CardListView appeared for deck: \(deck.name ?? "Untitled"), isHosted: \(deck.isHosted)")
                print("Cards fetched: \(cards.count)")
                for card in cards {
                    print("Card: front=\(card.front), back=\(card.back), difficulty=\(card.difficulty ?? "nil"), tags=\(card.tags ?? "nil")")
                }
            }
        }
    }
    
    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            offsets.map { cards[$0] }.forEach(viewContext.delete)
            try? viewContext.save()
            print("Deleted cards at offsets: \(offsets)")
        }
    }
    
    private func deleteSelectedCards() {
        withAnimation {
            selectedCards.forEach(viewContext.delete)
            try? viewContext.save()
            selectedCards.removeAll()
            print("Deleted \(selectedCards.count) selected cards")
        }
    }
}

struct CardRowView: View {
    let card: Card
    let isSelected: Bool
    let editMode: EditMode
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            if editMode.isEditing {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .blue : .gray)
                    .onTapGesture {
                        onSelect()
                    }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(card.front ?? "")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                Text(card.back ?? "")
                    .font(.system(.subheadline))
                    .foregroundStyle(.secondary)
                if let tags = card.tags, !tags.isEmpty {
                    Text(tags)
                        .font(.system(.caption))
                        .foregroundStyle(.blue)
                }
                if let difficulty = card.difficulty {
                    Text(difficulty)
                        .font(.system(.caption))
                        .foregroundStyle(.purple)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            if editMode.isEditing {
                onSelect()
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let deck = Deck(context: context)
    deck.name = "Sample Deck"
    deck.createdAt = Date()
    deck.isHosted = false
    let card = Card(context: context)
    card.front = "1+1"
    card.back = "2"
    card.difficulty = "Beginner"
    card.tags = "math"
    card.deck = deck
    return CardListView(deck: deck)
        .environment(\.managedObjectContext, context)
}
