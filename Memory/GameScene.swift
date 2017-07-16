//
//  GameScene.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit

private extension String {
    static let cardBack = "cardBack"
}

private extension CGFloat {
    static let backButtonOffset: CGFloat = 5
    static let gridPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 10
    static let cardTouchDownScale: CGFloat = 0.95
    static let highlightStartAlpha: CGFloat = 0.6
    static let highlightEndAlpha: CGFloat = 0.1
    static let highlightScale: CGFloat = 1.1
}

private extension TimeInterval {
    static let flipDuration: TimeInterval = 0.2
    static let highlightPulseDuration: TimeInterval = 1
    static let hideHighlightDuration: TimeInterval = 0.2
}

private extension UIColor {
    static let highlightColor = UIColor.cyan
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
            node.isSelected = true
            return
        }

        self.firstSelected = nil
        firstSelected.node.isSelected = false

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
        backButton.position = CGPoint(x: .backButtonOffset + backButtonSpriteSize.width / 2,
                                      y: size.height - .backButtonOffset - backButtonSpriteSize.height / 2)
        
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

        let cardSize = CardNode.cardBackTexture.size()
        let widthAndPadding = cardSize.width + .gridPadding
        let halfWidthAndPAdding = cardSize.width / 2 + .gridPadding
        let heightAndPadding = cardSize.height + .gridPadding
        let halfHeightAndPadding = cardSize.height / 2 + .gridPadding
        
        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                let card = CardNode()
                let index = row * grid.columns + column
                let selectable = SelectableNode(wrapping: card, touchDownScale: .cardTouchDownScale, canSelect: {
                    return !card.isShowing
                }, onSelect: { [unowned self] in
                    self.delegate?.selectCard(at: index, node: card)
                })
                selectable.position = CGPoint(x: halfWidthAndPAdding + CGFloat(column) * widthAndPadding,
                                              y: halfHeightAndPadding + CGFloat(row) * heightAndPadding)
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

final class CardNode: SKNode {
    var isShowing = false

    var highlightNode: SKNode?
    let cardNode: SKSpriteNode

    var isSelected = false {
        didSet {
            if isSelected {
                let node = makeHighlightNode()
                insertChild(node, at: 0)
                highlightNode = node
            } else {
                if let highlightNode = highlightNode {
                    highlightNode.run(.fadeOut(withDuration: .hideHighlightDuration)) {
                        self.removeChildren(in: [highlightNode])
                        self.highlightNode = nil
                    }
                }

            }
        }
    }

    static let cardBackTexture = SKTexture(imageNamed: .cardBack)

    override init() {
        cardNode = SKSpriteNode(texture: CardNode.cardBackTexture, color: .clear, size: CardNode.cardBackTexture.size())
        super.init()
        addChild(cardNode)
    }

    func flip(to card: Card) {
        flip(to: SKTexture(card: card))
        isShowing = true
    }

    func flipToBack() {
        flip(to: CardNode.cardBackTexture)
        isShowing = false
    }

    private func flip(to texture: SKTexture) {
        let scaleDown = SKAction.scaleX(to: 0, duration: .flipDuration / 2)
        let flip = SKAction.run { self.cardNode.texture = texture }
        let scaleUp = SKAction.scaleX(to: 1, duration: .flipDuration / 2)
        run(SKAction.sequence([scaleDown, flip, scaleUp]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeHighlightNode() -> SKNode {
        let pulse: [SKAction] = [
            .group([
                .fadeAlpha(to: .highlightStartAlpha, duration: 0),
                .scale(to: 1, duration: 0),
            ]),
            .group([
                .fadeAlpha(to: .highlightEndAlpha, duration: .highlightPulseDuration),
                .scale(to: .highlightScale, duration: .highlightPulseDuration),
            ]),
        ]

        let origin = CGPoint(x: -cardNode.size.width / 2, y: -cardNode.size.height / 2)
        let roundedRect = UIBezierPath(roundedRect: CGRect(origin: origin, size: cardNode.size),
                                       cornerRadius: .cardCornerRadius)
        let node = SKShapeNode(path: roundedRect.cgPath)
        node.fillColor = .highlightColor
        node.run(.repeatForever(.sequence(pulse)))
        return node
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
