import CoreData

class SpacedRepetition {
    static func cardsDueToday(in deck: Deck) -> [Card] {
        let cards = deck.cards as? Set<Card> ?? []
        let today = Calendar.current.startOfDay(for: Date())
        return cards.filter { card in
            guard let lastReviewed = card.lastReviewed else { return true }
            let interval = card.interval
            let nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(interval), to: lastReviewed) ?? today
            return nextReviewDate <= today
        }.sorted { $0.front ?? "" < $1.front ?? "" }
    }
    
    static func updateCard(_ card: Card, score: Int, context: NSManagedObjectContext) {
        let easeFactor = card.easeFactor > 0 ? card.easeFactor : 2.5
        let newMastery = min(card.mastery + Double(score) / 5.0, 1.0)
        let quality = max(0, min(score, 5))
        
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
        
        do {
            try context.save()
            print("Saved card: \(card.front), Mastery: \(card.mastery), Interval: \(card.interval)")
        } catch {
            print("Error saving card: \(error.localizedDescription)")
        }
    }
}
