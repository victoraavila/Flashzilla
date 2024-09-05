//
//  CardView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

// Currently, there is no visual distinction between swiping right or left (between correct answer and wrong answer, respectively)
// We will solve this in 2 ways:
// 1. For a phone with default settings, swiping right will make the card green or red before fading away. The folks with Color Blindness will set the brightness of the cards changing a little bit, but it won't be clear which side is each.
// 2. For a phone with differentiateWithoutColor enabled, we'll leave the cards white and show some extra information on the UI over the background

struct CardView: View {
    // Tracking whether should we use colors when swiping or not
    // We will use this information for both .fill() and .background(). We have to do this for both because when the card starts to fade out the background color starts to bleed through the fill.
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    
    @State private var offset = CGSize.zero
    
    @State private var isShowingAnswer = false
    
    let card: Card
    
    var removal: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
//                .fill(.white)
                // The white fill opacity will be similar to the opacity we added to the ZStack, except we'll use 1 - offset.width/50 instead of 2 - offset.width/50. This way, the card will start becoming colored straight away at the beginning of the movement (instead of only when 50 points away).
                .fill(
                    accessibilityDifferentiateWithoutColor
                    ? .white
                    : .white
                        .opacity(1 - Double(abs(offset.width/50)))
                )
                // We'll change the background to green or red depending on the Gesture movement, then we'll make white fill from above fade out as the drag movement gets larger
                .background(
                    accessibilityDifferentiateWithoutColor
                    ? nil // There will be no background
                    : RoundedRectangle(cornerRadius: 25)
                        .fill(offset.width > 0 ? .green : .red)
                )
                .shadow(radius: 10)
            
            VStack {
                Text(card.prompt)
                    .font(.largeTitle)
                    .foregroundStyle(.black)
                
                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 50)))
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        removal?()
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

#Preview {
    CardView(card: .example)
}
