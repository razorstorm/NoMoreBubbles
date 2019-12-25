//
//  Utils.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 12/22/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

func lerp(a : CGFloat, b : CGFloat, fraction : CGFloat) -> CGFloat
{
    return (b-a) * fraction + a
}

struct ColorComponents {
    var red = CGFloat(0)
    var green = CGFloat(0)
    var blue = CGFloat(0)
    var alpha = CGFloat(0)
}

extension UIColor {
    func toComponents() -> ColorComponents {
        var components = ColorComponents()
        getRed(&components.red, green: &components.green, blue: &components.blue, alpha: &components.alpha)
        return components
    }
}

extension SKAction {
    static func colorTransitionAction(fromColor : UIColor, toColor : UIColor, duration : Double = 0.4) -> SKAction
    {
        return SKAction.customAction(withDuration: duration, actionBlock: { (node : SKNode!, elapsedTime : CGFloat) -> Void in
            let fraction = CGFloat(elapsedTime / CGFloat(duration))
            let startColorComponents = fromColor.toComponents()
            let endColorComponents = toColor.toComponents()
            let transColor = UIColor(red: lerp(a: startColorComponents.red, b: endColorComponents.red, fraction: fraction),
                                     green: lerp(a: startColorComponents.green, b: endColorComponents.green, fraction: fraction),
                                     blue: lerp(a: startColorComponents.blue, b: endColorComponents.blue, fraction: fraction),
                                     alpha: lerp(a: startColorComponents.alpha, b: endColorComponents.alpha, fraction: fraction))
            (node as? SKShapeNode)?.fillColor = transColor
        })
    }
}

func *(_ scalar: CGFloat, _ vector: CGVector) -> CGVector {
    return CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

func +(_ vector1: CGVector, _ vector2: CGVector) -> CGVector {
    return CGVector(dx: vector1.dx + vector2.dx, dy: vector1.dy + vector2.dy)
}

func -(_ vector1: CGVector, _ vector2: CGVector) -> CGVector {
    return CGVector(dx: vector1.dx - vector2.dx, dy: vector1.dy - vector2.dy)
}

extension CGVector {
    func dot(_ otherVector: CGVector) -> CGFloat {
        return dx * otherVector.dx + dy * otherVector.dy
    }
}

func CGDistance(from: CGPoint, to: CGPoint) -> CGFloat {
    return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
}

func getVelocity(withDeltas deltas: CGPoint, withSpeed speed: CGFloat) -> CGVector {
    let theta = atan(deltas.y / deltas.x)
    
    var VX = speed * cos(theta)
    if deltas.x < 0 {
        VX = -VX
    }
    var VY = speed * abs(sin(theta)) // Fuck trig
    if deltas.y < 0 {
        VY = -VY
    }
    
    return CGVector(dx: VX, dy: VY)
}
