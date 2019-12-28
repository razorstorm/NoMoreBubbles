//
//  GameScene.swift
//  NoMoreBubbles
//
//  Created by Jason Jiang on 7/17/19.
//  Copyright © 2019 Jason Jiang. All rights reserved.
//

// TODO: powerups, spawn circles further from wall if ball ends too close. reflections on line from balls

// Game Modes:
// Sandbox: no death
// Sandbox + powerup per launch
// DeathGoal: goal kills, try to get highscore before dying
// SetLaunches: You have 100 launches, try to get a high score
// MaxRoundScore: You have 100 launches, try to get the maximum round score
// Competitive: DeathGoal + No random powerups

// Earned power ups, depending on how many circles destroyed previous round:
// 2: resetSpeed / skullBall / doubleDamage
// 3: large / small / shock

// 4: shockwaveOnBounce / randomDamageCircles / damageAura
// 5: superBounce / ultra speed / allCircles1hp
// 6: destroy X circles
// 7: clearWholeMap
// 8: spawnAMillionThes
// ScreenClear: 100 points

// Tiny chance of getting one of these per each launch:
// Stops ball in place and creates a circle
// Ball stops in place and creates medium sized shockwave and a new circle
// Will not generate a new circle on stop. ball light gray or something
// Damage aura larger than ball
// Increases a circle's health by 1 instead of decrease on hit by ball
// Medium sized shockwave on ball stop.
// Shockwaves will deal 2 damage
// Shockwaves deal 0 damage
// Changes all circle's health to 5
// Deals no damage, but large shockwave on bounce
// 10 frames per second until next launch LOLL
// Teleports ball to a random location and resets speed
// Teleports on bounce

// Power up ideas:
// SuperBounce On bounce from circles, speeds up. make circles glowing or something
// Shock Large shockwave from position
// A few random circles lose a random amount of health
// Fast ball with no deceleration for certain amount of time
// Large ball
// Small ball
// Damage aura larger than ball
// Ball will deal 2 damage instead of 1 to circle, speed is also reset back to launch speed. Ball glowing red
// SkullBall: Instant kill the next circle hit. Ball turns into a skull
// Small shockwave on each ball bounce
// Instantly destroy X circles
// Clears entire screen

