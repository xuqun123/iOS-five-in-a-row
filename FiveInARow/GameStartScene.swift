//
//  GameStartScene.swift
//  FiveInARow
//
//  Created by QUN XU on 8/5/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//

import SpriteKit

class GameStartScene: SKScene {
    static var gameMode = "Multiple"
    static var firstPlayer = "Computer"
    static var difficulty = "Easy"
        
    let gameStartLayer = SKNode()
    let background = SKSpriteNode(imageNamed: "Game Start")
    let singlePlayerButton = SKLabelNode(fontNamed: "Chalkduster")
    let multiPlayersButton = SKLabelNode(fontNamed: "Chalkduster")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        background.position = CGPoint(x: self.frame.size.width/2 , y: self.frame.size.height/2)
        background.size = size
        addChild(background)
        
        addChild(gameStartLayer)
        
        singlePlayerButton.text = "Single Player"
        singlePlayerButton.fontSize = 40
        singlePlayerButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - 40)
        singlePlayerButton.name = "Single"
        singlePlayerButton.fontColor = UIColor.black
        gameStartLayer.addChild(singlePlayerButton)
        
        multiPlayersButton.text = "Multiple Player"
        multiPlayersButton.fontSize = 40
        multiPlayersButton.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 + 40)
        multiPlayersButton.fontColor = UIColor.black
        multiPlayersButton.name = "Multiple"
        gameStartLayer.addChild(multiPlayersButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            //start transition to game scene
            if (touchedNode.name == "Multiple") {
                multiPlayersButton.alpha = 0.6
                multiPlayersButton.fontColor = UIColor.blue
                GameScene.gameWinner = ""
                GameStartScene.gameMode = "Multiple"
                
//                let level = Level()
                let gameScene = GameScene(size: self.size)
//                gameScene.addSprites(level: level)
                
                let transition = SKTransition.doorsOpenVertical(withDuration: 1.5)
                gameScene.scaleMode = .aspectFill
                self.scene!.view?.presentScene(gameScene, transition: transition)
            } else if (touchedNode.name == "Single") {
                singlePlayerButton.alpha = 0.6
                singlePlayerButton.fontColor = UIColor.blue
                GameScene.gameWinner = ""
                GameStartScene.gameMode = "Single"
                GameStartScene.difficulty = "Easy"
                
                let alert = UIAlertController(title: "Please select a difficulty level", message: nil, preferredStyle: .alert)
                let easyAlertAction = UIAlertAction(title: "Easy", style: .default) { _ in
                    GameStartScene.difficulty = "Easy"
//                    let level = Level()
                    let gameScene = GameScene(size: self.size)
//                    gameScene.addSprites(level: level)
                    
                    let transition = SKTransition.doorsOpenVertical(withDuration: 0.8)
                    gameScene.scaleMode = .aspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }
                let hardAlertAction = UIAlertAction(title: "Hard", style: .default) { _ in
                    GameStartScene.difficulty = "Hard"
//                    let level = Level()
                    let gameScene = GameScene(size: self.size)
//                    gameScene.addSprites(level: level)
                    
                    let transition = SKTransition.doorsOpenVertical(withDuration: 0.8)
                    gameScene.scaleMode = .aspectFill
                    self.scene!.view?.presentScene(gameScene, transition: transition)
                }

                alert.addAction(easyAlertAction)
                alert.addAction(hardAlertAction)
                view?.window?.rootViewController?.present(alert, animated: false)
            }
        }
    }
}
