//
//  Ball.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 12/22/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//
import SpriteKit
import GameplayKit
import Foundation

class ScoreBoard {
    var node: SKShapeNode
    var level: Int
    var levelLabelNode: SKLabelNode
    var accumScoreLabel: SKLabelNode
    var currentScoreLabel: SKLabelNode
    var accumScore: Int
    var currentScore: Int
    
    public init(
        fromNode: SKShapeNode,
        fromLevel: Int,
        fromLevelLabel: SKLabelNode,
        fromAccumScore: Int,
        fromAccumScoreLabel: SKLabelNode,
        fromCurrentScore: Int,
        fromCurrentScoreLabel: SKLabelNode
    ) {
        node = fromNode
        level = fromLevel
        levelLabelNode = fromLevelLabel
        accumScoreLabel = fromAccumScoreLabel
        currentScoreLabel = fromCurrentScoreLabel
        accumScore = fromAccumScore
        currentScore = fromCurrentScore
    }
    
    func resetValues() {
        level = 1
        currentScore = 0
        accumScore = 0
        updateDisplay()
    }
    
    func updateDisplay() {
        levelLabelNode.text = String(level)
        accumScoreLabel.text = String(accumScore)
        currentScoreLabel.text = String(currentScore)
    }

    func updateLevel(newLevel: Int) {
        level = newLevel
        updateDisplay()
    }
    
    func updateCurrentScore(newScore: Int) {
        currentScore = newScore
        updateDisplay()
    }
    
    func updateAccumScore(newScore: Int) {
        accumScore = newScore
        updateDisplay()
    }
}
