//
//  GameScene.swift
//  FiveInARow
//
//  Created by LIU FEI on 24/3/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//


import SpriteKit
import GameplayKit

class GameScene: SKScene {
    static var blackWon = 0
    static var whiteWon = 0
    static var gameWinner = ""

    var level: Level!
//    var strategist: Strategist!
    var strategist: GKMinmaxStrategist!

    var gridSet = Array2D<ChessPiece>(columns: NumColumns, rows: NumRows)
//    var blackSet = Array2D<ChessPiece>(columns: NumColumns, rows: NumRows)
//    var whiteSet = Array2D<ChessPiece>(columns: NumColumns, rows: NumRows)

    let TileWidth: CGFloat = 30
    let TileHeight: CGFloat = 30.0
    var isBlack: Bool = true
    var firstComputerRound: Bool = true
//    var currentTurnPlayer: String = ""
    let gameLayer = SKNode()
    let chessPiecesLayer = SKNode()
    let currentTurnLabel = SKLabelNode(fontNamed: "Chalkduster")
    let difficultyLabel = SKLabelNode(fontNamed: "Chalkduster")
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) is not used in this app")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let background = SKSpriteNode(imageNamed: "Background")
        background.size = size
        addChild(background)
        
        addChild(gameLayer)
        
        let layerPosition = CGPoint(
            x: -TileWidth * CGFloat(NumColumns) / 2,
            y: -TileHeight * CGFloat(NumRows) / 2)
        chessPiecesLayer.position = layerPosition
        gameLayer.addChild(chessPiecesLayer)
        
        level = Level()
        if isBlack == true {
            if GameStartScene.gameMode == "Multiple" {
                currentTurnLabel.text = "Current Turn: Black"
                currentTurnLabel.fontColor = UIColor.black
            } else {
                if GameStartScene.firstPlayer == "Computer" {
                    level.currentPlayer = Player.allPlayers[1]
                } else {
                    level.currentPlayer = Player.allPlayers[0]
                }
                currentTurnLabel.text = "Current Turn: \(level.currentPlayer.value)"
                currentTurnLabel.fontColor = UIColor.black
            }
        } else {
            if GameStartScene.gameMode == "Multiple" {
                currentTurnLabel.text = "Current Turn: White"
                currentTurnLabel.fontColor = UIColor.white
            } else {
                if GameStartScene.firstPlayer == "Computer" {
                    level.currentPlayer = Player.allPlayers[1]
                } else {
                    level.currentPlayer = Player.allPlayers[0]
                }
                currentTurnLabel.text = "Current Turn: \(level.currentPlayer.value)"
                currentTurnLabel.fontColor = UIColor.white
            }
        }
        currentTurnLabel.fontSize = 18
        currentTurnLabel.position = CGPoint(x: 0, y: 250)
        gameLayer.addChild(currentTurnLabel)
        
        if GameStartScene.gameMode == "Single" {
            difficultyLabel.fontSize = 18
            difficultyLabel.position = CGPoint(x: 0, y: 200)
            difficultyLabel.text = GameStartScene.difficulty + " Mode"
            difficultyLabel.fontColor = UIColor.blue
            gameLayer.addChild(difficultyLabel)
        }

        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 3
        strategist.randomSource = GKARC4RandomSource()
        strategist.gameModel = level
        for column in 0 ..< NumColumns {
            for row in 0 ..< NumRows {
                let chessPieceType = ChessPieceType(rawValue: 1)
                let chessPiece = ChessPiece(column: column, row: row, chessPieceType: chessPieceType!)
                
                gridSet[column, row] = chessPiece
                gridSet[column, row]?.occupiedColor = ""
            }
        }
        addSprites()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            if touchedNode.name == "grid"
            {
                if let linkedChessPiece = self.linkedChessPiece(node: touchedNode) {
                    linkedChessPiece.isTouched = true
                    if isBlack == true {
                        let chessPieceType = ChessPieceType(rawValue: 2)
                        let chessPiece = ChessPiece(column: linkedChessPiece.column, row: linkedChessPiece.row, chessPieceType: chessPieceType!)
                        chessPiece.isTouched = true
                        self.addSprite(chessPiece: chessPiece, location: touchedNode.position, name: "black")
                        level.setOccupiedColor(row: linkedChessPiece.row, column: linkedChessPiece.column, color: "Black")
                        gridSet[linkedChessPiece.column, linkedChessPiece.row]?.occupiedColor = "Black"

                        isBlack = false
                        gameOverDetect(placedChessPiece: chessPiece)
                        
                        if GameStartScene.gameMode == "Multiple" {
                            currentTurnLabel.text = "Current Turn: White"
                            currentTurnLabel.fontColor = UIColor.white
                        } else {
                            level.currentPlayer = level.currentPlayer.opponent
                            currentTurnLabel.text = "Current Turn: \(level.currentPlayer.value)"
                            currentTurnLabel.fontColor = UIColor.white
                        }
                        firstComputerRound = false

                        if GameStartScene.gameMode == "Single"  {
                            if GameStartScene.difficulty == "Easy" {
                                computerPlayV1()
                            } else {
                                computerPlayV2()
                            }
                        }
                    } else {
                        let chessPieceType = ChessPieceType(rawValue: 3)
                        let chessPiece = ChessPiece(column: linkedChessPiece.column, row: linkedChessPiece.row, chessPieceType: chessPieceType!)
                        chessPiece.isTouched = true
                        self.addSprite(chessPiece: chessPiece, location: touchedNode.position, name: "white")
                        level.setOccupiedColor(row: linkedChessPiece.row, column: linkedChessPiece.column, color: "White")
                        gridSet[linkedChessPiece.column, linkedChessPiece.row]?.occupiedColor = "White"

                        isBlack = true
                        gameOverDetect(placedChessPiece: chessPiece)
                        
                        if GameStartScene.gameMode == "Multiple" {
                            currentTurnLabel.text = "Current Turn: Black"
                            currentTurnLabel.fontColor = UIColor.black
                        } else {
                            level.currentPlayer = level.currentPlayer.opponent
                            currentTurnLabel.text = "Current Turn: \(level.currentPlayer.value)"
                            currentTurnLabel.fontColor = UIColor.black
                        }
                        firstComputerRound = false
                        
                        if GameStartScene.gameMode == "Single"  {
                            if GameStartScene.difficulty == "Easy" {
                                computerPlayV1()
                            } else {
                                computerPlayV2()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func linkedChessPiece(node: SKNode) -> ChessPiece? {
        for i in 0..<NumColumns {
            for j in 0..<NumRows {
                let grid = gridSet[i, j]
                if let linkedNode = grid?.sprite {
                    if linkedNode.isEqual(to: node) {
                        return grid
                    }
                }
            }
        }
        return nil
    }
    
    func addSprite(chessPiece: ChessPiece, location: CGPoint, name: String) {
        let sprite = SKSpriteNode(imageNamed: chessPiece.chessPieceType.spriteName)
        sprite.size = CGSize(width: 25, height: 25)
        sprite.position = location
        sprite.name = name
        sprite.isUserInteractionEnabled = false
        chessPiecesLayer.addChild(sprite)
        chessPiece.sprite = sprite
        print("---------- adding \(sprite.name!): (\(chessPiece.row), \(chessPiece.column)) ----------")
        
        if sprite.name == "black" {
//            blackSet[chessPiece.column, chessPiece.row] = chessPiece
//            level.setOccupiedColor(row: chessPiece.row, column: chessPiece.column, color: "Black")
        } else if sprite.name == "white" {
//            whiteSet[chessPiece.column, chessPiece.row] = chessPiece
//            level.setOccupiedColor(row: chessPiece.row, column: chessPiece.column, color: "White")
        }
    }
    
    func addSprites() {
//        if GameStartScene.firstPlayer == "Computer" {
//            level.currentPlayer = Player.allPlayers[1]
//        } else {
//            level.currentPlayer = Player.allPlayers[0]
//        }
//        self.level = level
////        self.strategist.level = self.level
//        strategist.gameModel = level
        
        for i in 0..<NumColumns {
            for j in 0..<NumRows {
                if let chessPiece = gridSet[i, j] {
                    let sprite = SKSpriteNode(imageNamed: chessPiece.chessPieceType.spriteName)
                    sprite.size = CGSize(width: TileWidth, height: TileHeight)
                    sprite.position = pointFor(column: chessPiece.column, row: chessPiece.row)
                    sprite.name = "grid"
                    sprite.isUserInteractionEnabled = false
                    chessPiecesLayer.addChild(sprite)
                    chessPiece.sprite = sprite
                    chessPiece.occupiedColor = ""
                    gridSet[i, j] = chessPiece
                }
            }
        }
        if GameStartScene.gameMode == "Single" && level.currentPlayer.value == "Computer" {
            if GameStartScene.difficulty == "Easy" {
                computerPlayV1()
            } else {
                computerPlayV2()
            }
        }
    }
    
    func pointFor(column: Int, row: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(column)*TileWidth + TileWidth/2,
            y: CGFloat(row)*TileHeight + TileHeight/2)
    }

    func gameOverDetect(placedChessPiece: ChessPiece) {
        if placedChessPiece.chessPieceType.spriteName == "Black" {
            scanChessBoard(chessPieceSet: gridSet, targetChessPiece: placedChessPiece)
            
        } else if placedChessPiece.chessPieceType.spriteName == "White" {
            scanChessBoard(chessPieceSet: gridSet, targetChessPiece: placedChessPiece)
        }
    }
    
    func scanChessBoard(chessPieceSet: Array2D<ChessPiece>, targetChessPiece: ChessPiece) {
        let row = targetChessPiece.row
        let column = targetChessPiece.column
        
        //scan horizontal rows
        for i in 0..<NumColumns {
            if ConsecutiveFiveChessPieces(chessPieceSet: chessPieceSet, color: targetChessPiece.chessPieceType.spriteName, start: i, end: i + 5, row: row, column: nil) == true {
                print("\(targetChessPiece.chessPieceType.spriteName) Chess Win from \(row), \(i) to  \(row), \(i+5)")
                
                hightlightRowChessPieces(start: [row, i], chessColor: targetChessPiece.chessPieceType.spriteName)
                break
            }
        }
        
        //scan vertical columns
        for i in 0..<NumRows {
            if ConsecutiveFiveChessPieces(chessPieceSet: chessPieceSet, color: targetChessPiece.chessPieceType.spriteName, start: i, end: i + 5, row: nil, column: column) == true {
                print("\(targetChessPiece.chessPieceType.spriteName) Chess Win from \(i),  \(column) to from \(i+5),  \(column)")

                hightlightColumnChessPieces(start: [i, column], chessColor: targetChessPiece.chessPieceType.spriteName)
                break
            }
        }
        
        //scan diagonal line from bottom-left to top-right
        let bottomLeft = getBottomLeft(targetChessPiece: targetChessPiece)
        print("bottom-left: \(bottomLeft)")
        let topRight = getTopRight(targetChessPiece: targetChessPiece)
        print("top-right: \(topRight)")
        var startPoint = bottomLeft
        for _ in bottomLeft[0]..<(topRight[0]+1) {
            if ConsecutiveFromBottomLeftToTopRight(chessPieceSet: chessPieceSet, color: targetChessPiece.chessPieceType.spriteName, start: startPoint, max: topRight) == true {
                print("\(targetChessPiece.chessPieceType.spriteName) Chess Win from \(startPoint) to \(topRight)")
                
                hightlightBottomLeftToTopRightChessPieces(start: startPoint, chessColor: targetChessPiece.chessPieceType.spriteName)
                break
            }
            startPoint[0] += 1
            startPoint[1] += 1
        }
        
        //scan diagonal line from bottom-right to top-left
        let bottomRight = getBottomRight(targetChessPiece: targetChessPiece)
        print("bottom-right: \(bottomRight)")
        let topLeft = getTopLeft(targetChessPiece: targetChessPiece)
        print("top-left: \(topLeft)")
        startPoint = bottomRight
        for _ in bottomRight[0]..<(topLeft[0]+1) {
            if ConsecutiveFromBottomRightToTopLeft(chessPieceSet: chessPieceSet, color: targetChessPiece.chessPieceType.spriteName, start: startPoint, max: topLeft) == true {
                print("\(targetChessPiece.chessPieceType.spriteName) Chess Win from \(startPoint) to \(topLeft)")
                
                hightlightBottomRightToTopLeftChessPieces(start: startPoint, chessColor: targetChessPiece.chessPieceType.spriteName)
                break
            }
            startPoint[0] += 1
            startPoint[1] -= 1
        }
    }
    
    func hightlightRowChessPieces(start: Array<Int>, chessColor: String) {
        calculateWinTimes(chessColor: chessColor)
        
        for i in 0..<5 {
            var hightlightedChessPiece : ChessPiece?
            if chessColor == "Black" {
                hightlightedChessPiece = gridSet[start[1] + i, start[0]]
            } else {
                hightlightedChessPiece = gridSet[start[1] + i, start[0]]
            }
            
            if hightlightedChessPiece != nil {
                presentGameOverScene(targetChessPiece: hightlightedChessPiece!)
            }
        }
    }
    
    func hightlightColumnChessPieces(start: Array<Int>, chessColor: String) {
        calculateWinTimes(chessColor: chessColor)
        
        for i in 0..<5 {
            var hightlightedChessPiece : ChessPiece?
            if chessColor == "Black" {
                hightlightedChessPiece = gridSet[start[1], start[0] + i]
            } else {
                hightlightedChessPiece = gridSet[start[1], start[0] + i]
            }
            
            if hightlightedChessPiece != nil {
                presentGameOverScene(targetChessPiece: hightlightedChessPiece!)
            }
        }
    }
    
    func hightlightBottomLeftToTopRightChessPieces(start: Array<Int>, chessColor: String) {
        calculateWinTimes(chessColor: chessColor)
        
        for i in 0..<5 {
            var hightlightedChessPiece : ChessPiece?
            if chessColor == "Black" {
                hightlightedChessPiece = gridSet[start[1] + i, start[0] + i]
            } else {
                hightlightedChessPiece = gridSet[start[1] + i, start[0] + i]
            }
            
            if hightlightedChessPiece != nil {
                presentGameOverScene(targetChessPiece: hightlightedChessPiece!)
            }
        }
    }
    
    func hightlightBottomRightToTopLeftChessPieces(start: Array<Int>, chessColor: String) {
        calculateWinTimes(chessColor: chessColor)
        
        for i in 0..<5 {
            var hightlightedChessPiece : ChessPiece?
            if chessColor == "Black" {
                hightlightedChessPiece = gridSet[start[1] - i, start[0] + i]
            } else {
                hightlightedChessPiece = gridSet[start[1] - i, start[0] + i]
            }
            
            if hightlightedChessPiece != nil {
                presentGameOverScene(targetChessPiece: hightlightedChessPiece!)
            }
        }
    }
    
    func getBottomLeft(targetChessPiece: ChessPiece) -> Array<Int> {
        let row = targetChessPiece.row
        let column = targetChessPiece.column
        var bottomLeft = [row, column]
        
        for _ in stride(from: row, to: row - 4, by: -1) {
            if bottomLeft[0] <= 0 {
                return bottomLeft
            } else if bottomLeft[1] <= 0 {
                return bottomLeft
            }
            bottomLeft[0] -= 1
            bottomLeft[1] -= 1
        }
        return bottomLeft
    }

    func getTopRight(targetChessPiece: ChessPiece) -> Array<Int> {
        let row = targetChessPiece.row
        let column = targetChessPiece.column
        var topRight = [row, column]
        
        for _ in stride(from: row, to: row + 4, by: 1) {
            if topRight[0] >= 9 {
                return topRight
            } else if topRight[1] >= 9 {
                return topRight
            }
            topRight[0] += 1
            topRight[1] += 1
        }
        return topRight
    }
    
    func getBottomRight(targetChessPiece: ChessPiece) -> Array<Int> {
        let row = targetChessPiece.row
        let column = targetChessPiece.column
        var bottomRight = [row, column]
        
        for _ in stride(from: row, to: row - 4, by: -1) {
            if bottomRight[0] <= 0 {
                return bottomRight
            } else if bottomRight[1] >= 9 {
                return bottomRight
            }
            bottomRight[0] -= 1
            bottomRight[1] += 1
        }
        return bottomRight
    }

    func getTopLeft(targetChessPiece: ChessPiece) -> Array<Int> {
        let row = targetChessPiece.row
        let column = targetChessPiece.column
        var TopLeft = [row, column]
        
        for _ in stride(from: row, to: row + 4, by: 1) {
            if TopLeft[0] >= 9 {
                return TopLeft
            } else if TopLeft[1] <= 0 {
                return TopLeft
            }
            TopLeft[0] += 1
            TopLeft[1] -= 1
        }
        return TopLeft
    }

    func ConsecutiveFiveChessPieces(chessPieceSet: Array2D<ChessPiece>, color: String, start: Int, end: Int, row: Int?, column: Int?) -> Bool {
        var consecutiveCount = 0

        //scan column
        if row != nil {
            for i in start..<end {
                if i < NumRows {
                    if chessPieceSet[i, row!]?.occupiedColor == color {
                        consecutiveCount += 1
                    }
                } else {
                    break
                }
            }
        //scan row
        } else if column != nil {
            for j in start..<end {
                if j < NumColumns {
                    if chessPieceSet[column!, j]?.occupiedColor == color {
                        consecutiveCount += 1
                    }
                } else {
                    break
                }
            }
        }
        return consecutiveCount >= 5
    }
    
    func ConsecutiveFromBottomLeftToTopRight(chessPieceSet: Array2D<ChessPiece>, color: String, start: Array<Int>, max: Array<Int>) -> Bool {
        var consecutiveCount = 0
        var tempPoint = start

        for _ in 0..<5 {
            if tempPoint[0] <= max[0] && tempPoint[1] <= max[1]{
          
                if chessPieceSet[tempPoint[1], tempPoint[0]]?.occupiedColor == color {
                    consecutiveCount += 1
                }
            } else {
                break
            }
            tempPoint[0] += 1
            tempPoint[1] += 1
        }
        return consecutiveCount >= 5
    }
    
    func ConsecutiveFromBottomRightToTopLeft(chessPieceSet: Array2D<ChessPiece>, color: String, start: Array<Int>, max: Array<Int>) -> Bool {
        var consecutiveCount = 0
        var tempPoint = start
        
        for _ in 0..<5 {
            if tempPoint[0] <= max[0] && tempPoint[1] >= max[1]{
                if chessPieceSet[tempPoint[1], tempPoint[0]]?.occupiedColor == color {
                    consecutiveCount += 1
                }
            } else {
                break
            }
            tempPoint[0] += 1
            tempPoint[1] -= 1
        }
        return consecutiveCount >= 5
    }
    
    func presentGameOverScene(targetChessPiece: ChessPiece){
        if let sprite = targetChessPiece.sprite {
            let new_sprite = SKSpriteNode(imageNamed: targetChessPiece.occupiedColor)
            new_sprite.size = CGSize(width: 25, height: 25)
            new_sprite.position = sprite.position
            new_sprite.name = targetChessPiece.occupiedColor
            new_sprite.isUserInteractionEnabled = false
            chessPiecesLayer.addChild(new_sprite)
            
            let textureAtlas = SKTextureAtlas(named: targetChessPiece.occupiedColor)
            let frames = [targetChessPiece.occupiedColor + " Normal"
                , targetChessPiece.occupiedColor + " Hightlight"].map { textureAtlas.textureNamed($0) }
            let animate = SKAction.animate(with: frames, timePerFrame: 0.5)
            let forever = SKAction.repeat(animate, count: 3)
            
            let gameTrans = SKAction.run(){
                let gameOverScene = GameOverScene(size: self.size)
                let transition = SKTransition.fade(withDuration: 0.5)
                gameOverScene.scaleMode = .aspectFill
                self.scene?.view?.presentScene(gameOverScene, transition: transition)
            }
            new_sprite.run(SKAction.sequence([forever,gameTrans]))
        }
    }
    
    func calculateWinTimes(chessColor: String){
        if chessColor == "White" {
            GameScene.whiteWon += 1
            if GameStartScene.gameMode == "Single" {
                GameScene.gameWinner = level.currentPlayer.value
            } else {
                GameScene.gameWinner = "White"
            }
        } else {
            GameScene.blackWon += 1
            if GameStartScene.gameMode == "Single" {
                GameScene.gameWinner = level.currentPlayer.value
            } else {
                GameScene.gameWinner = "Black"
            }
        }
    }
    
    //random place chess without IQ
    func computerPlayV1() {
        let wait = SKAction.wait(forDuration: TimeInterval(1))
        let action = SKAction.run() {
            if GameStartScene.firstPlayer == "Computer" && self.firstComputerRound == true {
                let midRow = NumRows/2
                let midColumn = NumColumns/2
                
                self.placeChessPiece(row: midRow - 1, column: midColumn - 1, color: "black")
                self.firstComputerRound = false
            } else {
                if self.isBlack == true {
                    var randomRow = Int(arc4random_uniform(UInt32(NumRows)))
                    var randomColumn = Int(arc4random_uniform(UInt32(NumColumns)))
                    while self.gridSet[randomColumn, randomRow]?.occupiedColor == "Black" {
                        randomRow = Int(arc4random_uniform(UInt32(NumRows)))
                        randomColumn = Int(arc4random_uniform(UInt32(NumColumns)))
                        print("existing black chess: \(randomRow), \(randomColumn)")
                    }

                    self.placeChessPiece(row: randomRow, column: randomColumn, color: "black")
                } else {
                    var randomRow = Int(arc4random_uniform(UInt32(NumRows)))
                    var randomColumn = Int(arc4random_uniform(UInt32(NumColumns)))
                    while self.gridSet[randomColumn, randomRow]?.occupiedColor == "White" {
                        randomRow = Int(arc4random_uniform(UInt32(NumRows)))
                        randomColumn = Int(arc4random_uniform(UInt32(NumColumns)))
                        print("existing white chess: \(randomRow), \(randomColumn)")
                    }
                    self.placeChessPiece(row: randomRow, column: randomColumn, color: "white")
                }
            }

        }
        self.run(SKAction.sequence([wait, action]))
    }
    
    //using GKMinmaxStrategist AI
    func computerPlayV2() {
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent()
            print("\(self.level.chessPieces)")

            print("\(self.level.currentPlayer.value)")
            guard let bestCoordinate = self.strategist.bestMove(for: self.level.currentPlayer) as? Move else {
                print("best position is not found")
                return
            }
            print("best position found in: \(bestCoordinate)")
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime
            let aiTimeCeiling = 0.5
            let delay = max(delta, aiTimeCeiling)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                //update board here
                if self.isBlack == true {
                    self.placeChessPiece(row: bestCoordinate.x, column: bestCoordinate.y, color: "black")
                } else {
                    self.placeChessPiece(row: bestCoordinate.x, column: bestCoordinate.y, color: "white")
                }
                //self.updateBoard(with: Int(bestCoordinate.x), y: Int(bestCoordinate.y))
            }
        }
    }
    
    func placeChessPiece(row: Int, column: Int, color: String) {
        let chessPieceType : ChessPieceType?
        if color == "White" || color == "white" {
            chessPieceType = ChessPieceType(rawValue: 3)
        } else {
            chessPieceType = ChessPieceType(rawValue: 2)
        }
        
        let chessPiece = ChessPiece(column: column, row: row, chessPieceType: chessPieceType!)
        chessPiece.isTouched = true
        
        if let grid = gridSet[column, row] {
            self.addSprite(chessPiece: chessPiece, location: grid.sprite!.position, name: color)
            if color == "white" {
                self.isBlack = true
            } else {
                self.isBlack = false
            }

            level.setOccupiedColor(row: row, column: column, color: color.capitalized)
            gridSet[column, row]?.occupiedColor = color.capitalized
            
            self.gameOverDetect(placedChessPiece: chessPiece)
            
            level.currentPlayer = level.currentPlayer.opponent

            self.currentTurnLabel.text = "Current Turn: \(level.currentPlayer.value)"
            
            if color == "white" {
                self.currentTurnLabel.fontColor = UIColor.black
            } else {
                self.currentTurnLabel.fontColor = UIColor.white
            }
        }
    }
 }
