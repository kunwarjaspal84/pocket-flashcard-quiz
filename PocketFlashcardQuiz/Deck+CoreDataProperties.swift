//
//  Deck+CoreDataProperties.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-19.
//

import Foundation
import CoreData

extension Deck {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Deck> {
        return NSFetchRequest<Deck>(entityName: "Deck")
    }
    
    @NSManaged public var id: UUID?
    @NSManaged public var name: String
    @NSManaged public var category: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var cards: NSSet?
}

extension Deck : Identifiable {
}
