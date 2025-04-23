import SwiftUI
import CoreData

struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let deck: Deck
    let difficultyFilter: String
    
    @State private var currentCardIndex = 0
    @State private var showAnswer = false
    @State private var selectedScore: Int?
    @State private var showingInfo = false
    
    private let cards: [Card]
    
    init(deck: Deck, difficultyFilter: String) {
        self.deck = deck
        self.difficultyFilter = difficultyFilter
        let allCards = (deck.cards as? Set<Card> ?? []).sorted { $0.front ?? "" < $1.front ?? "" }
        self.cards = difficultyFilter == "All" ? allCards : allCards.filter { $0.difficulty == difficultyFilter }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#F0FFF4"), Color(hex: "#E6FFFD")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if cards.isEmpty {
                VStack {
                    Text("No cards available for this difficulty.")
                        .font(.system(.title2, design: .rounded))
                        .foregroundStyle(.gray)
                    Button("Back to Deck") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                VStack(spacing: 20) {
                    Text("Card \(currentCardIndex + 1) of \(cards.count)")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .shadow(color: Color(hex: "#87CEEB").opacity(0.3), radius: 4)
                        VStack {
                            Text(cards[currentCardIndex].front ?? "")
                                .font(.system(.title2, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding()
                            if showAnswer {
                                Text(cards[currentCardIndex].back ?? "")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    .frame(maxHeight: 200)
                    
                    if showAnswer {
                        Text("How well did you recall this?")
                            .font(.system(.subheadline, design: .rounded))
                        HStack(spacing: 8) {
                            ForEach(0..<6) { score in
                                Button(action: {
                                    selectedScore = score
                                    submitScore()
                                }) {
                                    Text("\(score)")
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(.white)
                                        .frame(width: 40, height: 40)
                                        .background(score == selectedScore ? .blue : .gray)
                                        .clipShape(Circle())
                                }
                            }
                        }
                    } else {
                        Button("Show Answer") {
                            showAnswer = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle(deck.name ?? "Quiz")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showingInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $showingInfo) {
            VStack(spacing: 20) {
                Text("Recall Score Guide")
                    .font(.system(.title2, design: .rounded))
                Text("0: No recall\n1-2: Poor recall\n3-4: Good recall\n5: Perfect recall")
                    .font(.system(.body))
                    .multilineTextAlignment(.center)
                Button("Close") {
                    showingInfo = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .onAppear {
            print("QuizView initialized with \(cards.count) cards, difficulty: \(difficultyFilter)")
        }
    }
    
    private func submitScore() {
        guard let score = selectedScore else { return }
        let card = cards[currentCardIndex]
        SpacedRepetition.updateCard(card, score: score, context: viewContext)
        print("Updated Card: \(card.front), Mastery: \(card.mastery), Interval: \(card.interval)")
        
        if currentCardIndex + 1 < cards.count {
            currentCardIndex += 1
            showAnswer = false
            selectedScore = nil
        } else {
            dismiss()
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let deck = Deck(context: context)
    deck.name = "Sample Deck"
    deck.createdAt = Date()
    let card = Card(context: context)
    card.front = "1+1"
    card.back = "2"
    card.difficulty = "Beginner"
    card.deck = deck
    return QuizView(deck: deck, difficultyFilter: "All")
        .environment(\.managedObjectContext, context)
}
