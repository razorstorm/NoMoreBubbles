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

class Ball {
    var velocity: CGVector
    var node: SKShapeNode
    var labelNode: SKLabelNode
    var speed: CGFloat
    var trailNodes: [CGPoint]
    var radius: CGFloat
    
    public init(fromNode: SKShapeNode, withLabelNode: SKLabelNode, withVelocity: CGVector, withSpeed: CGFloat, withRadius: CGFloat) {
        node = fromNode
        velocity = withVelocity
        speed = withSpeed
        trailNodes = [CGPoint]()
        radius = withRadius
        labelNode = withLabelNode
    }

    static func createBallNode(radius: CGFloat, position: CGPoint) -> SKShapeNode {
        let node = SKShapeNode.init(circleOfRadius: radius)

        node.fillColor = SKColor.white
        node.isAntialiased = true
        node.zPosition = 100
        node.position = position
        return node
    }
}
