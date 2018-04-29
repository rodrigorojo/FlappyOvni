//
//  GameScene.swift
//  FlappyOvni
//
//  Created by Rodrigo Rojo on 4/28/18.
//  Copyright © 2018 Rodrigo Rojo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ovni: SKSpriteNode?
    var piso: SKSpriteNode?
    var puntuacionEtiqueta: SKLabelNode?
    
    var timerTuberia: Timer?
    
    var puntuacion: Int = 0
    
    let userDefaults = UserDefaults.standard
    let nombreFuente = "KohinoorBangla-Semibold"
    
    let categoriaOvni: UInt32 = 0x01 << 1
    let categoriaObstaculos: UInt32 = 0x01 << 2
    let categoriaPunto: UInt32 = 0x01 << 3
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        creaJuego()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        ovni?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        ovni?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == categoriaObstaculos ||
            contact.bodyB.categoryBitMask == categoriaObstaculos{
            print("perdiste")
        }
        if contact.bodyA.categoryBitMask == categoriaPunto ||
            contact.bodyB.categoryBitMask == categoriaPunto{
            if contact.bodyA.categoryBitMask == categoriaOvni{
                let nodo = contact.bodyB.node as? SKSpriteNode
                nodo?.removeFromParent()
            }else{
                let nodo = contact.bodyA.node as? SKSpriteNode
                nodo?.removeFromParent()
            }
            puntuacion += 1
            puntuacionEtiqueta?.text = String(puntuacion)
        }
    }
    
    func creaJuego(){
        creaOvni()
        timerTuberia = Timer.scheduledTimer(withTimeInterval: 2, repeats: true,
                                           block: {_ in self.creaTubos()})
        creaPiso()
        creaEtiqueta()
    }
    
    func creaOvni(){
        ovni = SKSpriteNode(imageNamed: "ovni")
        ovni?.position = CGPoint(x: -150, y: 0)
        ovni?.size = CGSize(width: 100, height: 100)
        ovni?.physicsBody = SKPhysicsBody(texture: (ovni?.texture)!, size: (ovni?.size)!)
        ovni?.physicsBody?.allowsRotation = false
        ovni?.physicsBody?.isDynamic = true
        
        ovni?.physicsBody?.categoryBitMask = categoriaOvni
        ovni?.physicsBody?.collisionBitMask = categoriaObstaculos
        ovni?.physicsBody?.contactTestBitMask = categoriaObstaculos | categoriaPunto
        
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
        
        tuboSuperior.physicsBody?.categoryBitMask = categoriaObstaculos
        tuboSuperior.physicsBody?.collisionBitMask = categoriaOvni
        tuboSuperior.physicsBody?.contactTestBitMask = categoriaOvni
        
        enMedio.isHidden = true
        enMedio.physicsBody = SKPhysicsBody(rectangleOf: enMedio.size)
        enMedio.physicsBody?.affectedByGravity = false
        enMedio.physicsBody?.isDynamic = true
        
        enMedio.physicsBody?.categoryBitMask = categoriaPunto
        enMedio.physicsBody?.contactTestBitMask = categoriaOvni
        
        tuboInferior.size = CGSize(width: anchoTubos, height: altoTubos)
        tuboInferior.physicsBody = SKPhysicsBody(texture: tuboInferior.texture!,
                                                 size: tuboInferior.size)
        tuboInferior.physicsBody?.affectedByGravity = false
        tuboInferior.physicsBody?.allowsRotation = false
        tuboInferior.physicsBody?.isDynamic = false
        
        tuboInferior.physicsBody?.categoryBitMask = categoriaObstaculos
        tuboInferior.physicsBody?.collisionBitMask = categoriaOvni
        tuboInferior.physicsBody?.contactTestBitMask = categoriaOvni
        
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
    
    func creaPiso(){
        piso = SKSpriteNode(imageNamed: "piso")
        piso?.size.width = size.width
        piso?.physicsBody = SKPhysicsBody(rectangleOf: (piso?.size)!)
        piso?.physicsBody?.affectedByGravity = false
        piso?.physicsBody?.pinned = true
        piso?.physicsBody?.isDynamic = false
        piso?.zPosition = 1
        piso?.position = CGPoint(x: 0, y: -size.height*0.5 + (piso?.size.height)!*0.5)
        piso?.physicsBody?.categoryBitMask = categoriaObstaculos
        piso?.physicsBody?.collisionBitMask = categoriaOvni
        piso?.physicsBody?.contactTestBitMask = categoriaOvni
        addChild(piso!)
    }
    
    func creaEtiqueta(){
        puntuacionEtiqueta = SKLabelNode(fontNamed: nombreFuente)
        puntuacionEtiqueta?.text = "0"
        puntuacionEtiqueta?.position = CGPoint(x: 0, y: size.height/2.7)
        puntuacionEtiqueta?.color = SKColor.white
        puntuacionEtiqueta?.fontSize = CGFloat(size.height/10)
        puntuacionEtiqueta?.zPosition = 1
        addChild(puntuacionEtiqueta!)
    }
    
    func puntuacionMasAlta(_ puntuacion: Int) -> Int{
        let nombrePuntuacionAlta = "puntuacionMasAlta"
        let puntuacionAltaActual = userDefaults.integer(forKey: nombrePuntuacionAlta)
        if puntuacion > puntuacionAltaActual {
            userDefaults.set(puntuacion, forKey: nombrePuntuacionAlta)
        }
        return userDefaults.integer(forKey: nombrePuntuacionAlta)
    }
}
