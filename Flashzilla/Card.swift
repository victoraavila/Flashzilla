//
//  Card.swift
//  Flashzilla
//
//  Created by Víctor Ávila on 26/08/24.
//

import Foundation

// Here, we're gonna store a String for the prompt and a String for the answer. We'll also add an example cards as a static property so we can preview and prototype.
struct Card {
    var prompt: String
    var answer: String
    
    static let example = Card(prompt: "Who played the 13th Doctor in Doctor Who?", answer: "Jodie Whittaker")
}
