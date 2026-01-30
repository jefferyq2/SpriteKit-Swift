//
//  GameScene.swift
//  swiftgame
//
//  Created by Stephen Chan on 6/3/14.
//  Copyright (c) 2014 Squid Ink Games. All rights reserved.
//

import Foundation
import SpriteKit

struct ContactCategory {
    static let charactor : UInt32 = 0x1 << 0
    static let star      : UInt32 = 0x1 << 1
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let sound : SKAction = SKAction.playSoundFileNamed("star.caf", waitForCompletion: false)
    
    var isJump : Bool = false
    
    var background : SKSpriteNode!
    var parallax : [ParallaxSprite]!
    var player : SKSpriteNode!
    var stars : [SKSpriteNode] = []
    
    var starCounter : Int = 0
    
    override func didMove(to view: SKView) {
        let ref = CreateManager.createBackground(self);
        
        background = ref.background
        parallax = ref.parallax
    
        player = CreateManager.createCharacter(self)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
   
    override func update(_ currentTime: TimeInterval) {
        for p : ParallaxSprite in parallax {
            p.update()
        }
        
        self.updateStars()
    }
    
    func updateStars() {
        starCounter += 1
        
        if(starCounter % 50 == 0){
            stars.insert(CreateManager.createStar(self), at: 0)
        }
        
        for index in stride(from: stars.count - 1, through: 0, by: -1) {
            let star : SKSpriteNode = stars[index]
            star.position.x -= 10
            
            if(star.position.x < 0 - star.size.width){
                stars.remove(at: index)
                star.removeFromParent()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!isJump){
            if let _ = touches.first {
                
                let jumpAction : SKAction = SKAction.move(to: CGPoint(x: player.position.x, y: player.position.y + 200), duration: 0.3)
                let fallAction : SKAction = SKAction.move(to: CGPoint(x: player.position.x, y: self.frame.midY - 150), duration: 0.3)
                let completeAction : SKAction = SKAction.run({
                    self.isJump = false
                })

                player.run(SKAction.sequence([jumpAction, fallAction, completeAction]))
                
                isJump = true
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact){
        var firstBody : SKPhysicsBody
        var secondBody : SKPhysicsBody
        
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & ContactCategory.star) != 0) {
            self.destroyStar(firstBody.node!)
            self.run(sound)
        }
    }
    
    func destroyStar(_ star : SKNode) {
        for index in stride(from: stars.count - 1, through: 0, by: -1) {
            let s : SKSpriteNode = stars[index]
    
            if(s == star){
                stars.remove(at: index)
                star.removeFromParent()
                
                return
            }
        }
    }
}
