//
//  GameViewController.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let grid = Grid(rows: 3, columns: 4)
        let grid = Grid(rows: 5, columns: 2)
//        let grid = Grid(rows: 4, columns: 4)
//        let grid = Grid(rows: 4, columns: 5)
        
        let scene = GameScene(grid: grid, size: skView.frame.size)
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        #if DEBUG
            skView.showsFPS = true
        #endif
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
