//
//  GameScene.swift
//  Sushi Neko
//
//  Created by Jacob Abrams on 7/10/17.
//  Copyright © 2017 Jacob Abrams. All rights reserved.
//

import SpriteKit

enum Side {
    case left, right, none
}

/* Tracking enum for game state */
enum GameState {
    case title, ready, playing, gameOver
}

class GameScene: SKScene {
    /* Game objects */
    var sushiBasePiece: SushiPiece!
    /* Cat Character */
    var character: Character!
    /* Sushi tower array */
    var sushiTower: [SushiPiece] = []
    /* Game management */
    var state: GameState = .title
    var playButton: MSButtonNode!
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        /* Connect game objects */
        character = childNode(withName: "character") as! Character
        /* Connect game objects */
        sushiBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
        /* Setup chopstick connections */
        sushiBasePiece.connectChopsticks()
        /* Manually stack the start of the tower */
        addTowerPiece(side: .none)
        addTowerPiece(side: .right)
        /* Randomize tower to just outside of the screen */
        addRandomPieces(total: 10)
        /* UI game objects */
        playButton = childNode(withName: "playButton") as! MSButtonNode
        /* Setup play button selection handler */
        playButton.selectedHandler = {
            /* Start game */
            self.state = .ready
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        
        /* Game not ready to play */
        if state == .gameOver || state == .title { return }
        /* Game begins on first touch */
        if state == .ready {
            state = .playing
        }
        
        /* We only need a single touch here */
        let touch = touches.first!
        
        /* Get touch position in scene */
        let location = touch.location(in: self)
        
        /* Was touch on left/right hand side of screen? */
        if location.x > size.width / 2 {
            character.side = .right
        } else {
            character.side = .left
        }
        /* Grab sushi piece on top of the base sushi piece, it will always be 'first' */
        if let firstPiece = sushiTower.first {
            /* Check character side against sushi piece side (this is our death collision check)*/
            if character.side == firstPiece.side {
                gameOver()
                /* No need to continue as player is dead */
                return
            }
            /* Remove from sushi tower array */
            sushiTower.removeFirst()
            /* Animate the punched sushi piece */
            firstPiece.flip(character.side)
            /* Add a new sushi piece to the top of the sushi tower */
            addRandomPieces(total: 1)
        }
    }
    
    func moveTowerDown() {
        var n: CGFloat = 0
        for piece in sushiTower {
            let y = (n * 55) + 215
            piece.position.y -= (piece.position.y - y) * 0.5
            n += 1
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        moveTowerDown()
    }
    
    func addTowerPiece(side: Side) {
        /* Add a new sushi piece to the sushi tower */
        
        /* Copy original sushi piece */
        let newPiece = sushiBasePiece.copy() as! SushiPiece
        newPiece.connectChopsticks()
        
        /* Access last piece properties */
        let lastPiece = sushiTower.last
        
        /* Add on top of last piece, default on first piece */
        let lastPosition = lastPiece?.position ?? sushiBasePiece.position
        newPiece.position.x = lastPosition.x
        newPiece.position.y = lastPosition.y + 55
        
        /* Increment Z to ensure it's on top of the last piece, default on first piece*/
        let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
        newPiece.zPosition = lastZPosition + 1
        
        /* Set side */
        newPiece.side = side
        
        /* Add sushi to scene */
        addChild(newPiece)
        
        /* Add sushi piece to the sushi tower */
        sushiTower.append(newPiece)
    }
    
    func addRandomPieces(total: Int) {
        /* Add random sushi pieces to the sushi tower */
        
        for _ in 1...total {
            
            /* Need to access last piece properties */
            let lastPiece = sushiTower.last!
            
            /* Need to ensure we don't create impossible sushi structures */
            if lastPiece.side != .none {
                addTowerPiece(side: .none)
            } else {
                
                /* Random Number Generator */
                let rand = arc4random_uniform(100)
                
                if rand < 45 {
                    /* 45% Chance of a left piece */
                    addTowerPiece(side: .left)
                } else if rand < 90 {
                    /* 45% Chance of a right piece */
                    addTowerPiece(side: .right)
                } else {
                    /* 10% Chance of an empty piece */
                    addTowerPiece(side: .none)
                }
            }
        }
    }
    
    func gameOver() {
        /* Game over! */
        
        state = .gameOver
        
        /* Turn all the sushi pieces red*/
        for sushiPiece in sushiTower {
            sushiPiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        }
        
        /* Make the base turn red */
        sushiBasePiece.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        
        /* Make the player turn red */
        character.run(SKAction.colorize(with: UIColor.red, colorBlendFactor: 1.0, duration: 0.50))
        
        /* Change play button selection handler */
        playButton.selectedHandler = {
            
            /* Grab reference to the SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load Game scene */
            guard let scene = GameScene(fileNamed:"GameScene") as GameScene! else {
                return
            }
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .aspectFill
            
            /* Restart GameScene */
            skView?.presentScene(scene)
        }
}
}
