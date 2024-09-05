//
//  ContentView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

// By using Foundation, SwiftUI and Combine, we can build a Timer to add a little pressure to the user
// There is a tiny bug that requires some extra work to fix: when the app is suspended, the timer will run for a few seconds in the background and then pause automatically until the apps come back. To solve this, we can detect whether the app is in the foreground or in the background and pause or restart our timer appropriately. With this change, the timer will automatically pause when the app moves to the background.
// We will display the timer by adding a Text with a darker background color to make sure it is clearly visible.

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(y: offset * 10)
    }
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @State private var cards = Array<Card>(repeating: .example, count: 10)
    
    // For the first part of the Timer, we will create 2 new properties: the timer itself (which will fire once a second) and a timeRemaining property (from which we subtract one every time the timer fires). This allows us to show how many seconds remain in the current app run.
    @State private var timeRemaining = 100 // 100 seconds to start
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Using the main thread
    // Instead of using date subtraction, we will just subtract from timeRemaining as it is simpler.
    
    // Storing whether the app is currently active
    // We will also consider the app inactive if the player has gone through their full deck of flash cards
    @Environment(\.scenePhase) var scenePhase // This tells whether the app is active or inactive in terms of visibility
    @State private var isActive = true
    
    var body: some View {
        ZStack {
            Image(.background)
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
        .onReceive(timer) { time in
            // Exit immediately if isActive == false
            guard isActive else { return }
            
            // This makes our timer count down to 0
            if timeRemaining > 0 { // Just to make sure we never get negative numbers
                timeRemaining -= 1
            }
        }
        
        // Tracking the scene phase changing
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                isActive = true
            } else {
                isActive = false
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
