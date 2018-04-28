//
//  GameScene.swift
//  FlappyOvni
//
//  Created by Rodrigo Rojo on 4/28/18.
//  Copyright © 2018 Rodrigo Rojo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var ovni: SKSpriteNode?
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        creaJuego()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ovni?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ovni?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        
    }
    
    func creaJuego(){
        creaOvni()
    }
    
    func creaOvni(){
        ovni = SKSpriteNode(imageNamed: "ovni")
        ovni?.position = CGPoint(x: -150, y: 0)
        ovni?.size = CGSize(width: 100, height: 100)
        ovni?.physicsBody = SKPhysicsBody(texture: (ovni?.texture)!, size: (ovni?.size)!)
        ovni?.physicsBody?.allowsRotation = false
        ovni?.physicsBody?.isDynamic = true
        addChild(ovni!)
    }
    
}
