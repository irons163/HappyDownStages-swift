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
            footboardSpawner.createFootboards()
            // spawnFireball() // Maybe spawn fireballs less frequently?
        }

        // --- Update Existing Elements ---
        var isInjure = false // Track if player hit something this frame

        // Update Footboards and Check Collisions
        state.playerStandOnFootboard = false // Reset before checking
        var playerContactY: CGFloat? = nil // Y position if player lands

        collisionSystem.updateAndCheckFootboards(&isInjure, &playerContactY)

        // Update Fireballs and Check Collisions
        collisionSystem.updateAndCheckFireballs(&isInjure)

        // Update Tools (like the exploding bomb)
        collisionSystem.updateTools(timeSinceLast: timeSinceLast) // Pass dt if tools need it

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
