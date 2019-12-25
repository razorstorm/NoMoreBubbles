//
//  Circle.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 12/22/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

class Circle: Hashable  {
    static func == (lhs: Circle, rhs: Circle) -> Bool {
        return lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self).hashValue)
    }
    
    var radius: CGFloat
    var node: SKShapeNode
    var health: Int
    var labelNode: SKLabelNode
    
    public init(fromRadius: CGFloat, fromNode: SKShapeNode, fromHealth: Int, fromLabel: SKLabelNode) {
        radius = fromRadius
        node = fromNode
        health = fromHealth
        labelNode = fromLabel
    }
}
