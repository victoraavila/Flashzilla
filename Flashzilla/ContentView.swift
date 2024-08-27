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

struct ContentView: View {
    var body: some View {
        CardView(card: .example)
    }
}

#Preview {
    ContentView()
}
