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
    var speed: CGFloat
    var trailNodes: [CGPoint]
    var radius: CGFloat
    
    public init(fromNode: SKShapeNode, withVelocity: CGVector, withSpeed: CGFloat, withRadius: CGFloat) {
        node = fromNode
        velocity = withVelocity
        speed = withSpeed
        trailNodes = [CGPoint]()
        radius = withRadius
    }
}
