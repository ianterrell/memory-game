//
//  GameScene.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit
import GameplayKit

private extension String {
    static var cardBack = "cardBack"
}

private extension CGFloat {
    static var backButtonOffset: CGFloat = 5
    static var gridPadding: CGFloat = 20
}

class GameScene: SKScene {
    let grid: Grid
    
    let backButton: SKSpriteNode
    let gridNode: GridNode
    
    init(grid: Grid, size: CGSize) {
        self.grid = grid
        
        backButton = SKSpriteNode(imageNamed: "backButton")
        backButton.anchorPoint = .zero
        
        gridNode = GridNode(grid: grid, size: .zero)
        
        super.init(size: size)
        
        scaleMode = .resizeFill
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        addChild(backButton)
        addChild(gridNode)
        positionNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        positionNodes()
    }
    
    func positionNodes() {
        let backButtonSize = CGSize(width: backButton.size.width + .backButtonOffset,
                                    height: backButton.size.height + .backButtonOffset)
        
        // Back button at top left
        backButton.position = CGPoint(x: .backButtonOffset, y: size.height - backButtonSize.height)
        
        // Grid occupying center
        gridNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        var gridHeight = size.height
        if fullScreenWouldIntersectBackButton(with: backButton.size) {
            gridHeight -= 2*backButtonSize.height
        }
        gridNode.size = CGSize(width: size.width, height: gridHeight)
    }
    
    func fullScreenWouldIntersectBackButton(with backButtonSize: CGSize) -> Bool {
        let fullScreenSize = grid.size(withCardSize: GridNode.referenceCard.size, padding: .gridPadding, fitting: size)
        let gridRect = CGRect(origin: CGPoint(x: size.width/2 - fullScreenSize.width/2,
                                              y: size.height/2 - fullScreenSize.height/2),
                              size: fullScreenSize)
        let backButtonRect = CGRect(origin: CGPoint(x: 0, y: size.height - backButtonSize.height), size: backButtonSize)
        return gridRect.intersects(backButtonRect)
    }
}

final class GridNode: SKNode {
    static let referenceCard = SKSpriteNode(imageNamed: .cardBack)
    
    let grid: Grid
    let cards: SKNode
    
    var size: CGSize {
        didSet {
            xScale = grid.scale(withCardSize: GridNode.referenceCard.size, padding: .gridPadding, fitting: size)
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
                let card = SKSpriteNode(imageNamed: .cardBack)
                card.anchorPoint = .zero
                card.position = CGPoint(x: .gridPadding + CGFloat(column) * (card.size.width + .gridPadding),
                                        y: .gridPadding + CGFloat(row) * (card.size.height + .gridPadding))
                cards.addChild(card)
            }
        }
        
        let gridSize = grid.size(withCardSize: GridNode.referenceCard.size, padding: .gridPadding)
        cards.position = CGPoint(x: -gridSize.width/2, y: -gridSize.height/2)
        self.addChild(cards)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
