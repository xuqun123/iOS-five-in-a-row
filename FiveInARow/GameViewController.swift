//
//  GameViewController.swift
//  FiveInARow
//
//  Created by LIU FEI on 24/3/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
//    var scene: GameScene!
    var startScene: GameStartScene!
//    var level: Level!
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait, .portraitUpsideDown]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        let skView = view as! SKView
        skView.isMultipleTouchEnabled = false
        
        startScene = GameStartScene(size: skView.bounds.size)
        startScene.scaleMode = .aspectFill
        
        // Present the scene.
        skView.presentScene(startScene)
        
        // Create and configure the scene.
        //scene = GameScene(size: skView.bounds.size)
        //scene.scaleMode = .aspectFill
        //initialize level
        //level = Level()
        //scene.level = level
        // Present the scene.
        //skView.presentScene(scene)
        //beginGame()
    }
    
//    func beginGame() {
//        shuffle()
//    }
//    
//    func shuffle() {
//        level = Level()
//        scene.addSprites(level: level)
//    }
}
