//
//  Grid.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit
import GameplayKit

typealias Card = Int

struct Game {
    /// Model the game state as an array of optional cards, where nil means the card
    /// has been removed.
    private var state: [(card: Card, matched: Bool)]

    /// The game is over when all cards have been removed.
    var isOver: Bool {
        return state.first(where: { $0.matched == false }) == nil
    }

    init(grid: Grid) {
        state = grid.shuffledCards().map { (card: $0, matched: false) }
    }

    func card(at index: Int) -> Card {
        return state[index].card
    }

    /// Select two cards by their indices. 
    /// This method updates the game state and returns whether or not the two cards match.
    mutating func select(first: Int, second: Int) -> Bool {
        if state[first] == state[second] {
            state[first].matched = true
            state[second].matched = true
            return true
        }

        return false
    }
}

struct Grid {
    let rows: Int
    let columns: Int
    
    var title: String {
        return "\(rows)x\(columns)"
    }

    func shuffledCards() -> [Card] {
        return Array(PairedCardGenerator(numPairs: rows * columns / 2)).shuffled()
    }
    
    func size(withCardSize cardSize: CGSize, padding: CGFloat) -> CGSize {
        return CGSize(
            width: CGFloat(columns) * (cardSize.width + padding) + padding,
            height: CGFloat(rows) * (cardSize.height + padding) + padding
        )
    }
    
    func size(withCardSize cardSize: CGSize, padding: CGFloat, fitting frameSize: CGSize) -> CGSize {
        let size = self.size(withCardSize: cardSize, padding: padding)
        let scale = self.scale(withCardSize: cardSize, padding: padding, fitting: frameSize)
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    func scale(withCardSize cardSize: CGSize, padding: CGFloat, fitting frameSize: CGSize) -> CGFloat {
        let gridSize = size(withCardSize: cardSize, padding: padding)
        return min(min(frameSize.width/gridSize.width, 1), min(frameSize.height/gridSize.height, 1))
    }
}

struct PairedCardGenerator: Sequence, IteratorProtocol {
    var count: Int
    var first = true

    init(numPairs: Int) {
        self.count = numPairs
    }

    mutating func next() -> Card? {
        guard count > 0 else {
            return nil
        }
        let card = count - 1
        if first {
            first = false
        } else {
            first = true
            count -= 1
        }
        return card
    }
}

extension Array where Element == Card {
    /// Return a new array of the same elements, shuffled.
    ///
    /// Uses the Fisher-Yates shuffle:
    /// https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle#The_modern_algorithm
    func shuffled() -> [Card] {
        var array = self
        guard count > 1 else {
            return array
        }

        for i in stride(from: count - 1, to: 1, by: -1) {
            let j = GKRandomDistribution(lowestValue: 0, highestValue: i).nextInt()
            (array[i], array[j]) = (array[j], array[i])
        }
        return array
    }
}
