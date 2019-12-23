//
//  Explosion.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 12/22/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

import SpriteKit
import GameplayKit
import Foundation

class Explosion: Equatable {
    let node: SKShapeNode
    var circlesHit: Set<Circle> = []
    
    public init(withNode node: SKShapeNode) {
        self.node = node
    }
    
    static func == (lhs: Explosion, rhs: Explosion) -> Bool {
        return lhs === rhs
    }
}
