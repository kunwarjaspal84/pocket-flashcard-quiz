//
//  Card+CoreDataProperties.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-19.
//

import Foundation
import CoreData

extension Card {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Card> {
        return NSFetchRequest<Card>(entityName: "Card")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var front: String
    @NSManaged public var back: String
    @NSManaged public var tags: String?
    @NSManaged public var mastery: Double
    @NSManaged public var lastReviewed: Date?
    @NSManaged public var interval: Double
    @NSManaged public var deck: Deck?
}

extension Card : Identifiable {
}
