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

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isActive = true
    
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
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                            .stacked(at: index, in: cards.count)
                            .allowsHitTesting(index == cards.count - 1) // True if this is the last card.
                            .accessibilityHidden(index < cards.count - 1) // Hide all cards besides the one on top.
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
    }
    
    func removeCard(at index: Int) {
        // We need to add a guard check at the start of this removeCard(at:) since these Buttons continue on screen even after the last card is removed
        guard index >= 0 else { return }
        
        cards.remove(at: index)
        
        if cards.isEmpty {
            isActive = false
        }
    }
    
    func resetCards() {
        cards = Array<Card>(repeating: .example, count: 10)
        timeRemaining = 100
        isActive = true
    }
}

#Preview {
    ContentView()
}
