//
//  SelectableNode.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit

final class SelectableNode: SKNode {
    let onSelect: () -> Void

    init(wrapping node: SKNode, onSelect: @escaping () -> Void) {
        self.onSelect = onSelect
        super.init()
        isUserInteractionEnabled = true
        self.addChild(node)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let parent = self.parent else {
            return
        }

        let location = touch.location(in: parent)
        if self.calculateAccumulatedFrame().contains(location) {
            onSelect()
        }
    }
}


