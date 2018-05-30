//
//  Level.swift
//  FiveInARow
//
//  Created by LIU FEI on 25/3/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//

import GameplayKit

let NumColumns = 10
let NumRows = 10

class Level: NSObject, GKGameModel {
    var chessPieces = Array2D<String>(columns: NumColumns, rows: NumRows)
    var currentPlayer: Player!
    
//    subscript(x: Int, y: Int) -> String {
//        get {
//            return chessPieces[y, x]!.occupiedColor
//        }
//        set {
//            if chessPieces[y, x]!.occupiedColor != "Black" || chessPieces[y, x]!.occupiedColor != "White" {
//                chessPieces[y, x]!.occupiedColor = newValue
//            }
//        }
//    }
    
    override init() {
        for column in 0 ..< NumColumns {
            for row in 0 ..< NumRows {
                chessPieces[column, row] = .none
            }
        }
        
//        if GameStartScene.firstPlayer == "Computer" {
//            currentPlayer = Player.allPlayers[1]
//        } else {
//            currentPlayer = Player.allPlayers[0]
//        }
        super.init()
    }
    
    func setOccupiedColor(row: Int, column: Int, color: String) {
        assert(column >= 0 && column < NumColumns)
        assert(row >= 0 && row < NumRows)
        
        chessPieces[column, row] = color
    }
    
    var isFull: Bool {
        print("is full ")
        for column in 0..<NumColumns {
            for row in 0..<NumRows {
                if chessPieces[column, row] == .none {
                    return false
                }
            }
        }
        return true
    }
        
    func clear() {
        print("clearing ")
        for column in 0..<NumColumns {
            for row in 0..<NumRows {
                chessPieces[column, row] = .none
            }
        }
    }
    
    func canMove(x: Int, y: Int) -> Bool {
        assert(y >= 0 && y < NumColumns)
        assert(x >= 0 && x < NumRows)

        if chessPieces[y, x] == .none {
            return true
        } else {
            return false
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Level()
        copy.setGameModel(self)
        return copy
    }
    
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let level = gameModel as? Level {
            chessPieces = level.chessPieces
            currentPlayer = level.currentPlayer
        }
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        
        if let player = player as? Player {
            let chessColor = player.color
            for col in 0..<NumColumns {
                for row in 0..<NumRows {
                        if consecutiveFiveMatch(chessColor: chessColor, row: row, col: col, moveX: 1, moveY: 0) {
                            return true
                        } else if consecutiveFiveMatch(chessColor: chessColor, row: row, col: col, moveX: 0, moveY: 1) {
                            return true
                        } else if consecutiveFiveMatch(chessColor: chessColor, row: row, col: col, moveX: 1, moveY: 1) {
                            return true
                        } else if consecutiveFiveMatch(chessColor: chessColor, row: row, col: col, moveX: 1, moveY: -1) {
                            return true
                        }
                }
            }
        }
        
        return false
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let player = player as? Player else {
            return nil
        }
        
        if isWin(for: player) {
            return nil
        }
        
        var moves = [Move]()
        
        for column in 0..<NumColumns {
            for row in 0..<NumRows {
                if canMove(x: row, y: column){
                    moves.append(Move(x: row, y: column))
                }
            }
        }
        return moves
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard  let move = gameModelUpdate as? Move else {
            return
        }
        chessPieces[move.y, move.x] = currentPlayer.color
        currentPlayer = currentPlayer.opponent
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        guard let player = player as? Player else {
            return Move.Score.none.rawValue
        }
        
        if isWin(for: player) {
            return Move.Score.win.rawValue
        } else {
            return Move.Score.none.rawValue
        }
    }
    
    func consecutiveFiveMatch(chessColor: String, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        // bail out early if we can't win from here
        if row + (moveY * 4) < 0 { return false }
        if row + (moveY * 4) >= NumRows { return false }
        if col + (moveX * 4) < 0 { return false }
        if col + (moveX * 4) >= NumColumns { return false }
        
        // still here? Check every square
        if chessPieces[col, row] != chessColor { return false }
        if chessPieces[col + moveX, row + moveY] != chessColor { return false }
        if chessPieces[col + (moveX * 2), row + (moveY * 2)] != chessColor { return false }
        if chessPieces[col + (moveX * 3), row + (moveY * 3)] != chessColor { return false }
        if chessPieces[col + (moveX * 4), row + (moveY * 4)] != chessColor { return false }

        return true
    }
}
