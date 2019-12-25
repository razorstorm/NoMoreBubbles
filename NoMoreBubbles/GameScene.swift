//
//  GameScene.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 7/17/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var circles: [Circle] = []
    private var explosions: [Explosion] = []
    private let lineScalingFactor: CGFloat = 0.085
    private let fontScalingFactor: CGFloat = 1.3
    private let scoreFontSize: CGFloat = 80
    private let colors: [SKColor] = [SKColor.red, SKColor.cyan, SKColor(red: 0.15, green: 1.0, blue: 0.15, alpha: 1.0), SKColor.yellow, SKColor(red: 0.35, green: 0.35, blue: 1.0, alpha: 1.0), SKColor.lightGray, SKColor.orange]
    private let maxCircleSize: CGFloat = 170.0
    private var ball: Ball?
    private var origin: CGPoint?
    private var lineOrigin: CGPoint?
    private var line: SKShapeNode?
    private let ballRadius: CGFloat = 15
    private let ballInitialSpeed: CGFloat = 35
    private let ballAcceleration: CGFloat = -1.4
    private var screenWidth: CGFloat = 0
    private var screenHeight: CGFloat = 0
    private var screenLeft: CGFloat = 0
    private var screenRight: CGFloat = 0
    private var screenTop: CGFloat = 0
    private var screenBottom: CGFloat = 0
    private var gameTop: CGFloat = 0
    
    private var scoreBoard: ScoreBoard?
    private let scoreBoardHeight: CGFloat = 130
    
    private let goalRadius: CGFloat = 79
    
    private var goal: SKShapeNode?
    
    private let trailInterval: CGFloat = 1
    private var previousTime: TimeInterval = TimeInterval.init()
    
    private let physicsFrameRate: CGFloat = 1/60.0
    
    private let bgColor: SKColor = SKColor.init(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
    private let scoreColor: SKColor = SKColor.init(red: 0.20, green: 0.15, blue: 0.20, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        lineOrigin = CGPoint(x: 0 , y: -size.height/2 + ballRadius)
        origin = CGPoint(x: 0 , y: -size.height/2)
        screenWidth = size.width
        screenHeight = size.height
        
        screenLeft = -screenWidth/2
        screenRight = screenWidth/2
        screenTop = screenHeight/2
        gameTop = screenTop - scoreBoardHeight - 1
        screenBottom = -screenHeight/2
        
        let scoreBoardNode = SKShapeNode.init(rectOf: CGSize.init(width: screenWidth + 2, height: scoreBoardHeight + 1))
        scoreBoardNode.position = CGPoint(x: 0, y: screenTop - scoreBoardHeight / 2.0 + 1)
        scoreBoardNode.zPosition = 1
        scoreBoardNode.lineWidth = 2
        scoreBoardNode.fillColor = scoreColor
        
        let label = SKLabelNode.init(text: String(0))
        label.fontSize = scoreFontSize
        label.position = CGPoint(x: 0, y: screenTop - 110)
        label.fontColor = SKColor.white
        label.zPosition = 1
        
        addChild(scoreBoardNode)
        addChild(label)
        
        scoreBoard = ScoreBoard.init(fromNode: scoreBoardNode, fromScore: 0, fromLabel: label)
        
        goal = SKShapeNode(circleOfRadius: goalRadius)
        goal!.position = origin!
        goal!.strokeColor = SKColor.green
        goal!.fillColor = UIColor.green.withAlphaComponent(0.1)
        goal!.isAntialiased = true
        goal!.lineWidth = 2
        addChild(goal!)
        
        startGame()
    }
    
    func startGame() {
        let bottomMargin = CGFloat(50)
        let circleMinSize = CGFloat(15)
        let circleMaxSize = CGFloat(70)
        let maxRounds = 10000

        scoreBoard?.score = 0
        for circle in circles {
            circle.node.removeAllChildren()
            circle.node.removeFromParent()
        }
        circles = []
        ball?.node.removeFromParent()
        ball = nil
        
        let gameBottom = screenBottom + bottomMargin
        
        ballLoop: for i in 1...Int.random(in: 3...6) {
            var position: CGPoint
            var invalidPosition: Bool = false
            var rounds: Int = 0
            repeat {
                invalidPosition = false
                if (rounds > maxRounds) {
                    continue ballLoop
                }
                
                position = generateRandomSeedCircleLocation(
                    circleMinSize: circleMinSize,
                    circleMaxSize: circleMaxSize,
                    gameBottom: gameBottom
                )

                // See if it is too far from the walls
                let tooFarFromWalls = (position.x - screenLeft > circleMaxSize && screenRight - position.x > circleMaxSize) &&
                    (position.y - gameBottom > circleMaxSize && gameTop - position.y > circleMaxSize)
                
                // If the position is too close to the goal post we can't spawn circle there
                if CGDistance(from: origin!, to: position) < goalRadius + circleMinSize {
                    invalidPosition = true
                }
                
                for circle in circles {
                    // If this is inside any of the other circles, then we haven't found a valid position yet. Keep looking
                    if CGDistance(from: position, to: circle.node.position) <= circle.radius + circleMinSize {
                        invalidPosition = true
                    }
                    let tooFarFromCircle = CGDistance(from: position, to: circle.node.position) > circle.radius + circleMaxSize
                    // If the circle is too far from other circles and is also too far from the wall, it's going to be too big
                    if tooFarFromCircle && tooFarFromWalls {
                        invalidPosition = true
                    }
                }
                rounds+=1
            } while (invalidPosition)

            createCircle(atPoint: position, withHealth: i)
        }
    }
    
    func generateRandomSeedCircleLocation(circleMinSize: CGFloat, circleMaxSize: CGFloat, gameBottom: CGFloat) -> CGPoint {
        let gracefulMargin = CGFloat(300)
        var xPosition: CGFloat
        var yPosition: CGFloat
        var xClampedPosition: CGFloat
        var yClampedPosition: CGFloat
        var xUnclampedPosition: CGFloat
        var yUnclampedPosition: CGFloat
        var margin: CGFloat
        
        if circles.count == 0 {
            margin = circleMaxSize
        } else {
            // We allow the new circle to be a bit further away from the wall the second time around,
            // because it can cluster with another circle
            margin = gracefulMargin
        }
        
        xClampedPosition = [CGFloat.random(in: screenLeft+circleMinSize...screenLeft+margin), CGFloat.random(in: screenRight-margin...screenRight-circleMinSize)].randomElement()!
        yClampedPosition = [CGFloat.random(in: gameBottom+circleMinSize...gameBottom+margin), CGFloat.random(in: gameTop-margin...gameTop-circleMinSize)].randomElement()!

        xUnclampedPosition = CGFloat.random(in: screenLeft+circleMinSize...screenRight-circleMinSize)
        yUnclampedPosition = CGFloat.random(in: gameBottom+circleMinSize...gameTop-circleMinSize)

        if (Bool.random()) {
            xPosition = xClampedPosition
            yPosition = yUnclampedPosition
        } else {
            xPosition = xUnclampedPosition
            yPosition = yClampedPosition
        }
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    func CGDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
    }
    
    func closestDistance(from: CGPoint) -> CGFloat {
        var minDist = maxCircleSize as CGFloat
        
        let walls = [
            CGPoint(x: screenLeft, y: from.y), CGPoint(x: screenRight, y: from.y),
            CGPoint(x: from.x, y: screenBottom), CGPoint(x: from.x, y: gameTop)
        ]
        
        for circle in circles {
            let dist = CGDistance(from: from, to: circle.node.position)
            let adjustedDistance = dist - circle.radius - circle.node.lineWidth/2
            
            let scaledDistance = adjustedDistance * (1 - lineScalingFactor/4)
            
            if scaledDistance < minDist {
                minDist = scaledDistance
            }
        }
        for wall in walls {
            let dist = CGDistance(from: from, to: wall)
            let scaledDistance = dist * (1 - lineScalingFactor/2)
            
            if scaledDistance < minDist {
                minDist = scaledDistance
            }
        }
        
        let goalDistance = CGDistance(from: from, to: origin!)
        let adjustedGoalDistance = goalDistance - goalRadius
        let scaledGoalDistance = adjustedGoalDistance * (1 - lineScalingFactor/2)
        
        if scaledGoalDistance < minDist {
            minDist = scaledGoalDistance
        }
        
        return minDist
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if (ball == nil) {
            drawLine(atPoint: pos)
        }
    }
    
    func pathForLine(atPoint pos: CGPoint) -> CGMutablePath {
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: lineOrigin!.x, y: lineOrigin!.y))
        pathToDraw.addLine(to: CGPoint(x: pos.x, y: pos.y))
        return pathToDraw
    }
    
    func drawLine(atPoint pos: CGPoint) {
        let pattern : [CGFloat] = [2.0, 5.0]
        let path = pathForLine(atPoint: pos).copy(dashingWithPhase: 2, lengths: pattern)
        if (line == nil) {
            line = SKShapeNode()
            line!.strokeColor = SKColor.white
            line!.lineWidth = 3
            addChild(line!)
        }
        line!.path = path
    }
    
    func createCircle(atPoint pos: CGPoint, withHealth expectedHealth: Int? = nil) {
        let size = closestDistance(from: pos)
        let node = SKShapeNode.init(circleOfRadius: size)
        node.position = pos
        let color = colors.randomElement() ?? SKColor.gray
        node.strokeColor = color
        node.lineWidth = size * lineScalingFactor
        node.isAntialiased = true
        
        let health = (expectedHealth != nil ? expectedHealth : Int.random(in: 4..<7))!
        let label = SKLabelNode.init(text: String(health))
        label.fontSize = size * fontScalingFactor
        label.fontColor = color
        label.fontName = "MarkerFelt-Wide"
//        label.fontName = "HelveticaNeue-Bold"
//        label.fontName = "AppleSDGothicNeo-Bold"
//        label.fontName = "Chalkduster"
//        label.fontName = "ChalkboardSE-Bold"
        label.position = CGPoint(x: 0, y: -label.frame.height/2)

        addChild(node)
        node.addChild(label)
        
        let circle = Circle.init(fromRadius: size, fromNode: node, fromHealth: health, fromLabel: label)
        
        for explosion in explosions {
            explosion.circlesHit.insert(circle)
        }
        circles.append(circle)
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if (ball == nil) {
            drawLine(atPoint: pos)
        }
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
    
    func normalizeVector(vector: CGVector) -> CGVector {
        let len = CGDistance(from: CGPoint(x: 0, y: 0), to: CGPoint(x: vector.dx, y: vector.dy))
        return len > 0 ? CGVector(dx: vector.dx / len, dy: vector.dy / len) : CGVector.zero
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if pos.y <= gameTop {
            if ball == nil {
                line?.removeFromParent()
                line = nil
                let deltas = CGPoint(x: pos.x - lineOrigin!.x, y: pos.y - lineOrigin!.y)
                
                let velocity = getVelocity(withDeltas: deltas, withSpeed: ballInitialSpeed)
                let node = SKShapeNode.init(circleOfRadius: ballRadius)
                
                node.fillColor = SKColor.white
                node.isAntialiased = true
                node.position = CGPoint(x: lineOrigin!.x, y: lineOrigin!.y)
                
                ball = Ball(fromNode: node, withVelocity: velocity, withSpeed: ballInitialSpeed)
                
                addChild(node)
            }
        } else {
            startGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }
    
    func onBallStop() {
        ball!.node.removeFromParent()
    
        if CGDistance(from: ball!.node.position, to: lineOrigin!) > goalRadius {
            createCircle(atPoint: ball!.node.position)
        }
        ball = nil
    
        scoreBoard!.score += 1
        scoreBoard!.labelNode.text = String(scoreBoard!.score)
    }
    
    func damageCircle(circle: Circle, withIndex i: Int) {
        circle.health -= 1
        circle.labelNode.text = circle.health > 0 ? String(circle.health) : ""
        circle.node.run(SKAction.sequence([
            SKAction.scale(by: 0.9, duration: 0.1),
            SKAction.scale(by: 1.1111111111, duration: 0.1),
        ]))
        
        if circle.health == 0 {
            self.circles.remove(at: i)
            
            let actions = SKAction.group([
                SKAction.scale(by: 0, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ])

            circle.node.run(actions, completion: {
                circle.node.removeFromParent()
                circle.labelNode.removeFromParent()
            })

            let explosionNode = SKShapeNode.init(circleOfRadius: circle.radius / 5.0)
            explosionNode.strokeColor = circle.node.strokeColor
            explosionNode.lineWidth = circle.node.lineWidth / 5.0
            explosionNode.alpha = 0.5
            explosionNode.isAntialiased = true
            explosionNode.position = circle.node.position
            explosionNode.glowWidth = 1/5
            let explosion = Explosion.init(withNode: explosionNode)
            explosions.append(explosion)
            
            addChild(explosionNode)
            
            explosionNode.run(SKAction.sequence([
                SKAction.group([
                    SKAction.fadeAlpha(to: 0.2, duration: 1.6),
                    SKAction.scale(by: 10, duration: 1.6),
                ]),
                SKAction.removeFromParent()
            ]), completion: {
                    if let index = self.explosions.index(of:explosion) {
                        self.explosions.remove(at: index)
                    }
                }
            )
        }
    }
    
    func onCollideWithCircle(ballCenter: CGPoint, circle: Circle, withIndex i: Int) -> CGPoint {
        let collisionVector = normalizeVector(vector: CGVector(dx: ballCenter.x - circle.node.position.x , dy: ballCenter.y - circle.node.position.y))
        let normalizedVelocity = normalizeVector(vector: ball!.velocity)
        
        let tangent = normalizeVector(vector: CGVector(dx: circle.node.position.y - ballCenter.y, dy: ballCenter.x - circle.node.position.x))
        let length = normalizedVelocity.dot(tangent)
        let velocityComponentOnTangent = length * tangent
        let velocityComponentPerpendicularToTangent = normalizedVelocity - velocityComponentOnTangent
        let resultant = normalizedVelocity - 2 * velocityComponentPerpendicularToTangent

        let normalizedResultant = normalizeVector(vector: resultant)
        ball!.velocity = CGVector(dx: ball!.speed * normalizedResultant.dx, dy: ball!.speed * normalizedResultant.dy)

        let distance = ballRadius + circle.radius
        let collisionPosition = CGPoint(x: circle.node.position.x + collisionVector.dx * distance, y: circle.node.position.y + collisionVector.dy * distance)
        let ballPosition = collisionPosition
        
        damageCircle(circle: circle, withIndex: i)
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        return ballPosition
    }
    
    func scaledAcceleration(speed: CGFloat) -> CGFloat {
        let normalizedSpeed = speed / ballInitialSpeed
        let accel = ballAcceleration * normalizedSpeed
        return min(-0.05, accel)
    }
    
    func updateExplosions() {
        for explosion in explosions {
            for (i, circle) in circles.enumerated() {
                if CGDistance(from: circle.node.position, to: explosion.node.position) < circle.radius + explosion.node.frame.width / 2.0 {
                    if !explosion.circlesHit.contains(circle) {
                        damageCircle(circle: circle, withIndex: i)
                        explosion.circlesHit.insert(circle)
                    }
                }
            }
        }
    }

    override func update(_ currentTime: TimeInterval) {
        let frameInterval: CGFloat = CGFloat(currentTime - previousTime)
        let frameScalingFactor: CGFloat = frameInterval / physicsFrameRate

        previousTime = currentTime
        
        if (ball != nil) {
            if (ball!.speed <= 0) {
                onBallStop()
            }
            else {
                var ballPosition = CGPoint(
                    x: ball!.node.position.x + ball!.velocity.dx * frameScalingFactor,
                    y: ball!.node.position.y + ball!.velocity.dy * frameScalingFactor
                )
                ball!.speed += scaledAcceleration(speed: ball!.speed) // ballAcceleration

                ball!.velocity = ball!.speed * normalizeVector(vector: ball!.velocity)

                // collision with walls
                let ballCenter = ballPosition

                if ballCenter.x - ballRadius < screenLeft && ball!.velocity.dx < 0 {
                    ball!.velocity.dx = abs(ball!.velocity.dx)
                }
                else if ballCenter.x + ballRadius > screenRight && ball!.velocity.dx > 0 {
                    ball!.velocity.dx = -abs(ball!.velocity.dx)
                }
                else if ballCenter.y - ballRadius < screenBottom && ball!.velocity.dy < 0 {
                    ball!.velocity.dy = abs(ball!.velocity.dy)
                }
                else if ballCenter.y + ballRadius > gameTop && ball!.velocity.dy > 0 {
                    ball!.velocity.dy = -abs(ball!.velocity.dy)
                }

                // collision with other circles
                for (i,circle) in circles.enumerated() {
                    if CGDistance(from: ballCenter, to: circle.node.position) <= circle.radius + ballRadius {
                        ballPosition = onCollideWithCircle(ballCenter: ballCenter, circle: circle, withIndex: i)
                    }
                }

                // Make trails
                let travelVector = normalizeVector(vector: CGVector(dx: ballPosition.x - ball!.node.position.x, dy: ballPosition.y - ball!.node.position.y))
                var trailPosition = ball!.node.position
                let scaledTravelVector = CGVector(dx: trailInterval * travelVector.dx, dy: trailInterval * travelVector.dy)

                let distance = CGDistance(from: ball!.node.position, to: ballPosition)
                let distanceIntervals = Int(distance/trailInterval)
                for _ in 0...distanceIntervals {
                    let trailNode = SKShapeNode.init(circleOfRadius: ballRadius * 0.75)
                    trailNode.fillColor = SKColor.lightGray
                    trailNode.lineWidth = 0
                    trailNode.strokeColor = SKColor.lightGray
                    trailNode.alpha = 0.5
                    trailNode.isAntialiased = true
                    trailNode.position = trailPosition
                    trailNode.glowWidth = 2
                    trailNode.zPosition = -1

                    trailPosition.x += scaledTravelVector.dx
                    trailPosition.y += scaledTravelVector.dy

                    addChild(trailNode)

                    let duration = 0.2

                    trailNode.run(SKAction.sequence([
                        SKAction.wait(forDuration: 0.0),
                        SKAction.group([
                            SKAction.colorTransitionAction(fromColor: trailNode.fillColor, toColor: bgColor, duration: duration),
//                            SKAction.fadeOut(withDuration: duration),
                            SKAction.scale(by: 0, duration: duration)
                        ]),
                        SKAction.removeFromParent()
                    ]))
                }

                ball!.node.position = ballPosition
            }
        }

        updateExplosions()
    }
    
    func printTime(startTime: DispatchTime, message: String) {
        let end = DispatchTime.now()   // <<<<<<<<<<   end time
        
        let nanoTime = end.uptimeNanoseconds - startTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
        let timeInterval = Double(nanoTime) / 1_000_000 // Technically could o
        let asFrames = timeInterval / (1/60.0)
        print("\(message): \(asFrames)")
    }
}
