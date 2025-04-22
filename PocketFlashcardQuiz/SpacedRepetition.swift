import Foundation

struct SpacedRepetition {
    static func updateCard(_ card: Card, quality: Int) {
        guard quality >= 0 && quality <= 5 else { return }
        
        let currentMastery = card.mastery
        let currentInterval = card.interval
        
        // Update mastery (0.0 to 1.0)
        let masteryDelta = Double(quality - 3) * 0.1
        card.mastery = min(max(currentMastery + masteryDelta, 0.0), 1.0)
        
        // Update interval (days)
        let newInterval: Double
        if quality >= 3 {
            if currentInterval == 0 {
                newInterval = 1 // First review: 1 day
            } else if currentInterval == 1 {
                newInterval = 6 // Second review: 6 days
            } else {
                let easeFactor = 1.3 + (card.mastery * 0.7)
                newInterval = currentInterval * easeFactor
            }
        } else {
            newInterval = 1 // Reset interval on poor performance
        }
        card.interval = newInterval
        
        // Update lastReviewed
        card.lastReviewed = Date()
        print("Updated Card: \(card.front), Mastery: \(card.mastery), Interval: \(card.interval), LastReviewed: \(card.lastReviewed?.description ?? "nil")")
    }
    
    static func isCardDue(_ card: Card) -> Bool {
        if card.lastReviewed == nil || card.interval == 0 {
            print("Card \(card.front) is due: lastReviewed=\(card.lastReviewed?.description ?? "nil"), interval=\(card.interval)")
            return true
        }
        let intervalDays = card.interval
        guard let lastReviewed = card.lastReviewed,
              let nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(intervalDays), to: lastReviewed) else {
            print("Card \(card.front) is due: invalid lastReviewed or date calculation")
            return true
        }
        let isDue = Date() >= nextReviewDate
        print("Card \(card.front) due check: lastReviewed=\(lastReviewed), interval=\(intervalDays), nextReview=\(nextReviewDate), isDue=\(isDue)")
        return isDue
    }
    
    static func cardsDueToday(in deck: Deck) -> [Card] {
        let cards = deck.cards as? Set<Card> ?? []
        let dueCards = cards.filter { isCardDue($0) }
        print("Deck \(deck.name ?? "Untitled"): \(dueCards.count) cards due out of \(cards.count)")
        return Array(dueCards)
    }
}
