//
//  GameScene.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit
import GameplayKit

private extension CGFloat {
    static var backButtonOffset: CGFloat = 5
    static var gridPadding: CGFloat = 20
}

class GameScene: SKScene {
    
    let backButton: SKSpriteNode
    let grid: GridNode
    
    override init(size: CGSize) {
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.anchorPoint = .zero
        
//        grid = GridNode(grid: Grid(rows: 3, columns: 4), size: .zero)
//        grid = GridNode(grid: Grid(rows: 5, columns: 2), size: .zero)
        grid = GridNode(grid: Grid(rows: 4, columns: 4), size: .zero)
//        grid = GridNode(grid: Grid(rows: 4, columns: 5), size: .zero)
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        backgroundColor = .white
        
        addChild(backButton)
        addChild(grid)
        positionNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        positionNodes()
    }
    
    func positionNodes() {
        let backButtonVerticalSpace = backButton.size.height + .backButtonOffset
        
        // Back button at top left
        backButton.position = CGPoint(x: .backButtonOffset, y: size.height - backButtonVerticalSpace)
        
        // Grid occupying center, adding top padding for node and equivalent bottom padding
        grid.position = CGPoint(x: size.width/2, y: size.height/2)
        grid.size = CGSize(width: size.width, height: size.height - 2*backButtonVerticalSpace)
    }
}

struct Grid {
    let rows: Int
    let columns: Int
    
    func size(withCardSize cardSize: CGSize) -> CGSize {
        return CGSize(
            width: CGFloat(columns) * (cardSize.width + .gridPadding) + .gridPadding,
            height: CGFloat(rows) * (cardSize.height + .gridPadding) + .gridPadding
        )
    }
}

final class GridNode: SKNode {
    static let referenceCard = SKSpriteNode(imageNamed: "cardBack")
    
    let grid: Grid
    let cards: SKNode
    
    var size: CGSize {
        didSet {
            let gridSize = grid.size(withCardSize: GridNode.referenceCard.size)
            xScale = min(min(size.width/gridSize.width, 1), min(size.height/gridSize.height, 1))
            yScale = xScale
        }
    }
    
    init(grid: Grid, size: CGSize) {
        self.grid = grid
        self.size = size
        self.cards = SKNode()
        
        super.init()
        
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let card = SKSpriteNode(imageNamed: "cardBack")
                card.anchorPoint = .zero
                card.position = CGPoint(x: .gridPadding + CGFloat(column) * (card.size.width + .gridPadding), y: .gridPadding + CGFloat(row) * (card.size.height + .gridPadding))
                cards.addChild(card)
            }
        }
        
        let gridSize = grid.size(withCardSize: GridNode.referenceCard.size)
        cards.position = CGPoint(x: -gridSize.width/2, y: -gridSize.height/2)
        self.addChild(cards)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
