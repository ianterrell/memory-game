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

protocol GameDelegate: class {
    func goBack()
}

final class GameScene: SKScene {
    let grid: Grid
    weak var gameDelegate: GameDelegate?
    
    let backButton: SKNode
    let gridNode: GridNode
    
    init(grid: Grid, gameDelegate: GameDelegate) {
        self.grid = grid
        self.gameDelegate = gameDelegate
        
        let backButtonSprite = SKSpriteNode(imageNamed: "backButton")
        backButtonSprite.anchorPoint = .zero
        backButton = SelectableNode(wrapping: backButtonSprite) { [weak gameDelegate] in
            gameDelegate?.goBack()
        }
        
        gridNode = GridNode(grid: grid, size: .zero)
        
        super.init(size: .zero)
        
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
        let backButtonSpriteSize = backButton.calculateAccumulatedFrame()
        let backButtonSize = CGSize(width: backButtonSpriteSize.width + .backButtonOffset,
                                    height: backButtonSpriteSize.height + .backButtonOffset)
        
        // Back button at top left
        backButton.position = CGPoint(x: .backButtonOffset, y: size.height - backButtonSize.height)
        
        // Grid occupying center
        gridNode.position = CGPoint(x: size.width/2, y: size.height/2)
        
        var gridHeight = size.height
        if fullScreenWouldIntersectBackButton(with: backButtonSize) {
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
