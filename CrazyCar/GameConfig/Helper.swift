//
//  Helper.swift
//  CarsGame
//
//  Created by Yaniv Mashat on 9.1.2018.
//  Copyright © 2018 Nitay&Raz. All rights reserved.
//

import Foundation
import UIKit

struct ColliderType {
    static let CAR_COLLIDER : UInt32 = 0
    static let ITEM_COLLIDER : UInt32 = 1
    static let ITEM_COLLIDER_1 : UInt32 = 1
}
class Helper : NSObject {
    
    func randomBtweenTowNumbers(firsNumber : CGFloat, secondNumber : CGFloat ) -> CGFloat {
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firsNumber - secondNumber) + min(firsNumber, secondNumber)
    }
    
    
    
}

class Settings {
    static let sharedInstance = Settings()
    
    private init(){
    }
    
    private var _highScore: Int = 0
    var highScore: Int {
        get {
            let level = GameConfig.shared.gameLevel
            var gameLevelStr = "Sorce"
            gameLevelStr += "_\(level.rawValue)"
            
            return UserDefaults.standard.integer(forKey: gameLevelStr)
        }
        
        set {
            _highScore = newValue
            let level = GameConfig.shared.gameLevel
            var gameLevelStr = "Sorce"
            gameLevelStr += "_\(level.rawValue)"
            
            UserDefaults.standard.set(newValue, forKey: gameLevelStr)
            UserDefaults.standard.synchronize()
        }
    }
}
