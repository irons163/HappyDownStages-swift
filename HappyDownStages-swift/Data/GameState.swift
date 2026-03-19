//
//  GameState.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import Foundation
import CoreGraphics

struct GameState {
    // Timing
    var lastSpawnTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    var lastSpawnCreateFootboardTimeInterval: TimeInterval = 0

    // Game State & Scores
    var playerDownOnFootBoard = false
    var playerStandOnFootboard = false
    var readyFlag = true
    var readyStep = 0
    var gameSuccess = false
    var moveDirection = 0
    var isPressLeftMoveBtn = false
    var isPressRightMoveBtn = false
    var scoreMultiple = 100
    var isGameFinish = false
    var isMoving = false
    var gameTimerCount = 0
    var drawCount = 0
    var life = 90

    // Physics & Movement Speeds
    var baseSpeed: CGFloat = 0.0
    var playerWalkSpeed: CGFloat = 0.0
    var downSpeed: CGFloat = 0.0
    var moveSpeed: CGFloat = 0.0

    // Player Landing Helper
    var whichFootboard = 0
}
