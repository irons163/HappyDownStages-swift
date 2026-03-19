//
//  MyScene+Timers.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import Foundation

extension MyScene {

    // MARK: - Game State & Timers

    func initReadyTimer() {
        state.readyStep = 0
        readyTimer?.invalidate() // Invalidate existing timer if any
        readyTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(countReadyTimer),
                                          userInfo: nil,
                                          repeats: true)
        if let readyTimer = readyTimer {
            activeTimers.append(readyTimer)
            // Ensure timer runs even while scrolling UI (if applicable)
            // RunLoop.current.add(readyTimer, forMode: .common)
        }
    }

    @objc private func countReadyTimer() {
        guard let readyLabel = readyLabel else {
            readyTimer?.invalidate()
            return
        }

        if state.readyStep == 0 {
            readyLabel.text = "READY"
            // Recenter label if needed (text length changes)
            readyLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            readyLabel.isHidden = false
        } else if state.readyStep < 4 { // Counts 3, 2, 1
            readyLabel.text = "\(4 - state.readyStep)"
            readyLabel.position = CGPoint(x: frame.midX, y: frame.midY) // Recenter
        } else if state.readyStep == 4 {
            readyLabel.text = "GO!" // Optional "GO!" message
            readyLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        } else { // state.readyStep >= 5
            readyLabel.isHidden = true
            readyTimer?.invalidate()
            state.readyFlag = false // Ready sequence finished, start the game
            return
        }
        state.readyStep += 1
    }

    func initGameTimer() {
        state.gameTimerCount = 0 // Reset count
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                         target: self,
                                         selector: #selector(countGameTime),
                                         userInfo: nil,
                                         repeats: true)
        if let gameTimer = gameTimer {
            activeTimers.append(gameTimer)
            // RunLoop.current.add(gameTimer, forMode: .common)
        }
    }

    @objc private func countGameTime() {
        // Guard against timer firing when game shouldn't be running
        guard MyScene.gameFlag && !state.readyFlag else {
            // Consider invalidating timer here if game ended unexpectedly
            return
        }

        state.gameTimerCount += 1

        // Update timer display moved to main update loop (setTimeTextures)
        // if !gameSuccess {
        //     setTimeTextures()
        // }

        // Win condition check moved to main update loop
        // if level < MyScene.infinityLevel && gameTimerCount >= MyScene.gameTime {
        //     gameSuccess = true
        //     handleGameEnd()
        // }
    }
}
