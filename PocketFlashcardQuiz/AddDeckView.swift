//
//  AddDeckView.swift
//  PocketFlashcardQuiz
//
//  Created by Kunwardeep Singh on 2025-04-19.
//

import SwiftUI
import CoreData

struct AddDeckView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var category: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Deck Details")) {
                    TextField("Name", text: $name)
                    TextField("Category (optional)", text: $category)
                }
            }
            .navigationTitle("New Deck")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newDeck = Deck(context: viewContext)
                        newDeck.id = UUID()
                        newDeck.name = name.isEmpty ? "Untitled" : name
                        newDeck.category = category.isEmpty ? nil : category
                        newDeck.createdAt = Date()
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            print("Error saving deck: \(error)")
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddDeckView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
