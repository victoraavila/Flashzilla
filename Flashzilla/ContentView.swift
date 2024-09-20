//
//  ContentView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

// Our app is full of glitches that are worth addressing
// 1. It is possible to drag cards around when they aren't on the top (which confuses users that may have not seen the card yet);
// To fix this, we will use .allowsHitTesting() just after .stacked() so the card on top will be the only one we can drag around.

// 2. Our UI is messy when using VoiceOver: when using a real device, one can tap the background and hear "Background. Image.". Besides that, when swiping to the right it will read the text from all cards (even ones that aren't visible).
// To fix the background issue, we will set it as a decorative image (change Image(.background) to Image(decorative: "background").
// To fix the cards, we will use .accessibilityHidden() with a similar condition to the one we used in Glitch 1: every card with an index less than the top card should be hidden from the accessibility system.
// 2.1. Accessibility conflict with gestures: it is not apparent to users how they can control the app with VoiceOver (we don't tell the cards are Buttons, we don't read out the answers, users have no way to swipe the cards to the left or right).
// To fix Glitch 2.1., we'll make it clear our cards are tappable Buttons by adding .accessibilityAddTraits(.isButton) to the CardView's ZStack; also, we'll help the system to read both the answer and the question by detecting if accessibility is enabled in the iPhone (by checking the environment variable accessibilityVoiceOverEnabled) and if so, we'll have the question in one side of the card and the answer in the other; also, we'll make it easier to mark the card as right or wrong (the checkmark gets read out as a SF Symbol name) by replacing our Images with Buttons that actually remove the top card from the deck. We'll also provide a label and a hint so users get a better idea of what the Buttons do.

// 3. If you start to drag a card, but then release it, you can't tell what happened: is it removing it? Is it readding it? It just jumps back.
// To fix Glitch 3, we need to attach a Spring animation to our card, so it will slide back to the center. Let's add an .animation() to the end of CardView's ZStack.

// We will create a new View that lets users add new cards and see all of them.
// 1. We need to create an @State that controls whether our editing screen is visible.
// 2. Add a Button to flip the @State Bool to true just before the Buttons that are shown when accessibility is enabled.
// 3. The new EditCards will encode and decode a card Array to UserDefaults. So, we have to make Card conform to Codable.
// 4. Create the view EditCards.

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    // Now that we have the EditCards View, we can get rid of the example data and fill the cards at runtime
    @State private var cards = [Card]()
    @State private var showingEditScreen = false
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
    // The URL to which the cards will be saved
    let savePath = URL.documentsDirectory.appending(path: "AddedCards")
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Displaying the timer
                Text("Time: \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(.capsule)
                
                
                ZStack {
                    ForEach(cards) { card in
                        CardView(card: card, removal:
                            {
                                withAnimation {
                                    removeCard(at: getCardIndex(of: card))
                            }
                        }, keeping:
                            {
                                withAnimation {
                                    putCardAtTheEnd(at: getCardIndex(of: card))
                                }
                            }
                        )
                        .stacked(at: getCardIndex(of: card), in: cards.count)
                        .allowsHitTesting(getCardIndex(of: card) == cards.count - 1) // True if this is the last card.
                        .accessibilityHidden(getCardIndex(of: card) < cards.count - 1) // Hide all cards besides the one on top.
                    }
                }
                .allowsHitTesting(timeRemaining > 0)
                
                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(.capsule)
                }
            }
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button {
                            showingEditScreen = true
                        } label: {
                            Image(systemName: "plus.circle")
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                    }
                    
                    Spacer() // To push the HStack to the top
                }
                .foregroundStyle(.white)
                .font(.largeTitle)
                .padding()
                
                // Making these Buttons visible when either differentiateWithoutColor or voiceOver is enabled. For this, we added another environment property called accessibilityVoiceOverEnabled
                if accessibilityDifferentiateWithoutColor || accessibilityVoiceOverEnabled {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Button {
                                withAnimation {
                                    removeCard(at: cards.count - 1)
                                }
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .padding()
                                    .background(.black.opacity(0.7))
                                    .clipShape(.circle)
                            }
                            .accessibilityLabel("Wrong")
                            .accessibilityHint("Mark your answer as being incorrect.")
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    removeCard(at: cards.count - 1)
                                }
                            } label: {
                                Image(systemName: "checkmark.circle")
                                    .padding()
                                    .background(.black.opacity(0.7))
                                    .clipShape(.circle)
                            }
                            .accessibilityLabel("Correct")
                            .accessibilityHint("Mark your answer as being correct.")
                        }
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding()
                    }
                }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }
        }
        // When we are using .sheet(), we've got to give it a function that creates a View and returns it to be shown on the sheet
        // When we call EditCards(), we are using Syntactic Sugar: we are treating EditCards as a function and because of this Swift automatically calls its initializer. In practice, EditCards() = EditCards.init().
//        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) { // Calling resetCards() when dismissing
//            EditCards()
//        }
        // Following the above reasoning, we can pass EditCards.init() directly to the sheet
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init) // Call init when you are ready to go, and it will send the View back to the sheet. This approach only works because the EditCards' initializer expects no parameters. If it does, we have to use the above approach.
        
        // We also want to call resetCards() when the View first appears.
        .onAppear(perform: resetCards)
    }
    
    func getCardIndex(of card: Card) -> Int {
        for i in 0..<cards.count {
            if cards[i].id == card.id {
                return i
            }
        }
        return -1
    }
    
    func removeCard(at index: Int) {
        // We need to add a guard check at the start of this removeCard(at:) since these Buttons continue on screen even after the last card is removed
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func putCardAtTheEnd(at index: Int) {
        let newCard = Card(id: UUID(), prompt: cards[index].prompt, answer: cards[index].answer)
        cards.remove(at: index)
        cards.insert(newCard, at: 0)
    }
    
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData() // Getting data from UserDefaults every time
    }
    
    // We also need to read the cards' properties on demand
    // Reading from UserDefaults
    func loadData() {
        do {
            let data = try Data(contentsOf: savePath)
            cards = try JSONDecoder().decode([Card].self, from: data)
        } catch {
            cards = [Card]()
        }
    }
}

#Preview {
    ContentView()
}
