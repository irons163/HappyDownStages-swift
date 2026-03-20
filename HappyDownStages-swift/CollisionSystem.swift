//
//  CollisionSystem.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import SpriteKit

final class CollisionSystem {

    private weak var scene: MyScene?

    init(scene: MyScene) {
        self.scene = scene
    }

    func updateAndCheckFootboards(_ isInjure: inout Bool, _ playerContactY: inout CGFloat?) {
        guard let scene = scene else { return }
        var destoryedFootboard: Footboard?
        var destoryedFootboardIndex: Int?
        var linesToRemove: IndexSet = []

        for (lineIndex, line) in scene.footboards.enumerated() {
            var boardsToRemoveInLine: IndexSet = []

            for (boardIndex, board) in line.enumerated() {
                // --- Move board up ---
                board.drawDy(scene.speed) // Assuming drawDy updates position

                // --- Check if off-screen ---
                if board.position.y > scene.sceneHeight + scene.footboardHeight { // Well above the screen
                    boardsToRemoveInLine.insert(boardIndex)
                    continue // No need for collision checks
                }

                // --- Add/Update Tool Node ---
                updateToolForBoard(board)

                // --- Player Collision Check ---
                guard let player = scene.player else { continue }

                // Check for landing collision (player's bottom edge vs board's top edge)
                let playerBottomY = player.position.y - player.size.height * player.anchorPoint.y
                let playerTopY = player.position.y + player.size.height * (1.0 - player.anchorPoint.y)
                _ = playerTopY
                let playerLeftX = player.position.x - player.size.width * player.anchorPoint.x + MyScene.smoothDeviation * 2 // Adjusted collision box
                let playerRightX = player.position.x + player.size.width * (1.0 - player.anchorPoint.x) - MyScene.smoothDeviation * 2 // Adjusted collision box

                let boardTopY = board.position.y // Since anchor is (0,1)
                let boardBottomY = board.position.y - board.size.height
                _ = boardBottomY
                let boardLeftX = board.position.x
                let boardRightX = board.position.x + board.size.width

                // Conditions for potential landing:
                // 1. Player is horizontally overlapping the board.
                // 2. Player *was* above the board in the previous frame(s).
                // 3. Player's bottom is now at or just below the board's top.
                let horizontalOverlap = playerRightX > boardLeftX && playerLeftX < boardRightX
                // Check vertical position relative to board top, allowing for slight penetration due to falling speed
                let verticalLanding = playerBottomY <= boardTopY && playerBottomY > boardTopY - (scene.state.downSpeed + scene.speed + 5) // Allow tolerance

                if horizontalOverlap && verticalLanding && !scene.state.playerStandOnFootboard { // Only land once per frame check
                    print("Landing on board!")
                    scene.state.playerStandOnFootboard = true
                    playerContactY = boardTopY // The Y position player should be moved to

                    if scene.state.playerDownOnFootBoard {
                        // Handle board types (conveyor, spikes)
                        handleBoardLandingEffect(board, &isInjure)

                        // Handle tool collision *on landing*
                        handleToolCollision(board, &isInjure)

                        scene.state.playerDownOnFootBoard = false // Reset flag indicating falling state
                    }

                    // Increment score/counter if needed
                    board.setCount() // Assuming this tracks landings or score
                    if board.getBitmap() == nil {
                        destoryedFootboard = board
                        destoryedFootboardIndex = boardIndex
                    }
                }

                // --- Tool Collision Check (General Overlap, not just landing) ---
                // This might be redundant if handled on landing, or needed if tools activate without landing (e.g., proximity mine)
                if let tool = board.tool, board.toolNum != Footboard.BOMB_EXPLODE { // Don't check collision with explosion itself here
                    let toolFrame = tool.calculateAccumulatedFrame() // Get tool's frame in scene coordinates
                    let playerFrame = player.calculateAccumulatedFrame()

                    if playerFrame.intersects(toolFrame) {
                        // Handle collision even if not landing (e.g., running past a tree)
                        // Re-evaluate if handleToolCollision on landing is sufficient
                        // handleToolCollision(board, &isInjure) // Careful not to double-trigger
                    }
                }
            } // End loop through boards in line

            if let footboard = destoryedFootboard, let footboardIndex = destoryedFootboardIndex {
                footboard.tool?.removeFromParent()
                footboard.removeFromParent()
                scene.footboards[lineIndex].remove(at: footboardIndex)
                destoryedFootboard = nil
                destoryedFootboardIndex = nil
            }

            // Remove boards marked for removal from this line
            // Iterate backwards to avoid index issues
            for index in boardsToRemoveInLine.reversed() {
                let boardToRemove = line[index]
                boardToRemove.tool?.removeFromParent() // Remove associated tool node
                boardToRemove.removeFromParent()
                // scene.footboards[lineIndex].remove(at: index) // Modify copy, not original during iteration
            }
            // Update the original array outside the inner loop if modifying a mutable copy isn't feasible
            // Or reconstruct the line: scene.footboards[lineIndex] = line.enumerated().filter { !boardsToRemoveInLine.contains($0.offset) }.map { $0.element }

            if line.isEmpty || boardsToRemoveInLine.count == line.count {
                linesToRemove.insert(lineIndex) // Mark the whole line for removal if empty
            }
        } // End loop through lines

        // Remove lines marked for removal from the main footboards array
        // Iterate backwards
        for index in linesToRemove.reversed() {
            // Ensure associated nodes are removed if not already handled
            scene.footboards[index].forEach {
                $0.tool?.removeFromParent()
                $0.removeFromParent()
            }
            scene.footboards.remove(at: index)
        }
    }

