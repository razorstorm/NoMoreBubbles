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

    public func activate(gameScene: GameScene, index: Int) {
        switch self.type {
            case .resetSpeed:
                gameScene.ball!.speed = gameScene.ballInitialSpeed
                break
            case .superBounce:
                gameScene.ball!.speed = gameScene.ballInitialSpeed
                break
            case .shock:
                gameScene.createExplosion(radius: 50, strokeColor: SKColor.red, lineWidth: 3, position: self.node.position)
                break
            case .largeBall:
                gameScene.ball!.radius = 30
                gameScene.ball!.speed = gameScene.ballInitialSpeed
                gameScene.swapBallNode()
            case .smallBall:
                gameScene.ball!.radius = 7.5
                gameScene.ball!.speed = gameScene.ballInitialSpeed
                gameScene.swapBallNode()
            case .doubleDamage:
                break
            case .skullBall:
                break
        }

        gameScene.currentPowerUp = self
        self.node.removeFromParent()
        gameScene.powerUps.removeAll(where: { $0 == self })

        gameScene.updateBallToPowerUp()
    }

    public func ballLabel() -> String {
        switch type {
            case .doubleDamage: return "2x"
            case .skullBall: return "☠"
            default: return ""
        }
    }

    public func ballStrokeColor() -> SKColor {
        switch type {
            case .resetSpeed, .shock, .superBounce, .largeBall, .smallBall, .doubleDamage, .skullBall:
            return ballFillColor()
        }
    }

    public func ballFillColor() -> SKColor {
        switch type {
            case .resetSpeed, .shock, .superBounce, .largeBall, .smallBall, .doubleDamage, .skullBall:
                return PowerUp.powerUpColor(type: type)
        }
    }

    static func powerUpColor(type: PowerUpType) -> SKColor {
        switch type {
            case .resetSpeed: return SKColor.blue
            case .shock: return SKColor.red
            case .superBounce: return SKColor.green
            case .largeBall: return SKColor.yellow
            case .smallBall: return SKColor.yellow
            case .doubleDamage: return SKColor.red
            case .skullBall: return SKColor.black
        }
    }
    
    static func == (lhs: PowerUp, rhs: PowerUp) -> Bool {
        return lhs === rhs
    }

    static func spawnPowerUp(ballsHit: Int = 0, gameScene: GameScene) {
        let radius: CGFloat = 15
        var powerUpType: PowerUpType? = nil

        switch ballsHit {
            case 2:
                powerUpType = .shock
            case 3:
                powerUpType = .resetSpeed
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
            powerUpNode.strokeColor = PowerUp.powerUpColor(type: powerUpType!)
            powerUpNode.fillColor = fillColorForType(type: powerUpType!)
            powerUpNode.isAntialiased = true
            powerUpNode.lineWidth = 4
            gameScene.playingScreen?.addChild(powerUpNode)

            let label = SKLabelNode.init(text: powerUpLabelForType(type: powerUpType!))
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
    case doubleDamage
    case skullBall
}

func randomPowerUpType() -> PowerUpType {
    return PowerUpType(rawValue: arc4random_uniform(UInt32(PowerUpType.allCases.count)))!
}

func fillColorForType(type: PowerUpType) -> SKColor {
    switch type {
        case .skullBall: return SKColor.black
        default: return SKColor.clear
    }
}

func powerUpLabelForType(type: PowerUpType) -> String {
    switch type {
        case .resetSpeed: return ">"
        case .shock: return "💥"
        case .superBounce: return "B"
        case .largeBall: return "+"
        case .smallBall: return "—"
        case .doubleDamage: return "2x"
        case .skullBall: return "☠"
    }
}
