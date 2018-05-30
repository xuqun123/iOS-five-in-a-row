//
//  GameOverScene.swift
//  FiveInARow
//
//  Created by QUN XU on 3/5/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    let gameOverLayer = SKNode()
    let restartButton = SKSpriteNode(imageNamed: "Restart")
    let blackWonLabel = SKLabelNode(fontNamed: "Chalkduster")
    let whiteWonLabel = SKLabelNode(fontNamed: "Chalkduster")
    let finalRoundWinner = SKLabelNode(fontNamed: "Chalkduster")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }

    override init(size: CGSize) {
        super.init(size: size)
        
        //set next game's first player
        if GameStartScene.gameMode == "Single" {
            if GameStartScene.firstPlayer == "Computer" {
                GameStartScene.firstPlayer = "Player"
                Player.playerColor = "Black"
            } else {
               GameStartScene.firstPlayer = "Computer"
               Player.playerColor = "White"
            }
        }

        self.backgroundColor = SKColor(red: 0.5, green:0.7, blue:0.99, alpha: 0.8)
        addChild(gameOverLayer)
        
        restartButton.size = CGSize(width: 100, height: 100)
        restartButton.position =  CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        restartButton.name = "Restart"
        gameOverLayer.addChild(restartButton)
        
        blackWonLabel.text = "Black Win: \(GameScene.blackWon)"
        blackWonLabel.fontSize = 30
        blackWonLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - 200)
        gameOverLayer.addChild(blackWonLabel)

        whiteWonLabel.text = "White Win: \(GameScene.whiteWon)"
        whiteWonLabel.fontSize = 30
        whiteWonLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 - 250)
        gameOverLayer.addChild(whiteWonLabel)
        
        finalRoundWinner.text = "\(GameScene.gameWinner) Win!"
        finalRoundWinner.fontSize = 45
        finalRoundWinner.fontColor = UIColor.red
        finalRoundWinner.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2 + 100)
        gameOverLayer.addChild(finalRoundWinner)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            //start transition to game start scene
            if (touchedNode.name == "Restart") {
                GameScene.gameWinner = ""
    
                let gameStartScene = GameStartScene(size: self.size)
                let transition = SKTransition.doorsCloseVertical(withDuration: 1.0)
                gameStartScene.scaleMode = .aspectFill
                self.scene!.view?.presentScene(gameStartScene, transition: transition)
            }
        }
    }
}