    func updateTools(timeSinceLast: TimeInterval) {
        guard let scene = scene else { return }

        // Update the static exploding tool, if active
        if let explosion = MyScene.toolExplodingUtil {
            explosion.draw(dy: 0) // Pass speed 0? Or deltaTime? Assume ToolUtil handles its animation timing.
            if !explosion.isExploding { // Check if animation finished
                explosion.removeFromParent()
                MyScene.toolExplodingUtil = nil // Clear the static reference
            }
        }

        // Update other active tools if necessary (e.g., tree eating animation)
        for line in scene.footboards {
            for board in line {
                if let _ = board.tool {
                    // If the tool needs per-frame updates independent of board movement
                    // tool.update(deltaTime: timeSinceLast) // Example
                    if board.toolNum == Footboard.EAT_MAN_TREE {
                        // If tree needs state check even when player isn't touching
                    }
                }
            }
        }
    }

    func updateAndCheckFireballs(_ isInjure: inout Bool) {
        guard let scene = scene else { return }
        guard let player = scene.player else { return }
        var fireballsToRemove: IndexSet = []

        for (index, ball) in scene.fireballs.enumerated() {
            // Move fireball down (or up based on game logic)
            ball.moveDy(-(scene.speed * 2), dx: 0) // Move faster than background? Adjust as needed

            // Check if off-screen
            if ball.position.y < -ball.size.height {
                fireballsToRemove.insert(index)
                continue
            }

            // Collision Check with Player
            let ballFrame = ball.calculateAccumulatedFrame()
            let playerFrame = player.calculateAccumulatedFrame()

            if playerFrame.intersects(ballFrame) {
                isInjure = true
                scene.state.life = 0 // Fireball is instant kill
                fireballsToRemove.insert(index) // Remove the fireball
                scene.applyDamageFlash()
                // No need to continue checking other fireballs if player is dead
                // Break or return? Handle game end logic promptly.
            }
        }

        // Remove fireballs marked for removal
        for index in fireballsToRemove.reversed() {
            scene.fireballs[index].removeFromParent()
            scene.fireballs.remove(at: index)
        }
    }

