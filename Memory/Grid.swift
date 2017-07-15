//
//  Grid.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import SpriteKit

struct Grid {
    let rows: Int
    let columns: Int
    
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
