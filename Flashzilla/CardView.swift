//
//  CardView.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import SwiftUI

struct BackgroundColor: ViewModifier {
    var offset: CGSize
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(offset.width >= 0
                          ? (offset.width > 0 ? Color.green : Color.white)
                          : Color.red)
            )
    }
}

struct CardView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var accessibilityDifferentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var accessibilityVoiceOverEnabled
    
    @State private var offset = CGSize.zero
    
    @State private var isShowingAnswer = false
    
    let card: Card
    
    var removal: (() -> Void)? = nil
    var keeping: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    accessibilityDifferentiateWithoutColor
                    ? .white
                    : .white
                        .opacity(1 - Double(abs(offset.width/50)))
                )
                .modifier(BackgroundColor(offset: offset))
                .shadow(radius: 10)
            
            VStack {
                // If accessibility is enabled, show question and answer in the same Text View in order to support VoiceOver.
                if accessibilityVoiceOverEnabled {
                    Text(isShowingAnswer ? card.answer : card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                } else {
                    Text(card.prompt)
                        .font(.largeTitle)
                        .foregroundStyle(.black)
                    
                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250)
        .rotationEffect(.degrees(offset.width / 5.0))
        .offset(x: offset.width * 5)
        .opacity(2 - Double(abs(offset.width / 50)))
        .accessibilityAddTraits(.isButton) // Adding a hint to the users that the card can be tapped (this will be read out as "Who played the 13th Doctor in Doctor Who? Button.").
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                }
                .onEnded { _ in
                    if offset.width > 100 {
                        removal?()
                    } else if offset.width < -100 {
                        keeping?()
                    } else {
                        offset = .zero
                    }
                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.bouncy, value: offset) // Offset means the drag off we have right now. We can use .default or .bouncy to get a little overshoot.
    }
}

#Preview {
    CardView(card: .example)
}
