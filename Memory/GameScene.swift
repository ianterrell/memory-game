//
//  GameScene.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit

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

final class GameScene: SKScene, GridDelegate {
    let grid: Grid
    var game: Game
    weak var gameDelegate: GameDelegate?
    
    let backButton: SKNode
    let gridNode: GridNode

    var firstSelected: (index: Int, node: CardNode)?
    
    init(grid: Grid, gameDelegate: GameDelegate) {
        self.grid = grid
        self.game = Game(grid: grid)
        self.gameDelegate = gameDelegate
        
        let backButtonSprite = SKSpriteNode(imageNamed: "backButton")
        backButtonSprite.anchorPoint = .zero
        backButton = SelectableNode(wrapping: backButtonSprite) { [weak gameDelegate] in
            gameDelegate?.goBack()
        }
        
        gridNode = GridNode(grid: grid, size: .zero)
        
        super.init(size: .zero)

        gridNode.delegate = self
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

    func selectCard(at index: Int, node: CardNode) {
        guard !node.isShowing else {
            return
        }

        node.flip(to: game.card(at: index))

        guard let firstSelected = firstSelected else {
            self.firstSelected = (index: index, node: node)
            return
        }

        self.firstSelected = nil

        let isMatch = game.select(first: firstSelected.index, second: index)
        if !isMatch {
            let wait = SKAction.wait(forDuration: 1)
            let flip = SKAction.run {
                firstSelected.node.flipToBack()
                node.flipToBack()
            }
            run(SKAction.sequence([wait, flip]))
        }
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
        let fullScreenSize = grid.size(withCardSize: CardNode.cardBackTexture.size(), padding: .gridPadding, fitting: size)
        let gridRect = CGRect(origin: CGPoint(x: size.width/2 - fullScreenSize.width/2,
                                              y: size.height/2 - fullScreenSize.height/2),
                              size: fullScreenSize)
        let backButtonRect = CGRect(origin: CGPoint(x: 0, y: size.height - backButtonSize.height), size: backButtonSize)
        return gridRect.intersects(backButtonRect)
    }
}

protocol GridDelegate: class {
    func selectCard(at index: Int, node: CardNode)
}

final class GridNode: SKNode {
    let grid: Grid
    let cards: SKNode
    weak var delegate: GridDelegate?
    
    var size: CGSize {
        didSet {
            setScale(grid.scale(withCardSize: CardNode.cardBackTexture.size(), padding: .gridPadding, fitting: size))
        }
    }
    
    init(grid: Grid, size: CGSize) {
        self.grid = grid
        self.size = size
        self.cards = SKNode()
        
        super.init()
        
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let card = CardNode()
                card.anchorPoint = .zero
                card.position = CGPoint(x: .gridPadding + CGFloat(column) * (card.size.width + .gridPadding),
                                        y: .gridPadding + CGFloat(row) * (card.size.height + .gridPadding))
                let index = row * grid.columns + column
                let selectable = SelectableNode(wrapping: card) { [unowned self] in
                    self.delegate?.selectCard(at: index, node: card)
                }
                cards.addChild(selectable)
            }
        }
        
        let gridSize = grid.size(withCardSize: CardNode.cardBackTexture.size(), padding: .gridPadding)
        cards.position = CGPoint(x: -gridSize.width/2, y: -gridSize.height/2)
        self.addChild(cards)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class CardNode: SKSpriteNode {
    var isShowing = false
    static let cardBackTexture = SKTexture(imageNamed: .cardBack)

    init() {
        super.init(texture: CardNode.cardBackTexture, color: .clear, size: CardNode.cardBackTexture.size())
    }

    func flip(to card: Card) {
        texture = SKTexture(card: card)
        isShowing = true
    }

    func flipToBack() {
        texture = CardNode.cardBackTexture
        isShowing = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SKTexture {
    convenience init(card: Card) {
        self.init(imageNamed: SKTexture.imageName(for: card))
    }

    static func imageName(for card: Card) -> String {
        switch card {
        case 0: return "cardCow"
        case 1: return "cardHen"
        case 2: return "cardHorse"
        case 3: return "cardPig"
        case 4: return "cardBat"
        case 5: return "cardCat"
        case 6: return "cardGhostDog"
        case 7: return "cardSpider"
        case 8: return "cardUnicorn"
        case 9: return "cardUnicow"
        default:
            fatalError("No asset defined for card \(card)")
        }
    }
}
