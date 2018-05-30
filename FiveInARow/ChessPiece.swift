//
//  ChessPiece.swift
//  FiveInARow
//
//  Created by LIU FEI on 25/3/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//
import Foundation
import SpriteKit

enum ChessPieceType: Int, CustomStringConvertible {
    case unknown = 0, grid, black, white

    var spriteName: String {
        let spriteNames = [
            "Grid",
            "Black",
            "White"]
        
        return spriteNames[rawValue - 1]
    }
    
    var highlightedSpriteName: String {
        return spriteName + "-Highlighted"
    }
    
    var description: String {
        return spriteName
    }
    
    static func random() -> ChessPieceType {
        return ChessPieceType(rawValue: Int(arc4random_uniform(2))+1)!
    }
}

class ChessPiece: CustomStringConvertible, Hashable {
    var column: Int
    var row: Int
    let chessPieceType: ChessPieceType
    var sprite: SKSpriteNode? //optional here
    var isTouched: Bool
    var occupiedColor: String
    
    init(column: Int, row: Int, chessPieceType: ChessPieceType) {
        self.column = column
        self.row = row
        self.chessPieceType = chessPieceType
        self.isTouched = false
        self.occupiedColor = ""
    }
    
    var description: String {
        return "type:\(chessPieceType) -- square:(\(row),\(column)) -- color: \(occupiedColor)"
    }
    
    //just for creating a unique identifier value
    var hashValue: Int {
        return row*10 + column
    }
    
    //comparsion func here
    static func ==(lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        return lhs.column == rhs.column && lhs.row == rhs.row
    }
}
