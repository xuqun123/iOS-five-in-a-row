//
//  Player.swift
//  FiveInARow
//
//  Created by QUN XU on 21/5/17.
//  Copyright © 2017 QuintinXU. All rights reserved.
//
import GameplayKit

class Player: NSObject, GKGameModelPlayer {
    static var playerColor = "White"
    static var allPlayers = [
        Player("Player"),
        Player("Computer")
    ]
    
    var value: String
    var playerId: Int
    var color: String
    
    var opponent: Player {
        if value == "Computer" {
            return Player.allPlayers[0]
        } else {
            return Player.allPlayers[1]
        }
    }
    
    init(_ role: String) {
        self.value = role
        if role == "Computer" {
            self.playerId = 1
            if Player.playerColor == "Black" {
                self.color = "White"
            } else {
                self.color = "Black"
            }
        } else {
            self.playerId = 0
            if Player.playerColor == "Black" {
                self.color = "Black"
            } else {
                self.color = "White"
            }
        }
    }
}
