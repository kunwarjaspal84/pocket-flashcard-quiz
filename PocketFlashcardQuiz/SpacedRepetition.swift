import Foundation
import CoreData

class SpacedRepetition {
    static func cardsDueToday(in deck: Deck) -> [Card] {
        let cards = deck.cards as? Set<Card> ?? []
        return cards.filter { card in
            guard let lastReviewed = card.lastReviewed else { return true }
            let interval = card.interval
            let nextReview = lastReviewed.addingTimeInterval(interval * 24 * 60 * 60)
            let isDue = Date() >= nextReview
            print("Card \(card.front) due check: lastReviewed=\(lastReviewed), interval=\(interval), nextReview=\(nextReview), isDue=\(isDue)")
            return isDue
        }
    }
    
    static func updateCard(card: Card, rating: Int) {
        let easeFactor = card.easeFactor > 0 ? card.easeFactor : 2.5
        let newMastery = min(card.mastery + Double(rating) / 5.0, 1.0)
        let quality = max(0, min(rating, 5))
        
        var newEaseFactor = easeFactor
        if quality >= 3 {
            let qualityDiff = 5 - quality
            let adjustment = 0.1 - Double(qualityDiff) * 0.08 + Double(qualityDiff) * 0.02
            newEaseFactor += adjustment
        } else {
            let qualityDouble = Double(quality)
            newEaseFactor = max(1.3, newEaseFactor - 0.8 + qualityDouble * 0.28)
        }
        
        let newInterval: Double
        if quality < 3 {
            newInterval = 1.0
        } else if card.interval == 0.0 {
            newInterval = quality == 3 ? 1.0 : quality == 4 ? 2.0 : 6.0
        } else {
            newInterval = card.interval * newEaseFactor
        }
        
        card.mastery = newMastery
        card.interval = newInterval
        card.easeFactor = newEaseFactor
        card.lastReviewed = Date()
    }
}
