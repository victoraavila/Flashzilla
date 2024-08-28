//
//  ContentView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

// In this project, users will see a card with some prompt text on whatever they want to learn (for example, "What's the capital city of Scotland?"). When they tap it, we'll reveal the answer.
// A sensible place to start most projects is to define the data model we want to work with: how does one card of information look like? If you want to take the app further, you can store statistics such as the number of times a card's been shown and the number of times a card was correct.
// In terms of showing the card in the UI, we'll have two Texts and a nice white card background behind them. Then, a little bit of padding, so text won't go edge to edge of the card. (A VStack inside a ZStack with a white rounded rectangle). Usually, flash cards are wider than they are high. Therefore, this app will work only in Landscape, which gives us more room to draw the cards.
// To force Landscape, go to blue icon Flashzilla > Targets > Flashzilla > Info > Delete Portrait options on Supported interface orientations (iPhone).
// Switch to Landscape Mode on the iOS Simulator by pressing Command + <- Arrow

// Our next step is to build a stack of those cards to represent the subject the user is learning.
// This stack will change as the app is being used: it will remove cards over time. So, it will be represented with @State. In the beginning we will use a stack of 10 example cards by calling Swift's Array init(repeating:count:), which takes one value and repeats it n times.

// For now, we will do as follows:
// 1. Our stack of cards will be placed inside a single ZStack, so we can place them partly overlapped with a 3D effect.
// 2. Around the ZStack, there will be a VStack. Later on, we will use it to add a timer above our cards.
// 3. Around the VStack, there will be another ZStack, so we can place the cards and timer on a background.
// The complex part is how to position the cards inside the ZStack so they have a slight overlapping. The best way to write SwiftUI code is to give messy calculations to methods or modifiers.
// In this case, we will create a stacked() method that takes a position in an Array and its length, and offsets a View by some amount based on this parameters. This way, each card will be a little further down the screen than the one before.
extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        // Calculating our offset: how far through we are in the deck
        let offset = Double(total - position)
        return self.offset(y: offset * 10) // self is the current View, which will be 10 points down as the position increases
    }
}

struct ContentView: View {
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    var body: some View {
        ZStack {
            // The background is found at: https://github.com/twostraws/HackingWithSwift/tree/main/SwiftUI/project17-files
            // Both pictures were added to the assets
            Image(.background)
                .resizable()
                .ignoresSafeArea() // So it goes edge to edge
            
            VStack {
                ZStack {
                    // We get a really thick shadow because many cards are overlapping: as the cards depth increases, the shadow increases
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            // This is a trailing closure that corresponds to the removal function inside CardView
                            // If we wrap the call to removeCard with a withAnimation call, then the other cards will automatically slide upwards
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                            .stacked(at: index, in: cards.count)
                    }
                }
            }
        }
    }
    
    // A method that handle the removal of a card, by taking an index of the cards Array
    // This is gonna be connected to the closure that needs to be passed in to CardView
    func removeCard(at index: Int) {
        cards.remove(at: index)
    }
}

#Preview {
    ContentView()
}
