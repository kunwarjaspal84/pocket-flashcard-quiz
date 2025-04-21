//
//  QuizView.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-21.
//


import SwiftUI
import CoreData

struct QuizView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let deck: Deck
    
    @State private var currentCard: Card?
    @State private var isFlipped = false
    
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
                    if let card = currentCard {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white)
                                .shadow(color: .init(hex: "#87CEEB").opacity(0.3), radius: 4)
                            Text(isFlipped ? card.back : card.front)
                                .font(.system(.title2, design: .rounded))
                                .foregroundStyle(.primary)
                                .padding()
                                .rotation3DEffect(
                                    .degrees(isFlipped ? 180 : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                        .frame(height: 200)
                        .padding()
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                isFlipped.toggle()
                            }
                        }
                        
                        HStack(spacing: 16) {
                            Button("Correct") {
                                loadNextCard()
                            }
                            .font(.system(.headline, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            Button("Incorrect") {
                                loadNextCard()
                            }
                            .font(.system(.headline, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.red)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal)
                    } else {
                        Text("No cards available")
                            .font(.system(.title2))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle(deck.name)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadNextCard()
            }
        }
    }
    
    private func loadNextCard() {
        let cards = (deck.cards as? Set<Card>)?.filter { $0.mastery < 1.0 } ?? []
        currentCard = cards.randomElement()
        isFlipped = false
    }
}

#Preview {
    QuizView(deck: {
        let context = PersistenceController.preview.container.viewContext
        let deck = Deck(context: context)
        deck.name = "Test Deck"
        let card = Card(context: context)
        card.front = "Big"
        card.back = "Large"
        card.deck = deck
        return deck
    }())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}