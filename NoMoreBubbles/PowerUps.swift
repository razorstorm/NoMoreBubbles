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
    let radius: CGFloat

    public init(withNode node: SKShapeNode, type: PowerUpType, radius: CGFloat) {
        self.type = type
        self.node = node
        self.radius = radius
    }
    
    static func == (lhs: PowerUp, rhs: PowerUp) -> Bool {
        return lhs === rhs
    }

    static func spawnPowerUp(ballsHit: Int = 0, gameScene: GameScene) {
        let radius: CGFloat = 15
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
            powerUpNode.position = gameScene.generateRandomValidPowerUpLocation(radius: radius)
            powerUpNode.strokeColor = powerUpColorForType(type: powerUpType!)
            powerUpNode.isAntialiased = true
            powerUpNode.lineWidth = 4
            gameScene.playingScreen?.addChild(powerUpNode)

            let label = SKLabelNode.init(text: powerUpStringForType(type: powerUpType!))
            label.fontSize = 22
            label.position = CGPoint(x: 0.0, y: 0)
            label.fontColor = powerUpNode.strokeColor
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.fontName = "HelveticaNeue-Bold"

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
        case .resetSpeed: return ">"
        case .shock: return "💥"
        case .superBounce: return "B"
        case .largeBall: return "+"
        case .smallBall: return "—"
    }
}
