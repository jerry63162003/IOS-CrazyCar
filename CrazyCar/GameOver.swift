//
//  GameOver.swift
//  CarsGame
//
//  Created by roy on 2018/7/6.
//  Copyright © 2018年 Nitay&Raz. All rights reserved.
//

import Foundation
import SpriteKit

class GameOver: SKScene {
    
    var exit = SKSpriteNode()
    var tryAgin = SKSpriteNode()
    var bestScore = SKLabelNode()
    var gameSettings = Settings.sharedInstance
    var score = 0
    
    override func didMove(to view: SKView) {
        exit = self.childNode(withName: "exit") as! SKSpriteNode
        tryAgin = self.childNode(withName: "tryAgin") as! SKSpriteNode
        bestScore = self.childNode(withName: "bestScore") as! SKLabelNode
        
        bestScore.text = "得分: \(score)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            
            if atPoint(touchLocation).name == "exit" {
                let gameMenu = SKScene(fileNamed: "GameMenu")!
                gameMenu.scaleMode = .aspectFill
                
                view?.presentScene(gameMenu, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(1)))
            }
            if atPoint(touchLocation).name == "tryAgin" {
                var gameScence = SKScene(fileNamed: "SingleGameScene")!
                
                gameScence.scaleMode = .aspectFill
                
                view?.presentScene(gameScence, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(1)))
                
            }
        }
    }
}
