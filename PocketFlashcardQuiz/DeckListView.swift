import SwiftUI
import CoreData

struct DeckListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Deck.createdAt, ascending: false)])
    private var decks: FetchedResults<Deck>
    
    @State private var showingAddDeck = false
    
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
                                    QuizView(deck: deck)
                                            .environment(\.managedObjectContext, viewContext) // To be replaced
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(deck.name)
                                            .font(.system(.headline, design: .rounded))
                                            .foregroundStyle(.primary)
                                            .lineLimit(1)
                                        if let category = deck.category {
                                            Text(category)
                                                .font(.system(.subheadline))
                                                .foregroundStyle(.secondary)
                                                .lineLimit(1)
                                        }
                                        Text("Progress: 60%") // Placeholder
                                            .font(.system(.caption))
                                            .foregroundStyle(.blue)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .shadow(color: .init(hex: "#87CEEB").opacity(0.3), radius: 4)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    Button("Start Quiz") {
                        // Placeholder
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
                ToolbarItem(placement: .topBarTrailing) {
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
                    .sheet(isPresented: $showingAddDeck) {
                        AddDeckView()
                            .environment(\.managedObjectContext, viewContext)
                    }
                }
            }
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        var rgb: UInt64 = 0
        Scanner(string: hex.hasPrefix("#") ? String(hex.dropFirst()) : hex).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    DeckListView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
