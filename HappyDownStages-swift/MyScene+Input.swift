//
//  MyScene+Input.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import SpriteKit

extension MyScene {

    // MARK: - Event Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = self.view else { return } // Need view for coordinate conversion if using view coordinates

        // Ad View Touch Handling (Pass touches, let the ad view check)
        myAdView?.touchesBegan(touches, with: event)

        for touch in touches {
            let location = touch.location(in: self) // Location in scene coordinates

            if let leftKey = leftKeyNode, leftKey.contains(location) {
                state.isPressLeftMoveBtn = true
                state.moveDirection = MyScene.left
                player?.updateBitmap(type: MyScene.left) // Tell player to use left-facing animation
            } else if let rightKey = rightKeyNode, rightKey.contains(location) {
                state.isPressRightMoveBtn = true
                state.moveDirection = MyScene.right
                player?.updateBitmap(type: MyScene.right) // Tell player to use right-facing animation
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Optional: Handle dragging off buttons if needed
        for touch in touches {
            let location = touch.location(in: self)
            _ = location
            // Check if touch moved outside the button it started on
            // Update isPress flags and moveDirection accordingly
        }
        myAdView?.touchesMoved(touches, with: event) // Pass to ad view
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        var leftReleased = false
        var rightReleased = false

        for touch in touches {
            let location = touch.location(in: self)

            // Check if the touch ending corresponds to one of the buttons
            if let leftKey = leftKeyNode, leftKey.contains(location) {
                leftReleased = true
            } else if let rightKey = rightKeyNode, rightKey.contains(location) {
                rightReleased = true
            }
            // Consider case where touch *started* on button but ends elsewhere
            // This simple check assumes touch ends *on* the button area
        }

        if leftReleased {
            state.isPressLeftMoveBtn = false
        }
        if rightReleased {
            state.isPressRightMoveBtn = false
        }

        // Determine new move state based on which buttons are *still* pressed
        if state.isPressLeftMoveBtn {
            state.moveDirection = MyScene.left
            player?.updateBitmap(type: MyScene.left) // Ensure correct animation
        } else if state.isPressRightMoveBtn {
            state.moveDirection = MyScene.right
            player?.updateBitmap(type: MyScene.right) // Ensure correct animation
        } else {
            state.moveDirection = MyScene.stay
            state.isMoving = false // Reset moving flag if used for animation triggers
            // Tell player to return to idle animation for the last direction faced
            player?.updateBitmap(type: MyScene.stay) // Or pass last direction to idle correctly
            // player?.removeAllActions() // Stop movement animations if managed here (better in Player class)
        }

        // Ad View
        myAdView?.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Treat cancelled like ended for button release logic
        touchesEnded(touches, with: event)
        myAdView?.touchesCancelled(touches, with: event)
    }
}
