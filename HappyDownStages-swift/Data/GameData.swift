//
//  GameData.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import Foundation

enum Sex: Int {
    case girl = 0
    case boy = 1
}

struct GameData {
    // 玩家性別（預設為女生）
    static var playerSex: Sex = .girl

    // 可擴充：目前關卡、分數、音效設定等
    static var currentLevel: Int = 0
    static var highScore: Int = 0
    static var soundEnabled: Bool = true
}
