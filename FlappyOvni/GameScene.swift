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
    
    var timerTuberia: Timer?
    
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
        timerTuberia = Timer.scheduledTimer(withTimeInterval: 2, repeats: true,
                                           block: {_ in self.creaTubos()})
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
    
    func creaTubos(){
        let tuboSuperior = SKSpriteNode(imageNamed: "tubo1")
        let enMedio = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 15, height: 230))
        let tuboInferior = SKSpriteNode(imageNamed: "tubo2")
        
        let anchoTubos = tuboSuperior.size.width
        let altoTubos = tuboInferior.size.height*1.5
        
        tuboSuperior.size = CGSize(width: anchoTubos, height: altoTubos)
        tuboSuperior.physicsBody = SKPhysicsBody(texture: tuboSuperior.texture!,
                                                 size: tuboSuperior.size)
        tuboSuperior.physicsBody?.affectedByGravity = false
        tuboSuperior.physicsBody?.allowsRotation = false
        tuboSuperior.physicsBody?.isDynamic = false
        
        enMedio.isHidden = true
        enMedio.physicsBody = SKPhysicsBody(rectangleOf: enMedio.size)
        enMedio.physicsBody?.affectedByGravity = false
        enMedio.physicsBody?.isDynamic = true
        
        tuboInferior.size = CGSize(width: anchoTubos, height: altoTubos)
        tuboInferior.physicsBody = SKPhysicsBody(texture: tuboInferior.texture!,
                                                 size: tuboInferior.size)
        tuboInferior.physicsBody?.affectedByGravity = false
        tuboInferior.physicsBody?.allowsRotation = false
        tuboInferior.physicsBody?.isDynamic = false
        
        let inicioX = size.width/2 + anchoTubos
        let numeroAleatorio = CGFloat(arc4random_uniform(UInt32(3)))+2
        tuboSuperior.position = CGPoint(x: inicioX, y: size.height/numeroAleatorio)
        
        enMedio.position = CGPoint(x: inicioX,
                                   y: tuboSuperior.position.y -
                                    tuboSuperior.size.height + 365)

        let tuboInferiorY = tuboSuperior.position.y - tuboSuperior.size.height - 230
        tuboInferior.position = CGPoint(x: inicioX, y: tuboInferiorY)
        
        let finX = -size.width - anchoTubos*2
        let desplazamiento = SKAction.moveBy(x: finX, y: 0, duration: 4)
        
        tuboSuperior.run(SKAction.sequence([desplazamiento,SKAction.removeFromParent()]))
        enMedio.run(SKAction.sequence([desplazamiento,SKAction.removeFromParent()]))
        tuboInferior.run(SKAction.sequence([desplazamiento,SKAction.removeFromParent()]))
        
        addChild(tuboSuperior)
        addChild(enMedio)
        addChild(tuboInferior)
    }
    
}
