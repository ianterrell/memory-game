//
//  LobbyScene.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit

private extension CGFloat {
    static let titleSpacing: CGFloat = 65
    static let optionSpacing: CGFloat = 40
}

private extension UIFont {
    static let titleFont = boldSystemFont(ofSize: 32)
    static let optionFont = systemFont(ofSize: 24)
}

class LobbyScene: SKScene {
    
    let options: [Grid]
    
    let menuNode: SKNode
    let titleNode: SKLabelNode
    let optionsNode: SKNode
    
    init(options: [Grid], size: CGSize) {
        self.options = options
        
        self.menuNode = SKNode()
        self.titleNode = SKLabelNode(text: "Memory Game")
        self.optionsNode = SKNode()
        
        super.init(size: size)
        
        scaleMode = .resizeFill
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sceneDidLoad() {
        style(node: titleNode, with: .titleFont)
        titleNode.position = CGPoint(x: 0, y: -titleNode.frame.height / 2)
        menuNode.addChild(titleNode)

        for (i, option) in zip(options.indices,options) {
            let optionNode = SKLabelNode(text: option.title)
            style(node: optionNode, with: .optionFont)
            optionNode.position = CGPoint(x: 0, y: -CGFloat(i) * .optionSpacing)
            optionsNode.addChild(optionNode)
        }
        optionsNode.position = CGPoint(x: 0, y: -.titleSpacing)
        menuNode.addChild(optionsNode)

        addChild(menuNode)
        positionNodes()
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        positionNodes()
    }
    
    func positionNodes() {
        let menuSize = menuNode.calculateAccumulatedFrame()
        menuNode.position = CGPoint(x: size.width / 2, y: (size.height + menuSize.height) / 2)
    }
    
    func style(node: SKLabelNode, with font: UIFont, color: UIColor = .black) {
        node.fontColor = color
        node.fontName = font.fontName
        node.fontSize = font.pointSize
    }
}