import SwiftUI
import CoreData

struct DeckListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Deck.createdAt, ascending: false)])
    private var decks: FetchedResults<Deck>
    
    @State private var showingAddDeck = false
    @State private var showingEditDeck = false
    @State private var deckToEdit: Deck?
    @State private var deckToDelete: Deck?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [.init(hex: "#E6E6FA"), .init(hex: "#D8BFD8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Quizzes today: 00")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    
                    DeckGridView(decks: decks, onEdit: { deck in
                        deckToEdit = deck
                        showingEditDeck = true
                    }, onDelete: { deck in
                        deckToDelete = deck
                    })
                    
                    Button("Start Quiz") {
                        // Placeholder for random deck quiz
                    }
                    .font(.system(.headline, design: .rounded))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.init(hex: "#FF69B4"), .init(hex: "#800080")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 4)
                    .padding()
                }
            }
            .navigationTitle("Flashcards")
            .toolbar {
                Button(action: {
                    showingAddDeck = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.blue)
                        .clipShape(Circle())
                }
            }
            .sheet(isPresented: $showingAddDeck) {
                AddDeckView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .sheet(isPresented: $showingEditDeck) {
                editDeckContent()
            }
            .alert("Delete Deck", isPresented: Binding(
                get: { deckToDelete != nil },
                set: { if !$0 { deckToDelete = nil } }
            )) {
                Button("Delete", role: .destructive) {
                    if let deck = deckToDelete {
                        viewContext.delete(deck)
                        try? viewContext.save()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to delete this deck?")
            }
        }
    }
    
    @ViewBuilder
    private func editDeckContent() -> some View {
        if let deck = deckToEdit {
            AddDeckView(deck: deck)
                .environment(\.managedObjectContext, viewContext)
        } else {
            Text("No deck selected")
        }
    }
}

struct DeckGridView: View {
    let decks: FetchedResults<Deck>
    let onEdit: (Deck) -> Void
    let onDelete: (Deck) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(170), spacing: 16),
                    GridItem(.fixed(170), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(decks) { deck in
                    NavigationLink {
                        CardListView(deck: deck)
                            .environment(\.managedObjectContext, viewContext)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(deck.name ?? "Untitled")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            if let category = deck.category {
                                Text(category)
                                    .font(.system(.subheadline))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Text("Progress: \(deckProgress(for: deck))")
                                .font(.system(.caption))
                                .foregroundStyle(.blue)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .init(hex: "#87CEEB").opacity(0.3), radius: 4)
                    }
                    .contextMenu {
                        if !deck.isHosted {
                            Button("Edit") {
                                onEdit(deck)
                            }
                            Button("Delete", role: .destructive) {
                                onDelete(deck)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func deckProgress(for deck: Deck) -> String {
        let cards = deck.cards as? Set<Card> ?? []
        let averageMastery = cards.map { $0.mastery }.reduce(0.0, +) / Double(max(cards.count, 1))
        return "\(Int(averageMastery * 100))%"
    }
}

#Preview {
    DeckListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
