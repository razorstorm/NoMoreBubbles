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
    var pastScore: Int
    
    public init(
        fromNode: SKShapeNode,
        fromLevel: Int,
        fromLevelLabel: SKLabelNode,
        fromAccumScore: Int,
        fromAccumScoreLabel: SKLabelNode,
        fromCurrentScore: Int,
        fromCurrentScoreLabel: SKLabelNode,
        fromPastScore: Int
    ) {
        node = fromNode
        level = fromLevel
        levelLabelNode = fromLevelLabel
        accumScoreLabel = fromAccumScoreLabel
        currentScoreLabel = fromCurrentScoreLabel
        accumScore = fromAccumScore
        currentScore = fromCurrentScore
        pastScore = fromPastScore
    }
    
    func resetValues() {
        level = 1
        currentScore = 0
        accumScore = 0
        pastScore = 0
        updateDisplay()
    }
    
    func updateDisplay() {
        levelLabelNode.text = String(level)
        accumScoreLabel.text = String(accumScore)
        let currScoreDisplayNumber = adjustScorePerRound(score: currentScore)
        currentScoreLabel.text =  "\(pastScore) | \(currScoreDisplayNumber)"
    }

    func updateLevel(newLevel: Int) {
        level = newLevel
        updateDisplay()
    }
    
    func updateCurrentScore(newScore: Int) {
        currentScore = newScore
        updateDisplay()
    }

    func accumulate() {
        let adjustedScore = adjustScorePerRound(score: currentScore)
        accumScore += adjustedScore
        pastScore = adjustedScore
        currentScore = 0
        updateDisplay()
    }

    func updateAccumScore(newScore: Int) {
        accumScore = newScore
        updateDisplay()
    }

    private func adjustScorePerRound(score: Int) -> Int {
        return Int(pow(Double(score), 2.0))
    }
}