    private func updateToolForBoard(_ board: Footboard) {
        guard let scene = scene else { return }
        guard board.tool == nil && board.toolNum != Footboard.NOTOOL else {
            // Tool already exists or no tool assigned
            if let tool = board.tool {
                // Optional: Update tool position relative to board if needed
                // tool.position = CGPoint(x: board.position.x + board.size.width / 2 - tool.size.width * tool.anchorPoint.x,
                //                         y: board.position.y - tool.size.height * tool.anchorPoint.y)
                // Update tool animation/state if needed by the tool itself
                tool.draw(dy: scene.speed) // Or tool.update(deltaTime)
            }
            return
        }

        // Create and add tool node if it doesn't exist yet
        let toolUtil: ToolUtil?

        // Center the tool horizontally on the board, place it on top
        let toolX = board.position.x + board.size.width / 2
        let toolY = board.position.y // Y position at the top edge of the board (due to board anchor 0,1)

        switch board.toolNum {
        case Footboard.BOMB:
            toolUtil = ToolUtil(texture: nil) // Assuming init
            toolUtil?.setToolUtil(x: toolX, y: toolY, type: Footboard.BOMB)
        case Footboard.EAT_MAN_TREE:
            toolUtil = ToolUtil(texture: nil)
            toolUtil?.setToolUtil(x: toolX, y: toolY, type: Footboard.EAT_MAN_TREE)
        case Footboard.CURE:
            toolUtil = ToolUtil(texture: nil)
            toolUtil?.setToolUtil(x: toolX, y: toolY, type: Footboard.CURE)
        default:
            toolUtil = nil // No tool or unknown type
        }

        if let toolUtil = toolUtil {
            board.tool = toolUtil // Assign to the board
            toolUtil.zPosition = board.zPosition + 1 // Ensure tool is visually on top of board
            scene.addChild(toolUtil) // Add tool node to the scene
        }
    }

    private func handleBoardLandingEffect(_ board: Footboard, _ isInjure: inout Bool) {
        guard let scene = scene else { return }
        scene.state.playerWalkSpeed = 0 // Reset speed effect unless overridden

        switch board.which {
        case 1: // Left Conveyor
            scene.state.whichFootboard = 1
            scene.state.playerWalkSpeed = scene.commonUtil.SLIDERSPEED // Move player left (assuming negative dx in updatePlayer)
            // moveDirection = MyScene.left // Or just apply speed?
        case 2: // Right Conveyor
            scene.state.whichFootboard = 2
            scene.state.playerWalkSpeed = -scene.commonUtil.SLIDERSPEED // Move player right (assuming positive dx in updatePlayer)
            // moveDirection = MyScene.right
        case 5: // Spikes
            scene.state.whichFootboard = 5 // Or just apply damage immediately?
            isInjure = true
            scene.state.life -= 30
            scene.applyDamageFlash()
        default: // Normal board
            scene.state.whichFootboard = 0
            // No effect
        }
    }

    private func handleToolCollision(_ board: Footboard, _ isInjure: inout Bool) {
        guard let scene = scene else { return }
        guard let tool = board.tool, board.toolNum != Footboard.BOMB_EXPLODE else { return }

        // Check collision based on player frame and tool frame
        guard let player = scene.player else { return }
        let toolFrame = tool.calculateAccumulatedFrame()
        let playerFrame = player.calculateAccumulatedFrame()

        // Use intersects for frame collision detection
        if playerFrame.intersects(toolFrame) {
            switch board.toolNum {
            case Footboard.BOMB:
                isInjure = true
                scene.state.life -= 60
                scene.applyDamageFlash()
                // Trigger explosion visual
                createExplosion(at: tool.position) // Use tool's position
                // Remove bomb tool, mark board as having no tool now
                tool.removeFromParent()
                board.tool = nil
                board.toolNum = Footboard.NOTOOL // Prevent re-triggering

            case Footboard.CURE:
                scene.state.life = MyScene.config.maxLife // Full heal
                // Remove cure tool
                tool.removeFromParent()
                board.tool = nil
                board.toolNum = Footboard.NOTOOL

            case Footboard.EAT_MAN_TREE:
                tool.doEat() // Tell the tree tool to start eating animation
                if tool.isEated() { // Check if the eating animation completed this frame
                    isInjure = true
                    scene.state.life -= 30
                    scene.applyDamageFlash()
                }

            default:
                break // No action for other tool types on collision
            }
        }
    }

    private func createExplosion(at position: CGPoint) {
        guard let scene = scene else { return }
        guard MyScene.toolExplodingUtil == nil else { return } // Only one explosion at a time?

        MyScene.toolExplodingUtil = ToolUtil(texture: nil) // Assuming ToolUtil handles explosion animation
        MyScene.toolExplodingUtil?.setToolUtil(x: position.x, y: position.y, type: Footboard.BOMB_EXPLODE) // Center explosion?
        MyScene.toolExplodingUtil?.zPosition = 10 // Ensure explosion is visible
        if let explosion = MyScene.toolExplodingUtil {
            scene.addChild(explosion)
            // ToolUtil should handle its own animation and removal, or updateTools needs to manage it
        }
    }
}
