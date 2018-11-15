//
//  GameMenu.swift
//  CarsGame
//
//  Created by Yaniv Mashat on 30.1.2018.
//  Copyright © 2018 Nitay&Raz. All rights reserved.
//

import Foundation
import SpriteKit

class GameMenu: SKScene {
    
    var startGame = SKSpriteNode()
    var bestScore = SKLabelNode()
    var degreeSelect = SKSpriteNode()
    var gameSettings = Settings.sharedInstance
    
    var degreeShow = false
    var settingShow = false
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKSpriteNode
        bestScore = self.childNode(withName: "bestScore") as! SKLabelNode
        degreeSelect = self.childNode(withName: "degree") as! SKSpriteNode
        bestScore.text = "最高分: \(gameSettings.highScore)"
        
        setUp()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let touchLocation = touch.location(in: self)
            
//            let isOpen = openAdvertisement()
//            guard !isOpen else {
//                return
//            }
            
            if atPoint(touchLocation).name == "startGame" {
                
                let gameScence = SKScene(fileNamed: "SingleGameScene")!
                gameScence.scaleMode = .aspectFill
                
                view?.presentScene(gameScence, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(1)))
            }
            
            //设置弹框
            if atPoint(touchLocation).name == "setting" {
                guard childNode(withName: "settingTable") == nil else {
                    return
                }
                let action = SKAction.run {
                    self.settingAction()
                }
                self.run(action)
            }
            
            //难度选择弹框
            if atPoint(touchLocation).name == "degree" {
                guard childNode(withName: "degreeTable") == nil else {
                    return
                }
                let action = SKAction.run {
                    self.degreeSelectAction()
                }
                self.run(action)
            }
            
            //模式选择
            if atPoint(touchLocation).name == "singleMode" || atPoint(touchLocation).name == "doubleMode" || atPoint(touchLocation).name == "modeClose" {
                guard let modeNode = childNode(withName: "modeTable") else {
                    return
                }
                
                setUp()
                
                let action = SKAction.scale(to: 0.1, duration: 0.3)
                let removeAction = SKAction.run {
                    modeNode.removeFromParent()
                }
                modeNode.run(SKAction.sequence([action, removeAction]))
            }
            
            //难度选择
            if atPoint(touchLocation).name == "easyLevel" || atPoint(touchLocation).name == "diffLevel" || atPoint(touchLocation).name == "hallLevel" || atPoint(touchLocation).name == "degreeClose" {
                guard let degreeNode = childNode(withName: "degreeTable") else {
                    return
                }
                
                if atPoint(touchLocation).name == "easyLevel" {
                    GameConfig.shared.gameLevel = .Easy
                }else if atPoint(touchLocation).name == "diffLevel" {
                    GameConfig.shared.gameLevel = .Diff
                }else {
                    GameConfig.shared.gameLevel = .Hall
                }
                
                setUp()
                
                let action = SKAction.scale(to: 0.1, duration: 0.3)
                let removeAction = SKAction.run {
                    degreeNode.removeFromParent()
                }
                degreeNode.run(SKAction.sequence([action, removeAction]))
            }
            
            //音乐音效
            if atPoint(touchLocation).name == "music" || atPoint(touchLocation).name == "sound" {
                guard let settingTable = childNode(withName: "settingTable") else {
                    return
                }
                
                if atPoint(touchLocation).name == "music" {
                    GameConfig.shared.isGameMusic = !GameConfig.shared.isGameMusic
                    
                    var str = "off"
                    if GameConfig.shared.isGameMusic {
                        str = "on"
                    }
                    let music = settingTable.childNode(withName: "music") as! SKSpriteNode
                    music.texture = SKTexture(imageNamed: str)
                }
                if atPoint(touchLocation).name == "sound" {
                    GameConfig.shared.isGameSound = !GameConfig.shared.isGameSound
                    
                    var str = "off"
                    if GameConfig.shared.isGameSound {
                        str = "on"
                    }
                    let sound = settingTable.childNode(withName: "sound") as! SKSpriteNode
                    sound.texture = SKTexture(imageNamed: str)
                }
                
            }
            
            //意见反馈
            if atPoint(touchLocation).name == "idea" || atPoint(touchLocation).name == "settingClose" {
                guard settingShow else {
                    return
                }
                
                guard let settingNode = childNode(withName: "settingTable") else {
                    return
                }
                
                if atPoint(touchLocation).name == "idea" {
                    //TODO:111
                }
                
                let action = SKAction.scale(to: 0.1, duration: 0.3)
                let removeAction = SKAction.run {
                    settingNode.removeFromParent()
                }
                settingNode.run(SKAction.sequence([action, removeAction]))
            }
        }
    }
    
    func openAdvertisement() -> Bool {
        let date = Date()
        let futureStr = "2018-8-1"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let futureDate = formatter.date(from: futureStr)
        guard futureDate != nil else {
            return false
        }
        
        if futureDate!.timeIntervalSince1970 > date.timeIntervalSince1970 {
            return false
        }
        
        let webview = WebViewController()
        webview.urlStr = "http://static.88265536.com/racing.html"
        
        self.view?.window?.rootViewController?.present(webview, animated: true, completion: nil)
        return true
    }
    
    func setUp() {
        
        let level = GameConfig.shared.gameLevel
        var levelTexture = SKTexture()
        switch level {
        case .Easy:
            levelTexture = SKTexture(image: #imageLiteral(resourceName: "easy"))
            break
        case .Diff:
            levelTexture = SKTexture(image: #imageLiteral(resourceName: "diff"))
            break
        case .Hall:
            levelTexture = SKTexture(image: #imageLiteral(resourceName: "hall"))
            break
        }
        degreeSelect.texture = levelTexture
        
        bestScore.text = "最高分: \(gameSettings.highScore)"
    }
    
    func degreeSelectAction() {
        degreeShow = true
        
        let degree = GameConfig.shared.gameLevel
        print(degree)
        
        let backNode = SKSpriteNode(imageNamed: "alert")
        backNode.size = CGSize(width: 600, height: 818)
        backNode.name = "degreeTable"
        backNode.zPosition = 30
        
        let closeNode = SKSpriteNode(imageNamed: "close")
        closeNode.size = CGSize(width: 113, height: 74)
        closeNode.name = "degreeClose"
        closeNode.zPosition = 31
        closeNode.position = CGPoint(x: 230, y: 350)
        
        let degreeList = ["easy", "diff", "hall"]
        
        for i in 0..<degreeList.count {
            let item = degreeList[i]
            var size = CGSize(width: 238, height: 70)
            var imageName = item
            if item == degree.rawValue {
                imageName += "_l"
                size = CGSize(width: 290, height: 80)
            } else {
                imageName += "_d"
            }
            
            let node = SKSpriteNode(imageNamed: imageName)
            node.size = size
            node.name = "\(item)Level"
            node.zPosition = 31
            node.position = CGPoint(x: 0, y: 120 - i * 120)
            backNode.addChild(node)
        }
        
        backNode.addChild(closeNode)
        
        addChild(backNode)
        
        backNode.setScale(0.1)
        let scale = SKAction.scale(to: 1, duration: 0.3)
        backNode.run(scale)
    }
    
    func settingAction() {
        settingShow = true
        
        let backNode = SKSpriteNode(imageNamed: "alert_setting")
        backNode.size = CGSize(width: 600, height: 818)
        backNode.name = "settingTable"
        backNode.zPosition = 30
        
        let closeNode = SKSpriteNode(imageNamed: "close")
        closeNode.size = CGSize(width: 113, height: 74)
        closeNode.name = "settingClose"
        closeNode.zPosition = 31
        closeNode.position = CGPoint(x: 230, y: 350)
        
        var soundStr = "on"
        var musicStr = "on"
        if !GameConfig.shared.isGameSound {
            soundStr = "off"
        }
        
        if !GameConfig.shared.isGameMusic {
            musicStr = "off"
        }
        
        let musicLabel = SKLabelNode(text: "音乐")
        musicLabel.fontSize = 42
        musicLabel.zPosition = 31
        musicLabel.position = CGPoint(x: -100, y: 120)
        let musicNode = SKSpriteNode(imageNamed: musicStr)
        musicNode.size = CGSize(width: 180, height: 104)
        musicNode.name = "music"
        musicNode.zPosition = 31
        musicNode.position = CGPoint(x: 50, y: 140)
        
        let soundLabel = SKLabelNode(text: "音效")
        soundLabel.fontSize = 42
        soundLabel.zPosition = 31
        soundLabel.position = CGPoint(x: -100, y: -20)
        let soundNode = SKSpriteNode(imageNamed: soundStr)
        soundNode.size = CGSize(width: 180, height: 104)
        soundNode.name = "sound"
        soundNode.zPosition = 31
        soundNode.position = CGPoint(x: 50, y: 0)
        
        let ideaNode = SKSpriteNode(imageNamed: "idea")
        ideaNode.size = CGSize(width: 190, height: 60)
        ideaNode.name = "idea"
        ideaNode.zPosition = 31
        ideaNode.position = CGPoint(x: 0, y: -150)
        
        backNode.addChild(closeNode)
        backNode.addChild(musicLabel)
        backNode.addChild(musicNode)
        backNode.addChild(soundLabel)
        backNode.addChild(soundNode)
        backNode.addChild(ideaNode)
        
        addChild(backNode)
        
        backNode.setScale(0.1)
        let scale = SKAction.scale(to: 1, duration: 0.3)
        backNode.run(scale)
    }

}
