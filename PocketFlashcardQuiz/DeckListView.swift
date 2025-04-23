import SwiftUI
import CoreData

struct DeckListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView {
            MyDecksView()
                .tabItem {
                    Label("My Decks", systemImage: "folder")
                }
            ExploreDecksView()
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
        }
        .onAppear {
            print("DeckListView appeared")
            DeckFetcher.shared.fetchHostedDecks(context: viewContext) { result in
                switch result {
                case .success:
                    print("Hosted decks fetched successfully")
                case .failure(let error):
                    print("Error fetching hosted decks: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct MyDecksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Deck.createdAt, ascending: false)],
        predicate: NSPredicate(format: "isHosted == false"),
        animation: .default
    ) private var decks: FetchedResults<Deck>
    
    @State private var showingAddDeck = false
    @State private var showingEditDeck = false
    @State private var deckToEdit: Deck?
    @State private var deckToDelete: Deck?
    @State private var selectedDeck: Deck?
    @State private var selectedDifficulty: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#E6E6FA"), Color(hex: "#D8BFD8")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Quizzes today: \(quizzesToday)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    
                    if decks.isEmpty {
                        Text("No decks yet. Add one to start!")
                            .font(.system(.title3, design: .rounded))
                            .foregroundStyle(.gray)
                    } else {
                        DeckGridView(
                            decks: decks,
                            onEdit: { deck in
                                deckToEdit = deck
                                showingEditDeck = true
                            },
                            onDelete: { deck in
                                deckToDelete = deck
                            },
                            onQuiz: { deck, difficulty in
                                print("Quiz started for deck: \(deck.name ?? "Untitled"), difficulty: \(difficulty)")
                                selectedDeck = deck
                                selectedDifficulty = difficulty
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("My Decks")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !decks.isEmpty {
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
                    }
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
            .navigationDestination(isPresented: Binding(
                get: { selectedDeck != nil && selectedDifficulty != nil },
                set: { if !$0 { selectedDeck = nil; selectedDifficulty = nil } }
            )) {
                if let deck = selectedDeck, let difficulty = selectedDifficulty {
                    QuizView(deck: deck, difficultyFilter: difficulty)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .onAppear {
                print("My Decks CoreData: \(decks.count) decks found")
                for deck in decks {
                    print("Deck: \(deck.name ?? "Untitled") (ID: \(deck.objectID), isHosted: \(deck.isHosted))")
                    let cards = deck.cards as? Set<Card> ?? []
                    for card in cards {
                        print("  Card: front=\(card.front), back=\(card.back), tags=\(card.tags ?? "nil"), mastery=\(card.mastery), interval=\(card.interval), lastReviewed=\(card.lastReviewed?.description ?? "nil")")
                    }
                }
            }
        }
    }
    
    private var quizzesToday: Int {
        decks.reduce(0) { count, deck in
            let dueCount = SpacedRepetition.cardsDueToday(in: deck).count
            print("Deck \(deck.name ?? "Untitled"): \(dueCount) quizzes today")
            return count + dueCount
        }
    }
    
    @ViewBuilder
    private func editDeckContent() -> some View {
        if let deck = deckToEdit {
            AddDeckView(deck: deck)
                .environment(\.managedObjectContext, viewContext)
        } else {
            List {
                ForEach(decks) { deck in
                    Button(deck.name ?? "Untitled") {
                        deckToEdit = deck
                    }
                }
            }
        }
    }
}

struct ExploreDecksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Deck.name, ascending: true)],
        predicate: NSPredicate(format: "isHosted == true"),
        animation: .default
    ) private var decks: FetchedResults<Deck>
    
    @State private var selectedDeck: Deck?
    @State private var selectedDifficulty: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "#F0FFF4"), Color(hex: "#E6FFFD")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    Text("Quizzes today: \(quizzesToday)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    
                    if decks.isEmpty {
                        Text("No hosted decks available. Check your connection!")
                            .font(.system(.title3, design: .rounded))
                            .foregroundStyle(.gray)
                    } else {
                        DeckGridView(
                            decks: decks,
                            onEdit: { _ in },
                            onDelete: { _ in },
                            onQuiz: { deck, difficulty in
                                print("Quiz started for deck: \(deck.name ?? "Untitled"), difficulty: \(difficulty)")
                                selectedDeck = deck
                                selectedDifficulty = difficulty
                            }
                        )
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Explore Decks")
            .navigationDestination(isPresented: Binding(
                get: { selectedDeck != nil && selectedDifficulty != nil },
                set: { if !$0 { selectedDeck = nil; selectedDifficulty = nil } }
            )) {
                if let deck = selectedDeck, let difficulty = selectedDifficulty {
                    QuizView(deck: deck, difficultyFilter: difficulty)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .onAppear {
                print("Explore Decks CoreData: \(decks.count) decks found")
                for deck in decks {
                    print("Hosted Deck: \(deck.name ?? "Untitled") (ID: \(deck.objectID), isHosted: \(deck.isHosted))")
                    let cards = deck.cards as? Set<Card> ?? []
                    for card in cards {
                        print("  Card: front=\(card.front), back=\(card.back), tags=\(card.tags ?? "nil"), mastery=\(card.mastery), interval=\(card.interval), lastReviewed=\(card.lastReviewed?.description ?? "nil")")
                    }
                }
            }
        }
    }
    
    private var quizzesToday: Int {
        decks.reduce(0) { count, deck in
            let dueCount = SpacedRepetition.cardsDueToday(in: deck).count
            print("Hosted Deck \(deck.name ?? "Untitled"): \(dueCount) quizzes today")
            return count + dueCount
        }
    }
}

struct DeckGridView: View {
    let decks: FetchedResults<Deck>
    let onEdit: (Deck) -> Void
    let onDelete: (Deck) -> Void
    let onQuiz: (Deck, String) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 150), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(decks) { deck in
                    DeckRowView(
                        deck: deck,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onQuiz: onQuiz
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct DeckRowView: View {
    let deck: Deck
    let onEdit: (Deck) -> Void
    let onDelete: (Deck) -> Void
    let onQuiz: (Deck, String) -> Void
    
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDifficulty: String = "All"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                    Text("Progress: \(deckProgress)")
                        .font(.system(.caption))
                        .foregroundStyle(.blue)
                }
            }
            HStack {
                Picker("Difficulty", selection: $selectedDifficulty) {
                    Text("All").tag("All")
                    Text("Beginner").tag("Beginner")
                    Text("Intermediate").tag("Intermediate")
                    Text("Advanced").tag("Advanced")
                }
                .pickerStyle(.menu)
                .font(.system(.caption))
                .onChange(of: selectedDifficulty) { newValue in
                    print("Difficulty changed for deck \(deck.name ?? "Untitled"): \(newValue)")
                }
                Spacer()
                Button(action: {
                    onQuiz(deck, selectedDifficulty)
                }) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.green)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color(hex: "#87CEEB").opacity(0.3), radius: 4)
        .contextMenu {
            if !deck.isHosted {
                Button("Delete", role: .destructive) {
                    onDelete(deck)
                }
            }
        }
    }
    
    private var deckProgress: String {
        let cards = deck.cards as? Set<Card> ?? []
        guard !cards.isEmpty else { return "0%" }
        let averageMastery = cards.map { $0.mastery }.reduce(0.0, +) / Double(cards.count)
        return "\(Int(averageMastery * 100))%"
    }
}

#Preview {
    DeckListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
