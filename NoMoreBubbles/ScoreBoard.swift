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
    var score: Int
    var labelNode: SKLabelNode
    
    public init(fromNode: SKShapeNode, fromScore: Int, fromLabel: SKLabelNode) {
        node = fromNode
        score = fromScore
        labelNode = fromLabel
    }
}
