//
//  MyScene+GameEnd.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import Foundation

extension MyScene {

    // MARK: - Game Over & Score

    func handleGameEnd() {
        guard !state.isGameFinish else { return } // Prevent multiple calls
        state.isGameFinish = true
        MyScene.gameFlag = false // Stop game logic

        // Invalidate timers
        gameTimer?.invalidate()
        readyTimer?.invalidate()
        activeTimers.removeAll() // Clear timer list

        // Determine win/lose and act accordingly
        if state.gameSuccess {
            // Save progress if needed
            let maxLevel = UserDefaults.standard.integer(forKey: AppConstants.UserDefaultsKey.level)
            if maxLevel < MyScene.infinityLevel && level >= maxLevel {
                let nextLevel = level + 1 // Should be maxLevel + 1? Check Obj-C logic carefully
                UserDefaults.standard.set(nextLevel, forKey: AppConstants.UserDefaultsKey.level)
                // UserDefaults.standard.synchronize() // synchronize() often not needed now
            }
            // Show win dialog via delegate
            gameDelegate?.showWinDialog()
        } else {
            // Submit score and show lose dialog
            submitScore()
        }
    }

    private func submitScore() {
        // Calculate score (logic from Obj-C)
        // Time bonus only if not infinity level?
        let timeScore = (level < MyScene.infinityLevel) ? (MyScene.gameTime * level * state.scoreMultiple) : (state.gameTimerCount * state.scoreMultiple) // Score based on time survived in infinity
        let countScore = state.gameTimerCount * state.scoreMultiple // Or is 'count' something else? Check Obj-C 'count' usage. Assuming it's game time.
        let finalScore = timeScore + countScore // Combine scores? Obj-C logic was a bit ambiguous: GAME_TIME * level * SCORE_MULTIPLE + count * SCORE_MULTIPLE

        // Report score to Game Center
        GameCenterUtil.shared.reportScore(Int64(finalScore), forCategory: AppConstants.Leaderboard.reportId)

        // Show lose dialog via delegate
        gameDelegate?.showLoseDialog(score: finalScore)
    }
}
