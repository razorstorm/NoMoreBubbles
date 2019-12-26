//
//  PowerUps.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 12/25/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class PowerUp: Equatable {
    let node: SKShapeNode
    let type: PowerUpType
    let radius: Int

    public init(withNode node: SKShapeNode, type: PowerUpType, radius: Int) {
        self.type = type
        self.node = node
        self.radius = radius
    }
    
    static func == (lhs: PowerUp, rhs: PowerUp) -> Bool {
        return lhs === rhs
    }
}

enum PowerUpType: UInt32, CaseIterable {
    case superBounce
    case shock
    case resetSpeed
    case largeBall
    case smallBall
}

func randomPowerUpType() -> PowerUpType {
    return PowerUpType(rawValue: arc4random_uniform(UInt32(PowerUpType.allCases.count)))!
}
