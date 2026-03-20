//
//  MyScene+Utilities.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import Foundation
import SpriteKit

extension MyScene {

    // MARK: - Utilities

    func getRandomBgResId() -> String {
        guard !randomBackgroundIDs.isEmpty else { return "new_bg1" } // Default fallback
        let index = Int.random(in: 0..<randomBackgroundIDs.count)
        return randomBackgroundIDs[index]
    }

    func setAdClickable(_ clickable: Bool) {
        myAdView?.adClickable = clickable
    }

    func dequeueFootboard() -> Footboard {
        if let board = footboardPool.popLast() {
            return board
        }
        return Footboard(texture: nil)
    }

    func recycleFootboard(_ board: Footboard) {
        board.tool?.removeFromParent()
        board.tool = nil
        board.toolNum = Footboard.NOTOOL
        board.removeAllActions()
        board.removeFromParent()
        footboardPool.append(board)
    }
}
