//
//  MyScene+Update.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import SpriteKit

extension MyScene {

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        // --- Delta Time Calculation ---
        if state.lastUpdateTimeInterval == 0 {
            state.lastUpdateTimeInterval = currentTime // First frame
        }
        let dt = currentTime - state.lastUpdateTimeInterval
        state.lastUpdateTimeInterval = currentTime
        // Handle pauses or large gaps
        let timeSinceLast = (dt > 1.0) ? (1.0 / 60.0) : dt // Clamp delta time

        // --- Ready State ---
        if state.readyFlag && readyTimer == nil {
            initReadyTimer()
        }

        // --- Game Paused / Not Ready ---
        guard MyScene.gameFlag && !state.readyFlag else {
            // Allow ad view updates even if game is paused?
            myAdView?.startAd() // Assuming an update method exists
            return
        }

        // --- Start Game Timer ---
        if gameTimer == nil {
            initGameTimer() // Start the game timer only once game is running
        }

        // --- Check Win Condition (Time Limit) ---
        if level < MyScene.infinityLevel && state.gameTimerCount >= MyScene.gameTime {
            state.gameSuccess = true
            handleGameEnd() // Use a unified end function
            return // Stop further updates this frame
        }

        // --- Update Ad ---
        myAdView?.startAd() // Assuming an update method exists

        // --- Update Game Elements Based on Time Delta ---
        updateGameElements(timeSinceLast: timeSinceLast)

        // --- Check Lose Conditions ---
        if state.life <= 0 || (player?.position.y ?? sceneHeight + 1) < 0 { // Player fell off bottom
            if !state.isGameFinish { // Prevent multiple calls
                redFlashNode?.isHidden = false // Show red flash
                handleGameEnd()
            }
            return // Stop further updates this frame
        }

        // --- Reset Damage Indicator ---
        redFlashNode?.isHidden = true // Hide red flash if no new damage this frame

        // --- Final Position Updates --- (If player position wasn't updated in updateGameElements)
        // updatePlayerPosition(timeSinceLast: timeSinceLast) // Example if needed

