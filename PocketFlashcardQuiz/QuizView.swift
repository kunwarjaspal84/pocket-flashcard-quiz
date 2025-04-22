import SwiftUI
import CoreData

struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let deck: Deck
    @State private var currentCard: Card?
    @State private var showAnswer = false
    @State private var rating = 0
    @State private var difficultyFilter = "All"
    private let difficulties = ["All", "Beginner", "Intermediate", "Advanced"]
    
    var body: some View {
        VStack {
            Picker("Difficulty", selection: $difficultyFilter) {
                ForEach(difficulties, id: \.self) { level in
                    Text(level).tag(level)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if let card = currentCard {
                Text((showAnswer ? card.back : card.front) ?? "")
                    .font(.title)
                    .padding()
                
                if showAnswer {
                    Text("Rate your recall (0-5):")
                    Picker("Rating", selection: $rating) {
                        ForEach(0...5, id: \.self) { i in
                            Text("\(i)").tag(i)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Submit") {
                        SpacedRepetition.updateCard(card: card, rating: rating)
                        try? viewContext.save()
                        print("Updated Card: \(card.front), Mastery: \(card.mastery), Interval: \(card.interval), LastReviewed: \(card.lastReviewed?.description ?? "nil")")
                        nextCard()
                    }
                    .padding()
                    .disabled(rating == 0)
                } else {
                    Button("Show Answer") {
                        showAnswer = true
                    }
                    .padding()
                }
            } else {
                Text("No cards due for this difficulty")
                    .font(.title)
                    .foregroundStyle(.gray)
            }
        }
        .navigationTitle(deck.name ?? "Quiz")
        .onAppear {
            nextCard()
        }
    }
    
    private func nextCard() {
        let dueCards = SpacedRepetition.cardsDueToday(in: deck).filter { card in
            difficultyFilter == "All" || card.difficulty == difficultyFilter
        }
        currentCard = dueCards.randomElement()
        showAnswer = false
        rating = 0
        print("Deck \(deck.name ?? "Untitled"): \(dueCards.count) cards due out of \(deck.cards?.count ?? 0)")
    }
}

#Preview {
    QuizView(deck: Deck())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
