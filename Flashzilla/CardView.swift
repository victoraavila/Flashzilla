//
//  CardView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

struct CardView: View {
    // We will hide the answer label by default and toggle its visibility whenever the card is tapped
    @State private var isShowingAnswer = false
    
    // Which card it is looking at
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.white) // Invisible in the Canvas, but this does matter on other screens
                // When we get a stack of cards, it will be problematic: since they are all white, they will kind of blend into each other on the screen. To solve this, add a shadow to the RoundedRectangle, so our white card will stand out against the white background. When we get a stack of cards, the shadows will be summed up.
                .shadow(radius: 10)
            
            VStack {
                Text(card.prompt)
                    .font(.largeTitle)
                    .foregroundStyle(.black) // Black is the default for Light Mode, but since this uses a white background it has to be black no matter what
                
                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundStyle(.secondary) // Slightly translucent/Grayish
                }
            }
            .padding(20) // Texts can't go to the very edge of the card
            .multilineTextAlignment(.center) // So everything aligns at the center
        }
        .frame(width: 450, height: 250) // The ZStack gets a precise size as well. This size is no accident: the smallest iPhones have a landscape width of abount 480 points, so this means our card is fully visible on all devices.
        // An .onTapGesture{} to toggle isShowingAnswer and reveal the answer.
        // In this instance, adding .onTapGesture{} works better than adding a Button, because we will add dragging as well and then solve the conflicts involving two gestures at the same time.
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

#Preview {
    CardView(card: .example) // The example given inside Card.swift
}
