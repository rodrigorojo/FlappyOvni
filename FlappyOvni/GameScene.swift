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
    var timerEstrellasHorizontal: Timer?
    var timerEstrellasVertical: Timer?
    
    var puntuacion: Int = 0
    var perdio:Bool = false
    var yaJugo: Bool = false
    
    let userDefaults = UserDefaults.standard
    let nombreFuente = "KohinoorBangla-Semibold"
    
    let categoriaOvni: UInt32 = 0x01 << 1
    let categoriaObstaculos: UInt32 = 0x01 << 2
    let categoriaPunto: UInt32 = 0x01 << 3
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        inicio()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !perdio {
            ovni?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            ovni?.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 60))
        } else {
            let touch = touches.first
            if let location = touch?.location(in: self) {
                let theNodes = nodes(at: location)
                for node in theNodes{
                    if node.name == "repetir"{
                        scene?.removeAllChildren()
                        perdio = false
                        creaJuego()
                    }
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let categorias = [contact.bodyA.categoryBitMask, contact.bodyB.categoryBitMask]
        
        if categorias.contains(categoriaObstaculos) && categorias.contains(categoriaObstaculos) {
            contact.bodyA.categoryBitMask = 0
            contact.bodyB.categoryBitMask = 0
            self.speed = 0
            timerTuberia?.invalidate()
            perdio = true
            self.removeAllChildren()
            inicio()
        }
        if categorias.contains(categoriaPunto) && categorias.contains(categoriaPunto) {
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
        creaFondo()
        timerEstrellasVertical?.invalidate()
        timerEstrellasHorizontal = Timer.scheduledTimer(withTimeInterval: 0.1,
                                                        repeats: true,
                                                        block: { _ in self.creaEstrellasHorizontales() })
        creaOvni()
        timerTuberia = Timer.scheduledTimer(withTimeInterval: 2, repeats: true,
                                           block: {_ in self.creaTubos()})
        creaPiso()
        creaEtiqueta()
        yaJugo = true
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
    
    func inicio(){
        creaFondo()
        timerEstrellasHorizontal?.invalidate()
        timerEstrellasVertical = Timer.scheduledTimer(withTimeInterval: 0.5,
                                                      repeats: true,
                                                      block: { _ in self.creaEstrellasVerticales() })
        perdio = true
        self.speed = 1
        
        let tamFila = size.height/20
        let titulo = SKLabelNode(fontNamed: nombreFuente)
        titulo.fontSize = CGFloat(tamFila * 1.5)
        titulo.text = "Flappy Ovni"
        titulo.position = CGPoint(x: 0, y: tamFila * 7)
        titulo.zPosition = 1
        
        let valorMasAlta = puntuacionMasAlta(puntuacion)
        
        let tituloMasAlta = SKLabelNode(fontNamed: nombreFuente)
        tituloMasAlta.fontSize = CGFloat(tamFila * 0.8)
        tituloMasAlta.text = "Puntuación más alta:"
        tituloMasAlta.position = CGPoint(x: 0, y: tamFila * 3)
        tituloMasAlta.zPosition = 1
        
        let masAlta = SKLabelNode(fontNamed: nombreFuente)
        masAlta.fontSize = CGFloat(tamFila)
        masAlta.position = CGPoint(x: 0, y: tamFila * 2)
        masAlta.text = "\(valorMasAlta)"
        masAlta.zPosition = 1
        
        let tituloPuntuacion = SKLabelNode(fontNamed: nombreFuente)
        tituloPuntuacion.fontSize = CGFloat(tamFila * 0.8)
        tituloPuntuacion.text = "Tu puntuación:"
        tituloPuntuacion.position = CGPoint(x: 0, y: 0)
        tituloPuntuacion.zPosition = 1
        
        let puntos = SKLabelNode(fontNamed: nombreFuente)
        puntos.fontSize = CGFloat(tamFila)
        puntos.position = CGPoint(x: 0, y: -tamFila)
        puntos.text = "\(puntuacion)"
        puntos.zPosition = 1
        
        let boton = SKSpriteNode(imageNamed: "play")
        boton.name = "repetir"
        boton.position = CGPoint(x: 0, y: -tamFila * 4)
        boton.zPosition = 1
        
        puntuacion = 0
        
        addChild(titulo)
        addChild(tituloMasAlta)
        addChild(masAlta)
        if yaJugo{
            addChild(tituloPuntuacion)
            addChild(puntos)
        }
        addChild(boton)
    }
    
    func creaFondo(){
        let fondo = SKSpriteNode(imageNamed: "fondo-azul")
        fondo.position = CGPoint(x: 0.0, y: 0.0)
        fondo.zPosition = -2
        fondo.size = CGSize(width: size.width, height: size.height)
        addChild(fondo)
    }
    
    func creaEstrellasVerticales(){
        let numEstrella1 = arc4random_uniform(UInt32(4))+1
        let numEstrella2 = arc4random_uniform(UInt32(4))+1
        let estrella1 = SKSpriteNode(imageNamed: "estrella-\(numEstrella1)")
        let estrella2 = SKSpriteNode(imageNamed: "estrella-\(numEstrella2)")
        
        let tamAleatorio = CGFloat(arc4random_uniform(UInt32(20)))+5
        estrella1.size = CGSize(width: tamAleatorio, height: tamAleatorio)
        estrella2.size = CGSize(width: tamAleatorio, height: tamAleatorio)
        
        let xAleatorio1 = -CGFloat(arc4random_uniform(UInt32(size.width/2)))
        let xAleatorio2 = CGFloat(arc4random_uniform(UInt32(size.width/2)))
        estrella1.position = CGPoint(x: xAleatorio1, y: size.height/2)
        estrella2.position = CGPoint(x: xAleatorio2, y: size.height/2)

        let desplaza = SKAction.moveTo(y: -size.height/2, duration: 6)
        estrella1.run(SKAction.sequence([desplaza, SKAction.removeFromParent()]))
        estrella2.run(SKAction.sequence([desplaza, SKAction.removeFromParent()]))
        
        estrella1.zPosition = -1
        estrella2.zPosition = -1
        
        addChild(estrella1)
        addChild(estrella2)
    }
    
    func creaEstrellasHorizontales(){
        let numEstrella1 = arc4random_uniform(UInt32(4))+1
        let numEstrella2 = arc4random_uniform(UInt32(4))+1
        let estrella1 = SKSpriteNode(imageNamed: "estrella-\(numEstrella1)")
        let estrella2 = SKSpriteNode(imageNamed: "estrella-\(numEstrella2)")
        
        let tamAleatorio = CGFloat(arc4random_uniform(UInt32(20)))+5
        estrella1.size = CGSize(width: tamAleatorio, height: tamAleatorio)
        estrella2.size = CGSize(width: tamAleatorio, height: tamAleatorio)
        
        let yAleatorio1 = CGFloat(arc4random_uniform(UInt32(size.height/2)))
        let yAleatorio2 = -CGFloat(arc4random_uniform(UInt32(size.height/2)))
        estrella1.position = CGPoint(x: size.height/2, y: yAleatorio1)
        estrella2.position = CGPoint(x: size.height/2, y: yAleatorio2)
        
        
        let desplaza = SKAction.moveTo(x: -size.height/2, duration: 5.8)
        estrella1.run(SKAction.sequence([desplaza, SKAction.removeFromParent()]))
        estrella2.run(SKAction.sequence([desplaza, SKAction.removeFromParent()]))
        
        estrella1.zPosition = -1
        estrella2.zPosition = -1
        
        addChild(estrella1)
        addChild(estrella2)
    }
    
}
