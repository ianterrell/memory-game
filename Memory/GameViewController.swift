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
        
        let dimensions = [[3,4],[5,2],[4,4],[4,5]]
        let options = dimensions.map { Grid(rows: $0[0], columns: $0[1]) }
        let scene = LobbyScene(options: options, size: skView.frame.size)
        
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
