//
//  GameViewController.swift
//  Memory
//
//  Created by Ian Terrell on 7/15/17.
//  Copyright © 2017 Ian Terrell. All rights reserved.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController {
    
    var skView: SKView {
        return view as! SKView
    }

    var lobby: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        let dimensions = [[3,4],[5,2],[4,4],[4,5]]
        let options = dimensions.map { Grid(rows: $0[0], columns: $0[1]) }
        lobby = LobbyScene(options: options, lobbyDelegate: self)

        skView.presentScene(lobby)
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

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: LobbyDelegate, GameDelegate {
    func selected(grid: Grid) {
        let game = GameScene(grid: grid, gameDelegate: self)
        skView.presentScene(game, transition: .presentGame)
    }

    func goBack() {
        skView.presentScene(lobby, transition: .hideGame)
    }
}

private extension SKTransition {
    static let presentGame = configure(doorsOpenHorizontal(withDuration: 0.5))
    static let hideGame = configure(doorsCloseHorizontal(withDuration: 0.5))

    private static func configure(_ transition: SKTransition) -> SKTransition {
        transition.pausesIncomingScene = false
        transition.pausesOutgoingScene = false
        return transition
    }
}
