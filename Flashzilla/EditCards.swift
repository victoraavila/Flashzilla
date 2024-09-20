//
//  EditCards.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 12/09/24.
//

import SwiftUI

// This will have:
// Its own card Array;
// Be wrapped in a NavigationStack so we can add a Done Button to dismiss the View;
// Have a list showing all existing cards;
// Add swipe to delete for those cards;
// Have a section at the top of the list so users can add a new card;
// Have methods to load and save data from UserDefaults.

// Before we use this View, we have to add code to ContentView so it shows this sheet on demand and also calls resetCards() when dismissed.
// You can attach a function to your sheet that will automatically be ran when the sheet is dismissed. This is not helpful when we are trying to pass back data from the sheet, but here it is perfect since we just want to call resetCards().

struct EditCards: View {
    // So we can dismiss the View
    @Environment(\.dismiss) var dismiss
    
    // To store the card Array, the question and the answer that is being typed now
    @State private var cards = [Card]()
    @State private var newPrompt = ""
    @State private var newAnswer = ""
    
    // Instantiating a CardStoreManager to read and save data
    let cardStoreManager = CardStoreManager()
    
    var body: some View {
        NavigationStack {
            List {
                Section("Add new card") {
                    // TextFields with binding to newPrompt and newAnswer
                    TextField("Prompt", text: $newPrompt)
                    TextField("Answer", text: $newAnswer)
                    Button("Add Card", action: addCard) // A new method
                }
                
                Section {
                    ForEach(0..<cards.count, id: \.self) { index in
                        VStack(alignment: .leading) {
                            Text(cards[index].prompt)
                                .font(.headline)
                            
                            Text(cards[index].answer)
                                .foregroundStyle(.secondary) // So it is more transparent on the screen
                        }
                    }
                    .onDelete(perform: removeCards) // A new method
                }
            }
            .navigationTitle("Edit Cards")
            .toolbar {
                Button("Done", action: done) // done is a new method
            }
            .onAppear {
                cards = cardStoreManager.loadData()
            }
        }
    }
    
    func done() {
        dismiss()
    }
    
    
    func addCard() {
        // Trimming whitespaces for neatness
        let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
        let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
        
        // If the question or answer is empty, quit now
        guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else { return }
        
        // If we're still here, create a new Card
        let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
        
        // Place the card at the beginning of the deck
        cards.insert(card, at: 0)
        
        cardStoreManager.saveData(cards: cards)
        
        // Clearing the fields
        newPrompt = ""
        newAnswer = ""
    }
    
    func removeCards(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        cardStoreManager.saveData(cards: cards)
    }
}

#Preview {
    EditCards()
}
