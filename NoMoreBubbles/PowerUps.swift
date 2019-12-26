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

    static func spawnPowerUp(ballsHit: Int = 0, gameScene: GameScene) {
        let radius = 15
        var powerUpType: PowerUpType? = nil

        switch ballsHit {
            case 2:
                powerUpType = PowerUpType.shock
            case 3:
                powerUpType = PowerUpType.resetSpeed
            default:
                let random = CGFloat.random(in: 0...100)
                if random < 10 {
                    powerUpType = randomPowerUpType()
            }
        }

        // Delete
        powerUpType = randomPowerUpType()

        if powerUpType != nil {
            let powerUpNode = SKShapeNode(circleOfRadius: CGFloat(radius))
            powerUpNode.position = gameScene.generateRandomValidPowerUpLocation()
            powerUpNode.strokeColor = powerUpColorForType(type: powerUpType!)
            powerUpNode.isAntialiased = true
            powerUpNode.lineWidth = 4
            gameScene.addChild(powerUpNode)

            let label = SKLabelNode.init(text: powerUpStringForType(type: powerUpType!))
            label.fontSize = 20
            label.position = CGPoint(x: 0.0, y: 0)
            label.fontColor = powerUpNode.strokeColor
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center

            let frameNode = SKShapeNode.init(rectOf: label.frame.size)
            frameNode.position = label.position
            frameNode.strokeColor = SKColor.white

            powerUpNode.addChild(frameNode)
            powerUpNode.addChild(label)

            let powerUp = PowerUp(withNode: powerUpNode, type: powerUpType!, radius: radius)
            gameScene.powerUps.append(powerUp)
        }
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

func powerUpColorForType(type: PowerUpType) -> SKColor {
    switch type {
        case .resetSpeed: return SKColor.blue
        case .shock: return SKColor.red
        case .superBounce: return SKColor.green
        case .largeBall: return SKColor.yellow
        case .smallBall: return SKColor.yellow
    }
}

func powerUpStringForType(type: PowerUpType) -> String {
    switch type {
        case .resetSpeed: return "R"
        case .shock: return "💥"
        case .superBounce: return "asdf"
        case .largeBall: return "+"
        case .smallBall: return "-"
    }
}
