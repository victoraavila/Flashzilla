//
//  ContentView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    var body: some View {
        ZStack {
            Image(.background)
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    ForEach(0..<cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                            .stacked(at: index, in: cards.count)
                    }
                }
                
                // Adding some UI to make it clear which side is positive and which is negative for users with Color Blindness
                // The outer ZStack allows us to have both the background and the card stack overlapping. We'll use this to put Buttons in the Stack so the users can se which side is good.
                if accessibilityDifferentiateWithoutColor {
                    VStack {
                        Spacer()
                        
                        // All the Images in this Stack will be pushed to the very bottom of the screen
                        HStack {
                            Image(systemName: "xmark.circle") // The wrong side of things
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                            
                            Spacer()
                            
                            Image(systemName: "checkmark.circle") // The correct side of things
                                .padding()
                                .background(.black.opacity(0.7))
                                .clipShape(.circle)
                        }
                        // Modifiers for the HStack
                        .foregroundStyle(.white)
                        .font(.largeTitle)
                        .padding()
                    }
                }
            }
        }
    }
    
    func removeCard(at index: Int) {
        cards.remove(at: index)
    }
}

#Preview {
    ContentView()
}
