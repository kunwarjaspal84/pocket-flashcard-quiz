//
//  Deck+CoreDataProperties.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-21.
//
//

import Foundation
import CoreData


extension Deck {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Deck> {
        return NSFetchRequest<Deck>(entityName: "Deck")
    }

    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isHosted: Bool
    @NSManaged public var cards: NSSet?

}

// MARK: Generated accessors for cards
extension Deck {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: Card)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: Card)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}

extension Deck : Identifiable {

}