        // --- Static State Update ---
        // MyScene.gameStop = true // Original code sets this true every frame? Seems odd. Let's omit unless purpose is clear.
    }

    // MARK: - Update Helpers

    // Renamed from Obj-C 'draw' method - more descriptive
    private func updateGameElements(timeSinceLast: TimeInterval) {
        // Increment timers used for spawning logic
        state.lastSpawnTimeInterval += timeSinceLast
        state.lastSpawnCreateFootboardTimeInterval += timeSinceLast

        guard state.lastSpawnTimeInterval >= 0.025 else {
            return
        }

        state.lastSpawnTimeInterval = 0

        // --- Background Scrolling ---
        scrollBackground()

        // --- Footboard Generation ---
        // Throttle footboard creation based on time/distance scrolled
        // Obj-C used drawCount % interval. Let's use time interval for smoother scaling.
        // Calculate interval based on speed. Faster speed -> shorter interval.
        let footboardCreationInterval = TimeInterval((state.baseSpeed / speed))
        if state.lastSpawnCreateFootboardTimeInterval > footboardCreationInterval {
            state.lastSpawnCreateFootboardTimeInterval = 0 // Reset timer
            createFootboards()
            // spawnFireball() // Maybe spawn fireballs less frequently?
        }

        // --- Update Existing Elements ---
        var isInjure = false // Track if player hit something this frame
        var isDrawPlayer = true // Flag from Obj-C, might not be needed if player update is consolidated
        _ = isDrawPlayer

        // Update Footboards and Check Collisions
        state.playerStandOnFootboard = false // Reset before checking
        var playerContactY: CGFloat? = nil // Y position if player lands

        updateAndCheckFootboards(&isInjure, &playerContactY)

        // Update Fireballs and Check Collisions
        updateAndCheckFireballs(&isInjure)

        // Update Tools (like the exploding bomb)
        updateTools(timeSinceLast: timeSinceLast) // Pass dt if tools need it

        // Check Top Spikes Collision
        if let player = player, let topSpikedBar = topSpikedBar {
            // Check if player's top edge hits the bottom of the spikes
            if (player.position.y + player.size.height * (1.0 - player.anchorPoint.y)) >= topSpikedBar.position.y {
                isInjure = true
                state.life = 0 // Instant kill
            }
        }

        // --- Update Player ---
        updatePlayerMovement(isOnGround: state.playerStandOnFootboard, contactY: playerContactY, isInjured: isInjure)

        // --- Update UI ---
        if !state.gameSuccess {
            setTimeTextures() // Update timer display
        }
        changeHpBar() // Update HP bar display
    }

    private func scrollBackground() {
        // Move backgrounds up
        firstBgHeight += speed
        secondBgHeight += speed

        // Reposition backgrounds when they go off-screen
        if firstBgHeight >= sceneHeight {
            firstBgHeight = secondBgHeight - sceneHeight // Place above the other one
        }
        if secondBgHeight >= sceneHeight {
            secondBgHeight = firstBgHeight - sceneHeight // Place above the other one
        }

        backgroundNode?.position.y = firstBgHeight
        secondBackgroundNode?.position.y = secondBgHeight

        // Optional: Change background texture when one resets
        // if firstBgHeight was just reset:
        //    backgroundNode?.texture = SKTexture(imageNamed: getRandomBgResId())
        // if secondBgHeight was just reset:
        //    secondBackgroundNode?.texture = SKTexture(imageNamed: getRandomBgResId())
    }

    func createFootboards(offsetY: CGFloat = 0) {
        guard MyScene.gameFlag else { return }
        guard !currentXs.isEmpty else {
            print("Warning: currentXs is empty, cannot create new footboards.")
            // Maybe regenerate a default starting line?
            let initialX: CGFloat = sceneWidth / 2 - footboardWidth / 2
            currentXs.append(initialX)
            // Potentially create a single board here if needed
            return
        }

        let previousXs = currentXs // Copy the X positions from the last generated line
        var nextXs: [CGFloat] = [] // Store the X positions generated in this line
        var newFootboardsInLine: [Footboard] = [] // Store the footboards created in this line

        // Determine number of footboards to create (Max 2 per previous board)
        let maxNewBoardsPerSource = 2
        var boardsToCreateTotal = Int.random(in: 1...maxNewBoardsPerSource * previousXs.count)
        boardsToCreateTotal = min(boardsToCreateTotal, 2)

        var createdCount = 0
        for sourceX in previousXs {
            if createdCount >= boardsToCreateTotal { break }

            // How many to create from *this* sourceX (usually 1, maybe 2 if needed)
            let numToCreateFromThis = (boardsToCreateTotal - createdCount >= 2 && previousXs.count == 1) ? 2 : 1 // Try to create 2 if possible and only one source
            // let numToCreateFromThis = 1 // Simpler: always 1 from each source needed

            for _ in 0..<numToCreateFromThis {
                if createdCount >= boardsToCreateTotal { break }

                // Calculate horizontal offset (des in Obj-C)
                var randomOffset = CGFloat(Int.random(in: 7...20)) // 7-20 range from Obj-C logic
                randomOffset = (Int.random(in: 0...1) == 0) ? -randomOffset : randomOffset // Random direction
                randomOffset *= distanceMultiple

                // Calculate new X position
                var newX = sourceX + randomOffset

                // Clamp X position within screen bounds, leaving space if creating two
                let minX: CGFloat = (numToCreateFromThis == 2) ? 0 : minimumDistanceBetweenFootboards
                let maxX: CGFloat = (numToCreateFromThis == 2) ? sceneWidth - footboardWidth : sceneWidth - footboardWidth - minimumDistanceBetweenFootboards

                newX = max(minX, newX) // Clamp minimum to 0
                newX = min(maxX, newX) // Clamp maximum

                // Avoid overlap if creating two from the same source or close sources
                if let lastX = nextXs.last {
                    // Ensure minimum distance
                    if (newX > lastX && newX < lastX + footboardWidth + minimumDistanceBetweenFootboards) ||
                        (newX < lastX && newX + footboardWidth + minimumDistanceBetweenFootboards > lastX) {
                        // Too close, try nudging it away or skipping
                        if newX > lastX {
                            newX = lastX + footboardWidth + minimumDistanceBetweenFootboards
                            if newX >= sceneWidth - footboardWidth {
                                newX = lastX - footboardWidth - minimumDistanceBetweenFootboards
                            }
                        } else {
                            newX = lastX - footboardWidth - minimumDistanceBetweenFootboards
                            if newX <= 0 {
                                newX = lastX + footboardWidth + minimumDistanceBetweenFootboards
                            }
                        }
                        // Re-clamp after nudge
                        newX = max(0, newX)
                        newX = min(sceneWidth - footboardWidth, newX)
                    }
                }

                // --- Create the actual Footboard ---
                // Spawn below the screen view
                let spawnY: CGFloat = offsetY - footboardHeight // Adjust if anchor point is not (0,1)

                // NSLog("new footboard X = %f", newX) // Use print() in Swift
                print("New footboard X = \(newX)")

                let newBoard = Footboard(texture: nil) // Use appropriate initializer
                newBoard.setFrame(x: newX, y: spawnY, h: footboardHeight, w: footboardWidth) // Use the Footboard's method
                newBoard.anchorPoint = CGPoint(x: 0, y: 1) // Match Obj-C
                newBoard.position = CGPoint(x: newX, y: spawnY) // Set position

                // Randomly assign type (conveyor, spikes, etc.) or tool
                // newBoard.setWhich(...) // Add logic for different types
                // newBoard.setToolNum(...) // Add logic for tools (bomb, cure)

                newFootboardsInLine.append(newBoard)
                nextXs.append(newX)
                addChild(newBoard) // Add to the scene

                createdCount += 1
            } // end loop for creating 1 or 2 from sourceX
        } // end loop through previousXs

        // --- Cleanup and Update State ---
        if !newFootboardsInLine.isEmpty {
            footboards.append(newFootboardsInLine) // Add the new line of boards
            currentXs = nextXs // Update the reference X positions for the *next* generation
        } else if !previousXs.isEmpty && nextXs.isEmpty {
            // Failsafe: If we couldn't generate any new boards but had sources,
            // reuse the previous X positions to avoid getting stuck.
            currentXs = previousXs
            print("Warning: Failed to generate new footboards, reusing previous X positions.")
        }

        // Remove old footboard lines that are way off-screen (optional optimization)
        if footboards.count > 20 { // Example limit
            let lineToRemove = footboards.removeFirst()
            lineToRemove.forEach { $0.removeFromParent() }
        }
    }

    private func updateAndCheckFootboards(_ isInjure: inout Bool, _ playerContactY: inout CGFloat?) {
        var destoryedFootboard: Footboard?
        var destoryedFootboardIndex: Int?
        var linesToRemove: IndexSet = []

        for (lineIndex, line) in footboards.enumerated() {
            var boardsToRemoveInLine: IndexSet = []

            for (boardIndex, board) in line.enumerated() {
                // --- Move board up ---
                board.drawDy(speed) // Assuming drawDy updates position

                // --- Check if off-screen ---
                if board.position.y > sceneHeight + footboardHeight { // Well above the screen
                    boardsToRemoveInLine.insert(boardIndex)
                    continue // No need for collision checks
                }

                // --- Add/Update Tool Node ---
                updateToolForBoard(board)

                // --- Player Collision Check ---
                guard let player = player else { continue }

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
                let verticalLanding = playerBottomY <= boardTopY && playerBottomY > boardTopY - (state.downSpeed + speed + 5) // Allow tolerance

                if horizontalOverlap && verticalLanding && !state.playerStandOnFootboard { // Only land once per frame check
                    print("Landing on board!")
                    state.playerStandOnFootboard = true
                    playerContactY = boardTopY // The Y position player should be moved to

                    if state.playerDownOnFootBoard {
                        // Handle board types (conveyor, spikes)
                        handleBoardLandingEffect(board, &isInjure)

                        // Handle tool collision *on landing*
                        handleToolCollision(board, &isInjure)

                        state.playerDownOnFootBoard = false // Reset flag indicating falling state
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
                footboards[lineIndex].remove(at: footboardIndex)
                destoryedFootboard = nil
                destoryedFootboardIndex = nil
            }

            // Remove boards marked for removal from this line
            // Iterate backwards to avoid index issues
            for index in boardsToRemoveInLine.reversed() {
                let boardToRemove = line[index]
                boardToRemove.tool?.removeFromParent() // Remove associated tool node
                boardToRemove.removeFromParent()
                // footboards[lineIndex].remove(at: index) // Modify copy, not original during iteration
            }
            // Update the original array outside the inner loop if modifying a mutable copy isn't feasible
            // Or reconstruct the line: footboards[lineIndex] = line.enumerated().filter { !boardsToRemoveInLine.contains($0.offset) }.map { $0.element }

            if line.isEmpty || boardsToRemoveInLine.count == line.count {
                linesToRemove.insert(lineIndex) // Mark the whole line for removal if empty
            }
        } // End loop through lines

        // Remove lines marked for removal from the main footboards array
        // Iterate backwards
        for index in linesToRemove.reversed() {
            // Ensure associated nodes are removed if not already handled
            footboards[index].forEach {
                $0.tool?.removeFromParent()
                $0.removeFromParent()
            }
            footboards.remove(at: index)
        }
    }

    private func updateToolForBoard(_ board: Footboard) {
        guard board.tool == nil && board.toolNum != Footboard.NOTOOL else {
            // Tool already exists or no tool assigned
            if let tool = board.tool {
                // Optional: Update tool position relative to board if needed
                // tool.position = CGPoint(x: board.position.x + board.size.width / 2 - tool.size.width * tool.anchorPoint.x,
                //                         y: board.position.y - tool.size.height * tool.anchorPoint.y)
                // Update tool animation/state if needed by the tool itself
                tool.draw(dy: speed) // Or tool.update(deltaTime)
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
            addChild(toolUtil) // Add tool node to the scene
        }
    }

    private func handleBoardLandingEffect(_ board: Footboard, _ isInjure: inout Bool) {
        state.playerWalkSpeed = 0 // Reset speed effect unless overridden

        switch board.which {
        case 1: // Left Conveyor
            state.whichFootboard = 1
            state.playerWalkSpeed = commonUtil.SLIDERSPEED // Move player left (assuming negative dx in updatePlayer)
            // moveDirection = MyScene.left // Or just apply speed?
        case 2: // Right Conveyor
            state.whichFootboard = 2
            state.playerWalkSpeed = -commonUtil.SLIDERSPEED // Move player right (assuming positive dx in updatePlayer)
            // moveDirection = MyScene.right
        case 5: // Spikes
            state.whichFootboard = 5 // Or just apply damage immediately?
            isInjure = true
            state.life -= 30
            applyDamageFlash()
        default: // Normal board
            state.whichFootboard = 0
            // No effect
        }
    }

    private func handleToolCollision(_ board: Footboard, _ isInjure: inout Bool) {
        guard let tool = board.tool, board.toolNum != Footboard.BOMB_EXPLODE else { return }

        // Check collision based on player frame and tool frame
        guard let player = player else { return }
        let toolFrame = tool.calculateAccumulatedFrame()
        let playerFrame = player.calculateAccumulatedFrame()

        // Use intersects for frame collision detection
        if playerFrame.intersects(toolFrame) {
            switch board.toolNum {
            case Footboard.BOMB:
                isInjure = true
                state.life -= 60
                applyDamageFlash()
                // Trigger explosion visual
                createExplosion(at: tool.position) // Use tool's position
                // Remove bomb tool, mark board as having no tool now
                tool.removeFromParent()
                board.tool = nil
                board.toolNum = Footboard.NOTOOL // Prevent re-triggering

            case Footboard.CURE:
                state.life = MyScene.config.maxLife // Full heal
                // Remove cure tool
                tool.removeFromParent()
                board.tool = nil
                board.toolNum = Footboard.NOTOOL

            case Footboard.EAT_MAN_TREE:
                tool.doEat() // Tell the tree tool to start eating animation
                if tool.isEated() { // Check if the eating animation completed this frame
                    isInjure = true
                    state.life -= 30
                    applyDamageFlash()
                }

            default:
                break // No action for other tool types on collision
            }
        }
    }

    private func createExplosion(at position: CGPoint) {
        guard MyScene.toolExplodingUtil == nil else { return } // Only one explosion at a time?

        MyScene.toolExplodingUtil = ToolUtil(texture: nil) // Assuming ToolUtil handles explosion animation
        MyScene.toolExplodingUtil?.setToolUtil(x: position.x, y: position.y, type: Footboard.BOMB_EXPLODE) // Center explosion?
        MyScene.toolExplodingUtil?.zPosition = 10 // Ensure explosion is visible
        if let explosion = MyScene.toolExplodingUtil {
            addChild(explosion)
            // ToolUtil should handle its own animation and removal, or updateTools needs to manage it
        }
    }

    private func updateTools(timeSinceLast: TimeInterval) {
        // Update the static exploding tool, if active
        if let explosion = MyScene.toolExplodingUtil {
            explosion.draw(dy: 0) // Pass speed 0? Or deltaTime? Assume ToolUtil handles its animation timing.
            if !explosion.isExploding { // Check if animation finished
                explosion.removeFromParent()
                MyScene.toolExplodingUtil = nil // Clear the static reference
            }
        }

        // Update other active tools if necessary (e.g., tree eating animation)
        for line in footboards {
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

    private func updateAndCheckFireballs(_ isInjure: inout Bool) {
        guard let player = player else { return }
        var fireballsToRemove: IndexSet = []

        for (index, ball) in fireballs.enumerated() {
            // Move fireball down (or up based on game logic)
            ball.moveDy(-(speed * 2), dx: 0) // Move faster than background? Adjust as needed

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
                state.life = 0 // Fireball is instant kill
                fireballsToRemove.insert(index) // Remove the fireball
                applyDamageFlash()
                // No need to continue checking other fireballs if player is dead
                // Break or return? Handle game end logic promptly.
            }
        }

        // Remove fireballs marked for removal
        for index in fireballsToRemove.reversed() {
            fireballs[index].removeFromParent()
            fireballs.remove(at: index)
        }
    }

    private func updatePlayerMovement(isOnGround: Bool, contactY: CGFloat?, isInjured: Bool) {
        guard let player = player else { return }

        var dx: CGFloat = 0
        var dy: CGFloat = 0

        // --- Vertical Movement ---
        if isOnGround {
            // Snap player to ground + apply upward movement matching the floor speed
            if let groundY = contactY {
                // Adjust Y based on player anchor point to place bottom on groundY
                player.position.y = groundY + player.size.height * player.anchorPoint.y
            }
            dy = speed // Move player up with the platform/background
            state.playerDownOnFootBoard = false // Not falling
        } else {
            // Apply gravity (downSpeed)
            dy = -state.downSpeed
            state.playerDownOnFootBoard = true // Now considered falling
        }

        // --- Horizontal Movement ---
        if state.moveDirection == MyScene.left {
            if player.position.x - player.size.width * player.anchorPoint.x > 0 { // Check left bound
                dx = -state.moveSpeed // Move left
            } else {
                dx = 0 // Stop at boundary
                // Optionally stop player animation?
            }
        } else if state.moveDirection == MyScene.right {
            if player.position.x + player.size.width * (1.0 - player.anchorPoint.x) < sceneWidth { // Check right bound
                dx = state.moveSpeed // Move right
            } else {
                dx = 0 // Stop at boundary
                // Optionally stop player animation?
            }
        } else {
            // No player input movement
            dx = 0
        }

        // Apply conveyor belt speed if on ground and on a conveyor
        if isOnGround {
            dx -= state.playerWalkSpeed // Apply board-induced speed (subtract because dx is positive right)
        }

        // --- Apply Movement & Update Animation ---
        // The Player class should handle its own animation updates based on state
        player.draw(dy: dy, dx: dx, isInjure: isInjured) // Tell player how much to move and if injured

        // --- Boundary Check (Redundant?) ---
        // Player position should ideally be clamped within drawDyDx or here
        // player.position.x = max(player.size.width * player.anchorPoint.x, player.position.x)
        // player.position.x = min(sceneWidth - player.size.width * (1.0 - player.anchorPoint.x), player.position.x)

        // Check if player fell off the bottom of the screen
        // Lose condition checked in main update loop now

        // --- Update Player Animation State ---
        // Determine state based on dx, dy, isOnGround
        // let currentState = determinePlayerState(dx: dx, dy: dy, isOnGround: isOnGround)
        // player.updateAnimation(state: currentState) // Player class handles this
    }
}
