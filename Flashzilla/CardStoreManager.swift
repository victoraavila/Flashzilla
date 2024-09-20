//
//  CardStoreManager.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 19/09/24.
//

import Foundation

class CardStoreManager: ObservableObject {
    // The URL to which the cards will be saved
    let savePath = URL.documentsDirectory.appending(path: "AddedCards")
    
    // Reading from the documents directory
    func loadData() -> [Card] {
        var cards: [Card]
        
        do {
            let data = try Data(contentsOf: savePath)
            cards = try JSONDecoder().decode([Card].self, from: data)
        } catch {
            cards = [Card]()
        }
        
        return cards
    }
    
    // Besides adding cards, we gotta have a way to save cards too. This will be called from inside addCard().
    func saveData(cards: [Card]) {
        do {
            let data = try JSONEncoder().encode(cards)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
}
