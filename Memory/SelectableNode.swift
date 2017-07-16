//
//  SelectableNode.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit

private extension CGFloat {
    static let defaultTouchDownScale: CGFloat = 0.9
}

private extension TimeInterval {
    static let touchDownDuration: TimeInterval = 0.15
    static let touchUpDuration: TimeInterval = 0.15
}

final class SelectableNode: SKNode {
    let touchDownScale: CGFloat
    let canSelect: (() -> Bool)?
    let onSelect: () -> Void

    init(
        wrapping node: SKNode,
        touchDownScale: CGFloat = .defaultTouchDownScale,
        canSelect: (() -> Bool)? = nil,
        onSelect: @escaping () -> Void
    ) {
        self.canSelect = canSelect
        self.onSelect = onSelect
        self.touchDownScale = touchDownScale
        super.init()
        isUserInteractionEnabled = true
        self.addChild(node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canSelect?() ?? true else {
            return
        }

        run(.scale(to: touchDownScale, duration: .touchDownDuration))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard canSelect?() ?? true else {
            return
        }

        run(.scale(to: 1, duration: .touchUpDuration))

        guard let touch = touches.first, let parent = self.parent else {
            return
        }

        let location = touch.location(in: parent)
        if self.calculateAccumulatedFrame().contains(location) {
            onSelect()
        }
    }
}


