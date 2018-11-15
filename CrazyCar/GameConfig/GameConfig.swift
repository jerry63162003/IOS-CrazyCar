//
//  GameConfig.swift
//  CarsGame
//
//  Created by roy on 2018/7/3.
//  Copyright © 2018年 Nitay&Raz. All rights reserved.
//

import UIKit

enum GameLevel: String {
    case Easy = "easy"
    case Diff = "diff"
    case Hall = "hall"
}

let screenWidth = UIApplication.shared.keyWindow?.frame.width ?? 0

let screenHeigh = UIApplication.shared.keyWindow?.frame.height ?? 0

class GameConfig: NSObject {
    static let shared = GameConfig()
    let myCarSpeed: CGFloat = 20
    
    var gameLevel: GameLevel = (UserDefaults.standard.string(forKey: "gameLevel") != nil) ? GameLevel(rawValue: UserDefaults.standard.string(forKey: "gameLevel")!)! : GameLevel.Easy {
        didSet {
            UserDefaults.standard.set(gameLevel.rawValue, forKey: "gameLevel")
            UserDefaults.standard.synchronize()
        }
    }
    
    var isGameMusic = UserDefaults.standard.object(forKey: "isGameMusic") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isGameMusic, forKey: "isGameMusic")
            UserDefaults.standard.synchronize()
        }
    }
    var isGameSound = UserDefaults.standard.object(forKey: "isGameSound") as? Bool ?? true {
        didSet {
            UserDefaults.standard.set(isGameSound, forKey: "isGameSound")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var isGameBegin: Bool = false
    private var timer: Timer?
    private var timeInterval: Int = 0
    
    func getCarSpeed() -> CGFloat {
        
        var speed: CGFloat = 0
        var multiple = 0
        switch self.gameLevel {
        case .Easy:
            speed = 15
            multiple = timeInterval / 80
            break
        case .Diff:
            speed = 20
            multiple = timeInterval / 60
            break
        case .Hall:
            speed = 25
            multiple = timeInterval / 40
            break
        }
        
        let addSpeed = CGFloat(multiple * 10)
        speed += addSpeed
        
        return speed
    }
    
    func beginGame() {
        isGameBegin = true
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(GameConfig.countDown), userInfo: nil, repeats: true)
    }
    
    @objc func countDown() {
        timeInterval += 1
    }
    
    func endGame() {
        timeInterval = 0
        timer?.invalidate()
        isGameBegin = false
    }
    
}
