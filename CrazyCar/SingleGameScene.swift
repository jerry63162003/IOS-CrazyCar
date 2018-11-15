//
//  SingleGameScene.swift
//  CarsGame
//
//  Created by roy on 2018/7/4.
//  Copyright © 2018年 Nitay&Raz. All rights reserved.
//

import Foundation
import SpriteKit

class SingleGameScene: SKScene,SKPhysicsContactDelegate {
    
    enum MoveStatus: Int {
        case One = 0
        case Two = 1
        case Three = 2
        case Four = 3
    }
    
    var car = SKSpriteNode()
    var score = 0
    var canMove = false
    var moveStatus: MoveStatus = .One
    var carMoveStatus: MoveStatus = .One
    
    var  countDown = 0
    var stopEverything = true
    var isGameOver = false
    var scoreText = SKLabelNode()
    
    var leftCarMinimumX: CGFloat = -280
    var leftCarMaximumX: CGFloat = -100
    
    var rightCarMinimumX: CGFloat = 100
    var rightCarMaximumX: CGFloat = 280
    
    let carList: [CGFloat] = [-280, -100, 100, 280]
    let countlist: [String] = ["3", "2", "1"]
    
    var gameSettings = Settings.sharedInstance
    let gameConfig = GameConfig.shared
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        setUp()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(SingleGameScene.creatRoadStrip), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(SingleGameScene.startCountDown), userInfo: nil, repeats: true)
        
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBtweenTowNumbers(firsNumber: 0.4, secondNumber: 0.9)), target: self, selector: #selector(SingleGameScene.traffic), userInfo: nil, repeats: true)
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(SingleGameScene.removeItems), userInfo: nil, repeats: true)
        
        let deadtime  = DispatchTime.now()+1
        DispatchQueue.main.asyncAfter(deadline: deadtime) {
            
            Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(SingleGameScene.increaseScore), userInfo: nil, repeats: true)
        }
        
        gameConfig.beginGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        showRoadStrip()
        move(moveStatus: moveStatus)
    }
    
    func move (moveStatus: MoveStatus)
    {
        if moveStatus != carMoveStatus {
            if moveStatus.rawValue > carMoveStatus.rawValue {
                car.position.x += 20
                if car.position.x > carList[moveStatus.rawValue]{
                    car.position.x = carList[moveStatus.rawValue]
                    carMoveStatus = moveStatus
                }
            }else {
                car.position.x -= 20
                if car.position.x < carList[moveStatus.rawValue] {
                    car.position.x = carList[moveStatus.rawValue]
                    carMoveStatus = moveStatus
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar"{
            
            firstBody = contact.bodyA
            
        } else {
            
            firstBody = contact.bodyB
        }
        
        firstBody.node?.removeFromParent()
        afterCollision()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
            let touchLocaion = touch.location(in: self)
            if touchLocaion.x > car.position.x {
                if moveStatus != .Four {
                    moveStatus = MoveStatus(rawValue: moveStatus.rawValue + 1)!
                }else {
                    moveStatus = .Four
                }
            }else {
                if moveStatus != .One {
                    moveStatus = MoveStatus(rawValue: moveStatus.rawValue - 1)!
                }else {
                    moveStatus = .One
                }
            }
            canMove = true
        }
    }
    
    func afterCollision() {
        if gameSettings.highScore < score {
            
            
            gameSettings.highScore = score
        }
        
        isGameOver = true
        
        gameConfig.endGame()
        let menuScence = SKScene(fileNamed: "GameOver")!
        menuScence.scaleMode = .aspectFill
        (menuScence as! GameOver).score = score
        
        view?.presentScene(menuScence, transition: SKTransition.doorsCloseHorizontal(withDuration: TimeInterval(1)))
        
    }
    
    func showRoadStrip () {
        
        enumerateChildNodes(withName: "leftRoadStrip", using:  { (roadStrip, stop) in
            let stripf = roadStrip as! SKShapeNode
            stripf.position.y -= self.gameConfig.myCarSpeed
        })
        enumerateChildNodes(withName: "rightRoadStrip", using: { (roadStrip, stop) in
            let stripr = roadStrip as! SKShapeNode
            stripr.position.y -= self.gameConfig.myCarSpeed
        })
        enumerateChildNodes(withName: "centerRoadStrip", using: { (roadStrip, stop) in
            let stripr = roadStrip as! SKShapeNode
            stripr.position.y -= self.gameConfig.myCarSpeed
        })
        enumerateChildNodes(withName: "orangeCar", using: { (leftCar, stop) in
            let car = leftCar as! SKSpriteNode
            car.position.y -= self.gameConfig.getCarSpeed()
        })
        enumerateChildNodes(withName: "greenCar", using: { (rightCar, stop) in
            let car = rightCar as! SKSpriteNode
            car.position.y -= self.gameConfig.getCarSpeed()
        })
        
        
        
    }
    
    func setUp()  {
        car = self.childNode(withName: "car") as! SKSpriteNode
        
        car.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        car.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        car.physicsBody?.collisionBitMask = 0
        
        let scoreBackGround = SKShapeNode(rect: CGRect(x: -self.size.width/2 + 70 ,y:self.size.height/2 - 130, width: 180, height:80 ), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint ( x: -self.size.width/2 + 160, y: self.size.height/2 - 110)
        scoreText.fontSize = 50
        scoreText.zPosition = 4
        addChild(scoreText)
    }
    
    @objc func removeItems () {
        for child in children {
            if child.position.y < -self.size.height - 100{
                child.removeFromParent()
            }
        }
    }
    
    @objc func creatRoadStrip()   {
        
        let  leftRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        leftRoadStrip.strokeColor = SKColor.white
        leftRoadStrip.fillColor = SKColor.white
        leftRoadStrip.alpha = 0.4
        leftRoadStrip.name = "leftRoadStrip"
        leftRoadStrip.zPosition = 10
        leftRoadStrip.position.x = -187.5
        leftRoadStrip.position.y = 700
        addChild(leftRoadStrip)
        
        let  centerRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        centerRoadStrip.strokeColor = SKColor.white
        centerRoadStrip.fillColor = SKColor.white
        centerRoadStrip.alpha = 0.4
        centerRoadStrip.name = "centerRoadStrip"
        centerRoadStrip.zPosition = 10
        centerRoadStrip.position.x = 0
        centerRoadStrip.position.y = 700
        addChild(centerRoadStrip)
        
        let  rightRoadStrip = SKShapeNode(rectOf: CGSize(width: 10, height: 40))
        rightRoadStrip.strokeColor = SKColor.white
        rightRoadStrip.fillColor = SKColor.white
        rightRoadStrip.alpha = 0.4
        rightRoadStrip.name = "rightRoadStrip"
        rightRoadStrip.zPosition = 10
        rightRoadStrip.position.x = 187.5
        rightRoadStrip.position.y = 700
        addChild(rightRoadStrip)
        
        
    }
    
    @objc func traffic() {
        if !stopEverything {
            
            let leftTrafficItem  : SKSpriteNode
            let randomNumber = Helper().randomBtweenTowNumbers(firsNumber: 0, secondNumber: 8)
            switch Int(randomNumber) {
            case 0...3:
                leftTrafficItem = SKSpriteNode(imageNamed: "orangeCar")
                leftTrafficItem.name = "orangeCar"
                break
            case 4...8:
                leftTrafficItem = SKSpriteNode(imageNamed: "greenCar")
                leftTrafficItem.name = "greenCar"
                break
            default:
                leftTrafficItem = SKSpriteNode(imageNamed: "orangeCar")
                leftTrafficItem.name = "orangeCar"
                
            }
            leftTrafficItem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            leftTrafficItem.size = CGSize(width: 80, height: 182)
            leftTrafficItem.zPosition = 10
            let randomNum = Helper().randomBtweenTowNumbers(firsNumber: 0, secondNumber: 20)
            switch Int(randomNum) {
            case 0...4:
                leftTrafficItem.position.x = -280
                break
            case 5...9:
                leftTrafficItem.position.x = -100
                break
            case 10...14:
                leftTrafficItem.position.x = 100
                break
            case 15...20:
                leftTrafficItem.position.x = 280
                break
            default:
                leftTrafficItem.position.x = -280
            }
            leftTrafficItem.position.y = 700
            leftTrafficItem.physicsBody = SKPhysicsBody(circleOfRadius: leftTrafficItem.size.height/2)
            leftTrafficItem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
            leftTrafficItem.physicsBody?.collisionBitMask = 0
            leftTrafficItem.physicsBody?.affectedByGravity = false
            addChild(leftTrafficItem)
            
            randomMove(car: leftTrafficItem)
            
        }
    }
    
    func randomMove(car: SKSpriteNode) {
        var time = frame.height / (gameConfig.getCarSpeed() * 20)
        time = Helper().randomBtweenTowNumbers(firsNumber: 0.2, secondNumber: time)
        
        var random: Int = -1
        if gameConfig.gameLevel == .Diff {
            random = Int(Helper().randomBtweenTowNumbers(firsNumber: 0, secondNumber: 10))
        }else if gameConfig.gameLevel == .Hall {
            random = Int(Helper().randomBtweenTowNumbers(firsNumber: 0, secondNumber: 5))
        }
        
        if random != 0 {
            return
        }
        
        var moveX: CGFloat?
        switch car.position.x {
        case -280:
            moveX = -100
            break
        case -100:
            let number = Helper().randomBtweenTowNumbers(firsNumber: 0, secondNumber: 2)
            if Int(number) == 0 {
                moveX = -280
            }else {
                moveX = 100
            }
            break
        case 100:
            let number = Helper().randomBtweenTowNumbers(firsNumber: 0, secondNumber: 2)
            if Int(number) == 0 {
                moveX = 280
            }else {
                moveX = -100
            }
            break
        case 280:
            moveX = 100
            break
        default:
            break
        }
        
        guard moveX != nil else {
            return
        }
        
        let action = SKAction.moveTo(x: moveX!, duration: 0.3)
        car.run(action)
    }
    
    @objc func startCountDown() {
        if countDown > -1 {
            if countDown < 3 {
                let str = countlist[countDown]
                let  CounttDownLabel = SKSpriteNode(imageNamed: str)
                //                CounttDownLabel.fontName = "AvenirNext-Bold"
                //                CounttDownLabel.fontColor = SKColor.white
                //                CounttDownLabel.fontSize = 300
                //                CounttDownLabel.text = String(countDown)
                CounttDownLabel.position = CGPoint(x: 0, y: 0)
                CounttDownLabel.zPosition = 300
                //                CounttDownLabel.horizontalAlignmentMode = .center
                addChild(CounttDownLabel)
                
                let deadtime = DispatchTime.now()+0.5
                DispatchQueue.main.asyncAfter(deadline: deadtime, execute: {
                    CounttDownLabel.removeFromParent()
                })
            }
            countDown+=1
            if countDown == 3{
                
                self.stopEverything=false
            }
        }
        
    }
    
    @objc func increaseScore() {
        
        if !stopEverything {
            if isGameOver {
                return
            }
            score += 1
            scoreText.text = String(score)
        }
    }
}
