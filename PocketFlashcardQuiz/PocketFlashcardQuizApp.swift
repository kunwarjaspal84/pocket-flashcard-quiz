//
//  PocketFlashcardQuizApp.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-19.
//

import SwiftUI

@main
struct PocketFlashcardQuizApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