// Creates a circle in place
// better distribute powerups based on rarity

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var circles: Set<Circle> = Set()
    private var explosions: [Explosion] = []
    private let lineScalingFactor: CGFloat = 0.085
    private let fontScalingFactor: CGFloat = 1.6
    private let levelFontSize: CGFloat = 80
    private let ballFontSize: CGFloat = 20
    private let circleScoreFontSize: CGFloat = 40
    private let colors: [SKColor] = [SKColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0), SKColor.cyan, SKColor(red: 0.2, green: 0.9, blue: 0.2, alpha: 1.0), SKColor.yellow, SKColor(red: 0.45, green: 0.45, blue: 1.0, alpha: 1.0), SKColor.lightGray, SKColor.orange]
    private let maxCircleSize: CGFloat = 170.0
    var ball: Ball?
    private var origin: CGPoint?
    private var lineOrigin: CGPoint?
    private var line: SKShapeNode?
    private let ballInitialRadius: CGFloat = 15
    let ballInitialSpeed: CGFloat = 35
    private let maxSpeedLimit: CGFloat = 50
    private let ballAcceleration: CGFloat = -1.4
    private var screenWidth: CGFloat = 0
    private var screenHeight: CGFloat = 0
    private var screenLeft: CGFloat = 0
    private var screenRight: CGFloat = 0
    private var screenTop: CGFloat = 0
    private var screenBottom: CGFloat = 0
    private var gameHeight: CGFloat = 0
    private var gameTop: CGFloat = 0
    private var gameBottom: CGFloat = 0
    var gameScreen: SKShapeNode?
    var playingScreen: SKShapeNode?

    private let circleMinSize: CGFloat = 15
    private let circleMaxSize: CGFloat = 70
    
    private var lastParticleAt: CGPoint?
    private var particleDistance: CGFloat = 30
    private let maxTrailsLimit: Int = 1000
    
    private var scoreBoard: ScoreBoard?
    private let scoreBoardHeight: CGFloat = 130
    
    private let goalRadius: CGFloat = 79
    
    private var goal: SKShapeNode?
    
    private let trailInterval: CGFloat = 1
    private var previousTime: TimeInterval = TimeInterval.init()
    
    private let physicsFrameRate: CGFloat = 1/60.0

    private let bgColor: SKColor = SKColor.init(red: 0.20, green: 0.15, blue: 0.20, alpha: 1.0)
    private let scoreColor: SKColor = SKColor.init(red: 0.25, green: 0.15, blue: 0.25, alpha: 1.0)
    
    var powerUps: [PowerUp] = []
    private var ballsDestroyedThisRound: Int = 0
    var currentPowerUp: PowerUp? = nil

    private var trailContainerNode: SKShapeNode? = nil
    private var inRound: Bool = false
    private var touchCircle: SKShapeNode? = nil

    private var circleNodeDLQ: Set<CircleRecord> = Set()

    override func didMove(to view: SKView) {
        let bottomBarHeight: CGFloat = 70

        screenWidth = size.width
        screenHeight = size.height
        gameHeight = screenHeight - (bottomBarHeight + scoreBoardHeight)
        screenLeft = -screenWidth/2
        screenRight = screenWidth/2
        screenTop = screenHeight/2
        screenBottom = -screenHeight/2
        gameTop = gameHeight/2
        gameBottom = -gameHeight / 2.0

        origin = CGPoint(x: 0 , y: gameBottom)
        lineOrigin = CGPoint(x: 0 , y: gameBottom)

        let scoreBoardNode = SKShapeNode.init(rectOf: CGSize.init(width: screenWidth + 2, height: scoreBoardHeight + 1))
        scoreBoardNode.position = CGPoint(x: 0, y: screenTop - scoreBoardHeight / 2.0 + 1)
        scoreBoardNode.zPosition = 30
        scoreBoardNode.lineWidth = 2
        scoreBoardNode.fillColor = scoreColor

        let label = SKLabelNode.init(text: String(1))
        label.fontSize = levelFontSize
        label.position = CGPoint(x: 0, y: screenTop - 110)
        label.fontColor = SKColor.white
        label.zPosition = 31

        let accumScoreLabel = SKLabelNode.init(text: String(0))
        accumScoreLabel.fontSize = circleScoreFontSize
        accumScoreLabel.position = CGPoint(x: screenRight - 50, y: screenTop - 110)
        accumScoreLabel.fontColor = SKColor.white
        accumScoreLabel.zPosition = 31

        let currentScoreLabel = SKLabelNode.init(text: String(0))
        currentScoreLabel.fontSize = circleScoreFontSize
        currentScoreLabel.position = CGPoint(x: screenLeft + 50, y: screenTop - 110)
        currentScoreLabel.fontColor = SKColor.white
        currentScoreLabel.zPosition = 31

        addChild(scoreBoardNode)
        addChild(label)
        addChild(accumScoreLabel)
        addChild(currentScoreLabel)

        scoreBoard = ScoreBoard.init(
            fromNode: scoreBoardNode,
            fromLevel: 1,
            fromLevelLabel: label,
            fromAccumScore: 0,
            fromAccumScoreLabel: accumScoreLabel,
            fromCurrentScore: 0,
            fromCurrentScoreLabel: currentScoreLabel,
            fromPastScore: 0
        )

        let bottomBar = SKShapeNode.init(rectOf: CGSize.init(width: screenWidth + 2, height: bottomBarHeight + 1))
        bottomBar.position = CGPoint(x: 0, y: screenBottom + bottomBarHeight / 2.0 - 1)
        bottomBar.fillColor = scoreColor
        bottomBar.lineWidth = 2
        bottomBar.zPosition = 40
        addChild(bottomBar)

        gameScreen = SKShapeNode.init(rectOf: CGSize.init(width: screenWidth, height: gameHeight))
        gameScreen?.position = CGPoint(x: 0, y: bottomBarHeight / 2.0 - scoreBoardHeight / 2.0 - 1)
        gameScreen?.strokeColor = SKColor.clear
        addChild(gameScreen!)

        playingScreen = SKShapeNode.init(rectOf: CGSize.init(width: screenWidth, height: gameHeight))
        playingScreen?.position = CGPoint(x: 0, y: 0)
        playingScreen?.fillColor = SKColor.clear
        playingScreen?.strokeColor = SKColor.clear
        gameScreen?.addChild(playingScreen!)

        trailContainerNode = SKShapeNode.init(rectOf: CGSize.init(width: screenWidth, height: gameHeight))
        trailContainerNode?.position = CGPoint(x: 0, y: 0)
        trailContainerNode?.fillColor = SKColor.clear
        trailContainerNode?.strokeColor = SKColor.clear
        gameScreen?.addChild(trailContainerNode!)

        goal = SKShapeNode(circleOfRadius: goalRadius)
        goal!.position = lineOrigin!
        goal!.strokeColor = SKColor.green
        goal!.fillColor = UIColor.green.withAlphaComponent(0.1)
        goal!.isAntialiased = true
        goal!.lineWidth = 2
        gameScreen?.addChild(goal!)

        startGame()
    }

    func startGame() {
        let bottomMargin = CGFloat(50)
        let maxRounds = 10000
        inRound = false

        scoreBoard?.resetValues()

        for circle in circles {
            circle.node.removeAllChildren()
            circle.node.removeFromParent()
        }
        circles = Set()
        ball?.node.removeFromParent()
        ball = nil
        playingScreen?.removeAllChildren()
        
        for powerUp in powerUps {
            powerUp.node.removeFromParent()
        }

        ballsDestroyedThisRound = 0

        powerUps = []

        let generationBottom = gameBottom + bottomMargin

        ballLoop: for _ in 1...Int.random(in: 3...6) {
            var position: CGPoint
            var invalidPosition: Bool = false
            var rounds: Int = 0
            repeat {
                invalidPosition = false
                if (rounds > maxRounds) {
                    continue ballLoop
                }

                position = generateRandomSeedCircleLocation(
                    generationBottom: generationBottom
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

            createCircle(atPoint: position)
        }
    }

    func generateRandomSeedCircleLocation(generationBottom: CGFloat) -> CGPoint {
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
        yClampedPosition = [CGFloat.random(in: gameBottom+circleMinSize...generationBottom+margin), CGFloat.random(in: gameTop-margin...gameTop-circleMinSize)].randomElement()!

        xUnclampedPosition = CGFloat.random(in: screenLeft+circleMinSize...screenRight-circleMinSize)
        yUnclampedPosition = CGFloat.random(in: generationBottom+circleMinSize...gameTop-circleMinSize)

        if (Bool.random()) {
            xPosition = xClampedPosition
            yPosition = yUnclampedPosition
        } else {
            xPosition = xUnclampedPosition
            yPosition = yClampedPosition
        }
        
        return CGPoint(x: xPosition, y: yPosition)
    }

    func closestDistance(from: CGPoint) -> CGFloat {
        var minDist = maxCircleSize as CGFloat
        
        let walls = [
            CGPoint(x: screenLeft, y: from.y), CGPoint(x: screenRight, y: from.y),
            CGPoint(x: from.x, y: gameBottom), CGPoint(x: from.x, y: gameTop)
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

        for powerUp in powerUps {
            let dist = CGDistance(from: from, to: powerUp.node.position)
            let adjustedDistance = dist - CGFloat(powerUp.radius)

            let scaledDistance = adjustedDistance * (1 - lineScalingFactor/2)
            
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
        if touchCircle != nil {
            touchCircle?.removeFromParent()
        }
        touchCircle = SKShapeNode.init(circleOfRadius: 15)
        touchCircle?.fillColor = SKColor.white.withAlphaComponent(0.2)
        touchCircle?.strokeColor = SKColor.clear
        touchCircle?.position = pos
        gameScreen?.addChild(touchCircle!)
        if (ball == nil) {
            drawLine(atPoint: pos)
        }
    }

    func pathForLine(atPoint pos: CGPoint) -> CGMutablePath {
        let pathToDraw = CGMutablePath()
        var expandedX = (pos.x - lineOrigin!.x)
        let expandedY = (pos.y - lineOrigin!.y)

        if expandedX == 0 {
            expandedX = 0.00001
        }

        let slope = expandedY / expandedX
        var position: CGPoint

        let topXIntercept = (gameTop - gameBottom) / slope
        let topDist = CGDistance(from: lineOrigin!, to: CGPoint(x: topXIntercept, y: gameTop))
        if slope > 0 {
            let rightYIntercept = screenRight * slope + gameBottom
            let topDist = CGDistance(from: lineOrigin!, to: CGPoint(x: topXIntercept, y: gameTop))
            let rightDist = CGDistance(from: lineOrigin!, to: CGPoint(x: screenRight, y: rightYIntercept))

            if topDist < rightDist {
                position = CGPoint(x: topXIntercept, y: gameTop)
            } else {
                position = CGPoint(x: screenRight, y: rightYIntercept)
            }
        } else {
            let leftYIntercept = screenLeft * slope + gameBottom
            let leftDist = CGDistance(from: lineOrigin!, to: CGPoint(x: screenLeft, y: leftYIntercept))

            if topDist < leftDist {
                position = CGPoint(x: topXIntercept, y: gameTop)
            } else {
                position = CGPoint(x: screenLeft, y: leftYIntercept)
            }
        }

        pathToDraw.move(to: CGPoint(x: lineOrigin!.x, y: lineOrigin!.y))
//        pathToDraw.addLine(to: CGPoint(x: pos.x, y: pos.y))
//        pathToDraw.addLine(to: CGPoint(x: expandedX, y: expandedY))
        pathToDraw.addLine(to: position)
        return pathToDraw
    }

    func drawLine(atPoint pos: CGPoint) {
        let pattern : [CGFloat] = [2.0, 5.0]
        let clampedYPos = max(pos.y, gameBottom)
        let path = pathForLine(atPoint: CGPoint(x: pos.x, y: clampedYPos)).copy(dashingWithPhase: 2, lengths: pattern)
        if (line == nil) {
            line = SKShapeNode()
            line!.strokeColor = SKColor.white
            line!.lineWidth = 2
            playingScreen?.addChild(line!)
        }
        line!.path = path
//        hitTestWithSegmentFromPoint()
    }

    func createCircle(atPoint pos: CGPoint, withHealth expectedHealth: Int? = nil) {
        let size = closestDistance(from: pos)
        let node = SKShapeNode.init(circleOfRadius: size)
        node.position = pos
        let color = colors.randomElement() ?? SKColor.gray
        node.strokeColor = color
        node.lineWidth = size * lineScalingFactor
        node.isAntialiased = true
        node.fillColor = color.withAlphaComponent(0.05)
        
        let health = (expectedHealth != nil ? expectedHealth : Int.random(in: 4..<7))!
        let label = SKLabelNode.init(text: String(health))
        label.fontSize = size * fontScalingFactor
        label.fontColor = color
        label.fontName = "HelveticaNeue-Light"
        label.position = CGPoint(x: 0, y: 0)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        playingScreen?.addChild(node)
        node.addChild(label)

        let circle = Circle.init(fromRadius: size, fromNode: node, fromHealth: health, fromLabel: label)

        for explosion in explosions {
            explosion.circlesHit.insert(circle)
        }
        circles.insert(circle)
    }

    func touchMoved(toPoint pos : CGPoint) {
        touchCircle?.position = pos
        if (ball == nil) {
            drawLine(atPoint: pos)
        }
    }

    func normalizeVector(vector: CGVector) -> CGVector {
        let len = CGDistance(from: CGPoint(x: 0, y: 0), to: CGPoint(x: vector.dx, y: vector.dy))
        return len > 0 ? CGVector(dx: vector.dx / len, dy: vector.dy / len) : CGVector.zero
    }

    func touchUp(atPoint pos : CGPoint) {
        touchCircle?.removeFromParent()
        touchCircle = nil
        if pos.y <= gameTop {
            if !inRound && ball == nil {
                line?.removeFromParent()
                line = nil
                let deltas = CGPoint(x: pos.x - lineOrigin!.x, y: pos.y - lineOrigin!.y)

                let velocity = getVelocity(withDeltas: deltas, withSpeed: ballInitialSpeed)
                let node = SKShapeNode.init(circleOfRadius: ballInitialRadius)

                node.fillColor = SKColor.white
                node.isAntialiased = true
                node.position = lineOrigin!

                let label = SKLabelNode.init()
                label.fontSize = ballFontSize
                label.position = CGPoint(x: 0, y: 0)
                label.horizontalAlignmentMode = .center
                label.verticalAlignmentMode = .center
                label.zPosition = 31
                label.fontName = "HelveticaNeue-Bold"

                ball = Ball(fromNode: node, withLabelNode: label, withVelocity: velocity, withSpeed: ballInitialSpeed, withRadius: ballInitialRadius)

                node.addChild(label)
                playingScreen?.addChild(node)
            }
        } else {
            startGame()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchDown(atPoint: t.location(in: gameScreen!)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchMoved(toPoint: t.location(in: gameScreen!)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            touchUp(atPoint: t.location(in: gameScreen!))
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { touchUp(atPoint: t.location(in: self)) }
    }
    
    func onBallStop() {
        ball!.node.removeFromParent()
    
        if CGDistance(from: ball!.node.position, to: lineOrigin!) > goalRadius + circleMinSize {
            createCircle(atPoint: ball!.node.position)
        }
        ball = nil
        currentPowerUp = nil

        if explosions.count == 0 {
            endRound()
        }

        PowerUp.spawnPowerUp(ballsHit: ballsDestroyedThisRound, gameScene: self)
    }

    func endRound() {
        scoreBoard?.updateLevel(newLevel: scoreBoard!.level + 1)
        scoreBoard?.accumulate()
        ballsDestroyedThisRound = 0
        inRound = false
    }

    func createExplosion(radius: CGFloat, strokeColor: UIColor, lineWidth: CGFloat, position: CGPoint) {
        let explosionNode = SKShapeNode.init(circleOfRadius: radius)
        explosionNode.strokeColor = strokeColor
        explosionNode.lineWidth = lineWidth
        explosionNode.alpha = 0.5
        explosionNode.isAntialiased = true
        explosionNode.position = position
        explosionNode.glowWidth = 1/5
        let explosion = Explosion.init(withNode: explosionNode)
        explosions.append(explosion)

        addChild(explosionNode)

        explosion.node.run(SKAction.sequence([
            SKAction.group([
                SKAction.fadeAlpha(to: 0.2, duration: 1.6),
                SKAction.scale(by: 10, duration: 1.6),
            ]),
            SKAction.removeFromParent()
        ]), completion: {
                if let index = self.explosions.index(of:explosion) {
                    self.explosions.remove(at: index)
                    if self.explosions.count == 0 && self.ball == nil {
                        self.endRound()
                    }
                }
            }
        )
    }

    func updateBallToPowerUp() {
        ball!.labelNode.text = currentPowerUp?.ballLabel() ?? ""
        ball!.node.fillColor = currentPowerUp?.ballFillColor() ?? SKColor.white
        ball!.node.strokeColor = currentPowerUp?.ballStrokeColor() ?? SKColor.white
    }

    func damageCircleBy(circle: Circle, damage: Int) {
        circle.health -= damage
        circle.labelNode.text = circle.health > 0 ? String(circle.health) : ""
        circle.node.run(SKAction.sequence([
            SKAction.scale(by: 0.9, duration: 0.1),
            SKAction.scale(by: 1.1111111111, duration: 0.1),
        ]))

        if circle.health <= 0 {
            scoreBoard?.updateCurrentScore(newScore: scoreBoard!.currentScore + 1)
            ballsDestroyedThisRound += 1

            let actions = SKAction.group([
                SKAction.scale(by: 0, duration: 0.5),
                SKAction.fadeOut(withDuration: 0.5)
            ])

            let nanoTime = DispatchTime.now().uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000
            let circleRecord = CircleRecord(fromCircle: circle, withTimestamp: timeInterval)

            circleNodeDLQ.insert(circleRecord)
            circle.node.run(actions, completion: {
                circle.node.removeFromParent()
                circle.labelNode.removeFromParent()
                self.circleNodeDLQ.remove(circleRecord)
            })
            if self.circles.contains(circle) {
                self.circles.remove(circle)
            }

            createExplosion(
                radius: circle.radius / 5.0, strokeColor: circle.node.strokeColor, lineWidth: circle.node.lineWidth / 5.0, position: circle.node.position
            )
        }
        checkCircles()
    }

    func damageCircle(circle: Circle) {
        switch currentPowerUp?.type {
            case .doubleDamage: damageCircleBy(circle: circle, damage: 2)
            case .skullBall:
                damageCircleBy(circle: circle, damage: circle.health)
                currentPowerUp = nil
                updateBallToPowerUp()
            default: damageCircleBy(circle: circle, damage: 1)
        }
    }

    func randomDamageCircles() {
        for circle in circles {
            let damage = Int.random(in: 0...circle.health)
            damageCircleBy(circle: circle, damage: damage)
        }
    }

    func checkCircles() {
        let nanoTime = DispatchTime.now().uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000
        for record in circleNodeDLQ {
            let circle = record.circle
            let timestamp = record.timestamp
            if timestamp > timeInterval + 600 {
                circle.node.removeFromParent()
                circle.labelNode.removeFromParent()
                self.circleNodeDLQ.remove(record)
            }
        }
    }

    func onCollideWithCircle(ballCenter: CGPoint, circle: Circle) -> CGPoint {
        let collisionVector = normalizeVector(vector: CGVector(dx: ballCenter.x - circle.node.position.x , dy: ballCenter.y - circle.node.position.y))
        let normalizedVelocity = normalizeVector(vector: ball!.velocity)

        let tangent = normalizeVector(vector: CGVector(dx: circle.node.position.y - ballCenter.y, dy: ballCenter.x - circle.node.position.x))
        let length = normalizedVelocity.dot(tangent)
        let velocityComponentOnTangent = length * tangent
        let velocityComponentPerpendicularToTangent = normalizedVelocity - velocityComponentOnTangent
        let resultant = normalizedVelocity - 2 * velocityComponentPerpendicularToTangent

        let normalizedResultant = normalizeVector(vector: resultant)

        if currentPowerUp?.type == PowerUpType.superBounce {
            ball!.speed = ballInitialSpeed
        }
        
        ball!.velocity = CGVector(dx: ball!.speed * normalizedResultant.dx, dy: ball!.speed * normalizedResultant.dy)

        let distance = ball!.radius + circle.radius
        let collisionPosition = CGPoint(x: circle.node.position.x + collisionVector.dx * distance, y: circle.node.position.y + collisionVector.dy * distance)
        let ballPosition = collisionPosition

        damageCircle(circle: circle)

        generateParticles(position: ball!.node.position, color: circle.node.fillColor.withAlphaComponent(1.0))

        if currentPowerUp?.type == .shockOnBounce {
            createExplosion(radius: 15, strokeColor: SKColor.red, lineWidth: 3, position: ballCenter)
        }

        return ballPosition
    }

    func scaledAcceleration(speed: CGFloat) -> CGFloat {
        let normalizedSpeed = speed / ballInitialSpeed
        let accel = ballAcceleration * normalizedSpeed
        return min(-0.05, accel)
    }

    func updateExplosions() {
        for explosion in explosions {
            for circle in circles {
                if CGDistance(from: circle.node.position, to: explosion.node.position) < circle.radius + explosion.node.frame.width / 2.0 {
                    if !explosion.circlesHit.contains(circle) {
                        damageCircle(circle: circle)
                        explosion.circlesHit.insert(circle)
                    }
                }
            }
        }
    }
    
    func swapBallNode() {
        let node = SKShapeNode.init(circleOfRadius: ball!.radius)
        
        node.fillColor = SKColor.white
        node.isAntialiased = true
        node.position = ball!.node.position

        ball!.node.removeFromParent()
        ball!.node = node
        playingScreen?.addChild(node)
        trailContainerNode?.removeAllChildren()
    }

    func checkPowerUpCollisions(ballPosition: CGPoint) {
        for (i, powerUp) in powerUps.enumerated() {
            if CGDistance(from: ballPosition, to: powerUp.node.position) <= CGFloat(powerUp.radius) + ball!.radius {
                powerUp.activate(gameScene: self, index: i)
            }
        }
    }
    
    func generateRandomValidPowerUpLocation(radius: CGFloat) -> CGPoint {
        var rounds = 0
        let maxRounds = 10000
        var invalidPosition = false
        var position: CGPoint = origin!
        repeat {
            invalidPosition = false
            if (rounds > maxRounds) {
                break
            }
            var xPosition: CGFloat
            var yPosition: CGFloat
            let margin: CGFloat = 15

            xPosition = CGFloat.random(in: screenLeft+margin...screenRight-margin)
            yPosition = CGFloat.random(in: gameBottom+margin...gameTop-margin)
            
            position = CGPoint(x: xPosition, y: yPosition)
            
            // If the position is too close to the goal post we can't spawn circle there
            if CGDistance(from: origin!, to: position) < goalRadius + margin {
                invalidPosition = true
            }

            for powerUp in powerUps {
                if CGDistance(from: position, to: powerUp.node.position) <= 2 * radius {
                    invalidPosition = true
                }
            }
            
            for circle in circles {
                // If this is inside any of the other circles, then we haven't found a valid position yet. Keep looking
                if CGDistance(from: position, to: circle.node.position) <= circle.radius + margin {
                    invalidPosition = true
                }
            }
            rounds+=1
        } while (invalidPosition)

        return position
    }


    func generateParticles(position: CGPoint, color: UIColor = UIColor.white) {
        if lastParticleAt == nil || CGDistance(from: position, to: lastParticleAt!) > particleDistance {
            if let emitter = SKEmitterNode(fileNamed: "TrailParticle.sks") {
                emitter.position = ball!.node.position // center of screen
                emitter.name = "boom"
                emitter.targetNode = self
                emitter.zPosition = 10
                emitter.particleZPosition = 10
                emitter.numParticlesToEmit = Int.random(in: 5...10)
                emitter.particleColorSequence = nil
                emitter.particleColor = color
                addChild(emitter)

                let duration = 0.5
                emitter.run(SKAction.sequence([
                    SKAction.wait(forDuration: 0.0),
                    SKAction.group([
                        SKAction.scale(by: 0, duration: duration),
                    ]),
                    SKAction.removeFromParent()
                ]))
            }
        }

        lastParticleAt = position
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func checkWallCollisions(ballPosition: CGPoint) {
        // collision with walls
        var ballCollided = false

        if ballPosition.x - ball!.radius <= screenLeft && ball!.velocity.dx < 0 {
            ball!.velocity.dx = abs(ball!.velocity.dx)
            ballCollided = true
        }
        else if ballPosition.x + ball!.radius >= screenRight && ball!.velocity.dx > 0 {
            ball!.velocity.dx = -abs(ball!.velocity.dx)
            ballCollided = true
        }
        else if ballPosition.y - ball!.radius <= gameBottom && ball!.velocity.dy < 0 {
            ball!.velocity.dy = abs(ball!.velocity.dy)
            ballCollided = true
        }
        else if ballPosition.y + ball!.radius >= gameTop && ball!.velocity.dy > 0 {
            ball!.velocity.dy = -abs(ball!.velocity.dy)
            ballCollided = true
        }

        if ballPosition.x < screenLeft {
            ball!.node.position.x = screenLeft + ball!.radius
        }

        if ballPosition.y < gameBottom {
            ball!.node.position.y = gameBottom + ball!.radius
        }

        if ballPosition.x > screenRight {
            ball!.node.position.x = screenRight - ball!.radius
        }

        if ballPosition.x > gameTop {
            ball!.node.position.y = gameTop - ball!.radius
        }

        if ballCollided {
            generateParticles(position: ball!.node.position)
        }
    }

    func cleanUp() {
        if trailContainerNode!.children.count > maxTrailsLimit {
            trailContainerNode?.removeAllChildren()
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

//                ball!.speed += min(scaledAcceleration(speed: ball!.speed), maxSpeedLimit) // ballAcceleration
                ball!.speed += scaledAcceleration(speed: ball!.speed) // ballAcceleration
                ball!.velocity = ball!.speed * normalizeVector(vector: ball!.velocity)

                let originalBallPosition = ballPosition
                checkWallCollisions(ballPosition: ballPosition)

                checkPowerUpCollisions(ballPosition: ballPosition)

                // collision with other circles
                for circle in circles {
                    if CGDistance(from: originalBallPosition, to: circle.node.position) <= circle.radius + ball!.radius {
                        ballPosition = onCollideWithCircle(ballCenter: originalBallPosition, circle: circle)
                    }
                }

                // Make trails
                let travelVector = normalizeVector(vector: CGVector(dx: ballPosition.x - ball!.node.position.x, dy: ballPosition.y - ball!.node.position.y))
                var trailPosition = ball!.node.position
                let scaledTravelVector = CGVector(dx: trailInterval * travelVector.dx, dy: trailInterval * travelVector.dy)

                let distance = CGDistance(from: ball!.node.position, to: ballPosition)
                let distanceIntervals = Int(distance/trailInterval)
                for i in 0...distanceIntervals {
                    let trailNode = SKShapeNode.init(circleOfRadius: ball!.radius * 0.75)
                    trailNode.fillColor = SKColor.lightGray
                    trailNode.lineWidth = 0
                    trailNode.strokeColor = SKColor.lightGray
                    trailNode.alpha = 1
                    trailNode.isAntialiased = true
                    trailNode.position = trailPosition
                    trailNode.glowWidth = 2
                    trailNode.zPosition = -1

                    trailPosition.x += scaledTravelVector.dx
                    trailPosition.y += scaledTravelVector.dy

                    trailContainerNode?.addChild(trailNode)

                    let duration = 0.2
                    trailNode.run(SKAction.sequence([
                        SKAction.wait(forDuration: Double(i) * 0.0005),
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

        cleanUp()

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
