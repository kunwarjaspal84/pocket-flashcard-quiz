import SwiftUI
import CoreData

struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let deck: Deck
    @State private var currentCard: Card?
    @State private var showAnswer = false
    @State private var cardsToReview: [Card] = []
    @State private var currentIndex = 0
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if let error = errorMessage {
                Text("Error: \(error)")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .padding()
            } else if cardsToReview.isEmpty {
                Text("No cards due for review")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding()
            } else if let card = currentCard {
                VStack(spacing: 20) {
                    Text(deck.name ?? "Untitled")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(showAnswer ? card.back ?? "" : card.front ?? "")
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(radius: 4)
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                    
                    if showAnswer {
                        HStack(spacing: 10) {
                            ForEach(0...5, id: \.self) { quality in
                                Button(action: {
                                    rateCard(quality: quality)
                                }) {
                                    Text("\(quality)")
                                        .font(.system(.headline, design: .rounded))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(quality >= 3 ? .blue : .red)
                                        .foregroundStyle(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        Button("Show Answer") {
                            showAnswer = true
                        }
                        .font(.system(.headline, design: .rounded))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
        }
        .background(
            LinearGradient(
                colors: [.init(hex: "#E6E6FA"), .init(hex: "#D8BFD8")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle("Quiz")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("End Quiz") {
                    dismiss()
                }
            }
        }
        .onAppear {
            loadCards()
        }
    }
    
    private func loadCards() {
        cardsToReview = SpacedRepetition.cardsDueToday(in: deck)
        currentIndex = 0
        currentCard = cardsToReview.isEmpty ? nil : cardsToReview[0]
    }
    
    private func rateCard(quality: Int) {
        guard let card = currentCard else { return }
        SpacedRepetition.updateCard(card, quality: quality)
        
        do {
            try viewContext.save()
        } catch {
            errorMessage = "Failed to save card: \(error.localizedDescription)"
            print("Error saving card: \(error)")
            return
        }
        
        currentIndex += 1
        if currentIndex < cardsToReview.count {
            currentCard = cardsToReview[currentIndex]
            showAnswer = false
        } else {
            currentCard = nil
            cardsToReview = []
        }
    }
}

#Preview {
    QuizView(deck: Deck(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
