import Foundation
import CoreData

class DeckFetcher {
    static let shared = DeckFetcher()
    private let jsonURL = URL(string: "https://kunwarjaspal84.github.io/flashcard-decks/decks.json")!
    
    struct HostedDeck: Codable {
        let id: String
        let name: String
        let category: String?
        let url: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case category
            case url
        }
    }
    
    func fetchHostedDecks(context: NSManagedObjectContext, completion: @escaping (Result<Void, Error>) -> Void) {
        print("Fetching JSON from \(jsonURL)")
        URLSession.shared.dataTask(with: jsonURL) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response: \(response.debugDescription)")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid HTTP response"])))
                return
            }
            
            print("HTTP status code: \(httpResponse.statusCode)")
            guard httpResponse.statusCode == 200 else {
                print("HTTP error: Status code \(httpResponse.statusCode)")
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP status code \(httpResponse.statusCode)"])))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let jsonString = String(data: data, encoding: .utf8) ?? "Unable to decode JSON"
                print("Received JSON: \(jsonString)")
                let hostedDecks = try JSONDecoder().decode([HostedDeck].self, from: data)
                context.perform {
                    for hostedDeck in hostedDecks {
                        let fetchRequest: NSFetchRequest<Deck> = Deck.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "name == %@ AND isHosted == true", hostedDeck.name)
                        fetchRequest.fetchLimit = 1
                        
                        if let existingDeck = try? context.fetch(fetchRequest).first {
                            print("Hosted deck \(hostedDeck.name) already exists, skipping")
                            continue
                        }
                        
                        let deck = Deck(context: context)
                        deck.id = UUID()
                        deck.name = hostedDeck.name
                        deck.category = hostedDeck.category
                        deck.isHosted = true
                        deck.createdAt = Date()
                        
                        self.fetchCards(for: deck, csvURL: hostedDeck.url, context: context) { result in
                            switch result {
                            case .success:
                                do {
                                    try context.save()
                                    print("Saved hosted deck: \(hostedDeck.name)")
                                } catch {
                                    print("Error saving hosted deck \(hostedDeck.name): \(error)")
                                }
                            case .failure(let error):
                                print("Error fetching cards for \(hostedDeck.name): \(error)")
                                context.delete(deck)
                            }
                        }
                    }
                    completion(.success(()))
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func fetchCards(for deck: Deck, csvURL: String, context: NSManagedObjectContext, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: csvURL) else {
            print("Invalid CSV URL: \(csvURL)")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid CSV URL"])))
            return
        }
        
        print("Fetching CSV from \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("CSV network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let status = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("CSV HTTP error: Status code \(status)")
                completion(.failure(NSError(domain: "", code: status, userInfo: [NSLocalizedDescriptionKey: "CSV HTTP status code \(status)"])))
                return
            }
            
            guard let data = data, let csvString = String(data: data, encoding: .utf8) else {
                print("No CSV data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No CSV data received"])))
                return
            }
            
            print("Received CSV:\n\(csvString)")
            context.perform {
                let lines = csvString.components(separatedBy: .newlines).filter { !$0.isEmpty }
                for (index, line) in lines.enumerated() where index > 0 {
                    let columns = line.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    guard columns.count >= 2 else {
                        print("Skipping invalid CSV line: \(line)")
                        continue
                    }
                    
                    let card = Card(context: context)
                    card.id = UUID()
                    card.front = columns[0]
                    card.back = columns[1]
                    card.tags = columns.count > 2 ? columns[2] : nil
                    card.difficulty = columns.count > 3 ? columns[3] : "Beginner"
                    card.mastery = 0.0
                    card.interval = 0.0
                    card.lastReviewed = nil
                    card.deck = deck
                }
                completion(.success(()))
            }
        }.resume()
    }
}
