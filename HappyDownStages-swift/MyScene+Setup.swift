//
//  MyScene+Setup.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import SpriteKit

extension MyScene {

    // MARK: - Scene Setup

    func setupScene() {
        guard let backgroundTexture = backgroundTexture else {
            print("Error: Background texture not set!")
            // Handle error: return, load default, etc.
            self.backgroundTexture = SKTexture(imageNamed: "new_bg1") // Load a default maybe?
            return // Or proceed with a default
        }

        // Set scene properties from initializer or size
        sceneWidth = frame.size.width
        sceneHeight = frame.size.height

        // Top Spiked Bar
        let topSpikedBarTexture = SKTexture(imageNamed: "top_spiked_bar")
        let topSpikedBarHeight = (topSpikedBarTexture.size().height / topSpikedBarTexture.size().width) * sceneWidth
        topSpikedBar = SKSpriteNode(texture: topSpikedBarTexture)
        topSpikedBar?.size = CGSize(width: sceneWidth, height: topSpikedBarHeight)
        topSpikedBar?.position = CGPoint(x: 0, y: sceneHeight - topSpikedBarHeight - 50) // Adjust Y as needed
        topSpikedBar?.anchorPoint = .zero
        topSpikedBar?.zPosition = 1
        if let topSpikedBar = topSpikedBar {
            addChild(topSpikedBar)
        }

        // Background Nodes
        backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode?.size = CGSize(width: sceneWidth, height: sceneHeight)
        backgroundNode?.position = CGPoint(x: 0, y: 0)
        backgroundNode?.anchorPoint = .zero
        backgroundNode?.zPosition = -10 // Ensure background is behind everything
        if let backgroundNode = backgroundNode {
            addChild(backgroundNode)
        }

        secondBackgroundNode = SKSpriteNode(texture: backgroundTexture) // Use same texture initially
        secondBackgroundNode?.size = CGSize(width: sceneWidth, height: sceneHeight)
        secondBackgroundNode?.position = CGPoint(x: 0, y: -sceneHeight) // Position below the first one
        secondBackgroundNode?.anchorPoint = .zero
        secondBackgroundNode?.zPosition = -10
        if let secondBackgroundNode = secondBackgroundNode {
            addChild(secondBackgroundNode)
        }

        // Initialize game elements and state
        setupGame()
    }

    func setupGame() {
        // Reset Game State Variables
        state.baseSpeed = sqrt(sceneWidth / 200.0) * 2
        speed = state.baseSpeed // Initial speed
        state.playerDownOnFootBoard = false
        state.playerStandOnFootboard = false
        state.readyFlag = true
        state.readyStep = 0
        state.playerWalkSpeed = 0
        state.whichFootboard = 0
        state.gameTimerCount = 0
        state.gameSuccess = false
        state.moveDirection = MyScene.stay
        state.scoreMultiple = MyScene.config.scoreMultiple
        state.downSpeed = state.baseSpeed // Falling speed related to base speed
        commonUtil.SLIDERSPEED = state.baseSpeed
        state.moveSpeed = commonUtil.SLIDERSPEED * 1.5 // Player horizontal speed
        MyScene.gameStop = false
        state.isMoving = false
        state.isGameFinish = false
        state.life = MyScene.config.initialLife

        // Clear Arrays
        currentXs.removeAll()
        footboards.removeAll()
        // footboardsTheSameLine.removeAll() // Local var now
        fireballs.removeAll()
        randomBackgroundIDs = ["new_bg1", "new_bg2", "new_bg3"]
        activeTimers.forEach { $0.invalidate() } // Invalidate previous timers
        activeTimers.removeAll()

        // Reset Static State (Use with caution)
        MyScene.gameFlag = true
        MyScene.gameStop = false
        MyScene.toolExplodingUtil = nil // Reset static explosion util

        // Adjust speed based on level
        speed = state.baseSpeed + CGFloat(level) * 0.6

        // Background Positioning
        firstBgHeight = 0
        // Ensure second background is positioned correctly relative to first
        secondBgHeight = -sceneHeight // Directly below the visible frame

        // Footboard Dimensions (Ensure bitmapUtil properties are accessible)
        guard let normalFootboardTexture = bitmapUtil.footboard_normal_bitmap else {
            print("Error: Missing normal footboard texture")
            return // Or handle error
        }
        footboardWidth = sceneWidth / MyScene.footboardWidthPercent
        footboardHeight = (normalFootboardTexture.size().height / normalFootboardTexture.size().width) * footboardWidth

        // Initial Footboard Setup
        let initialX: CGFloat = sceneWidth / 2 - footboardWidth / 2
        initialFootboard = Footboard(texture: nil, size: CGSize(width: footboardWidth, height: footboardHeight)) // Assuming Footboard has an init
        initialFootboard?.setFrame(x: initialX, y: 200 + footboardHeight, h: footboardHeight, w: footboardWidth) // Y adjusted for anchor point? Check Footboard.setFrame
        initialFootboard?.anchorPoint = CGPoint(x: 0, y: 1) // Top-left anchor
        initialFootboard?.setWhich(0) // Normal footboard
        initialFootboard?.setToolNum(Footboard.NOTOOL) // Assuming NOTOOL maps to noTool

        if let initialFootboard = initialFootboard {
            let initialLine = [initialFootboard]
            footboards.append(initialLine)
            currentXs.append(initialX) // Add the X of the first board
            addChild(initialFootboard)
        } else {
            print("Error: Could not create initial footboard")
            return
        }

        createFootboards(offsetY: 100)

        // Player Setup (Ensure bitmapUtil provides textures/sizes)
        guard let playerTexture = bitmapUtil.player_girl_left01_bitmap,
              let playerSize = bitmapUtil.player_girl_left01_size else {
            print("Error: Missing player texture or size")
            return
        }
        let playerInitialX = sceneWidth / 2
        // Place player slightly above the initial footboard
        let playerInitialY = (initialFootboard?.position.y ?? 0) + playerSize.height + 100 // Adjust Y based on anchor and desired position

        player = Player(texture: playerTexture, size: playerSize) // Assuming Player init
        player?.initPlayer(x: playerInitialX, y: playerInitialY)
        player?.anchorPoint = CGPoint(x: 0, y: 1) // Bottom-center anchor usually works well for platformers
        player?.zPosition = 5 // Ensure player is above footboards but below UI
        if let player = player {
            addChild(player)
        }

        // UI Elements Setup
        setupUIElements()

        // Ad View
        myAdView = MyADView(texture: nil) // Assuming MyADView is an SKSpriteNode subclass
        myAdView?.size = CGSize(width: sceneWidth, height: 50) // Standard ad height
        myAdView?.position = CGPoint(x: sceneWidth / 2, y: sceneHeight - 50) // Top of screen
        myAdView?.anchorPoint = CGPoint(x: 0.5, y: 1.0) // Anchor at top-center
        myAdView?.zPosition = 100 // Ensure ad is on top
        myAdView?.startAd() // Assuming this method exists
        if let myAdView = myAdView {
            addChild(myAdView)
        }

        // Initialize Timer Display Nodes
        initTimeNode()

        // Initialize HP Bar display
        changeHpBar() // Call initially to set it up
    }

    func setupUIElements() {
        // Life Bar
        lifeBgNode = SKSpriteNode(imageNamed: "life_bg")
        lifeNode = SKSpriteNode(imageNamed: "life") // The fill part

        lifeBgNode?.size = .zero // Initial size, will be set in changeHpBar
        lifeNode?.size = .zero   // Initial size

        if let lifeBgNode = lifeBgNode { addChild(lifeBgNode) }
        if let lifeNode = lifeNode { addChild(lifeNode) }

        // Ready Label
        readyLabel = SKLabelNode(fontNamed: "Chalkduster")
        readyLabel?.text = ""
        readyLabel?.fontSize = 30
        readyLabel?.fontColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        readyLabel?.position = CGPoint(x: frame.midX, y: frame.midY) // Center initially
        readyLabel?.zPosition = 50
        if let readyLabel = readyLabel {
            addChild(readyLabel)
        }

        // Game Timer Label (Initially hidden or showing level info?)
        // The Obj-C code adds it but hides it. Let's replicate that.
        gameTimerLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameTimerLabel?.text = "0" // Initial text
        gameTimerLabel?.fontSize = 20
        gameTimerLabel?.fontColor = SKColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
        // Position needs to be set relative to timer display nodes later?
        // Obj-C positioned it relative to a 'sharp' node which wasn't fully shown.
        // Let's position it near the timer display for now.
        gameTimerLabel?.position = CGPoint(x: 80, y: sceneHeight - 130) // Adjust as needed
        gameTimerLabel?.isHidden = true // Hidden initially as per Obj-C
        gameTimerLabel?.zPosition = 50
        if let gameTimerLabel = gameTimerLabel {
            addChild(gameTimerLabel)
        }

        // Red Flash Node for Damage
        redFlashNode = SKSpriteNode(color: .red, size: frame.size)
        redFlashNode?.anchorPoint = .zero
        redFlashNode?.position = .zero
        redFlashNode?.isHidden = true
        redFlashNode?.zPosition = 90 // Above most things but below UI top layer
        if let redFlashNode = redFlashNode {
            addChild(redFlashNode)
        }

        // Control Keys
        leftKeyNode = SKSpriteNode(imageNamed: "left_keyboard_btn")
        leftKeyNode?.size = CGSize(width: 80, height: 80)
        leftKeyNode?.position = CGPoint(x: 0, y: 0) // Bottom-left
        leftKeyNode?.anchorPoint = .zero
        leftKeyNode?.zPosition = 50
        if let leftKeyNode = leftKeyNode {
            addChild(leftKeyNode)
        }

        rightKeyNode = SKSpriteNode(imageNamed: "right_keyboard_btn")
        rightKeyNode?.size = CGSize(width: 80, height: 80)
        rightKeyNode?.position = CGPoint(x: sceneWidth - (rightKeyNode?.size.width ?? 80), y: 0) // Bottom-right
        rightKeyNode?.anchorPoint = .zero
        rightKeyNode?.zPosition = 50
        if let rightKeyNode = rightKeyNode {
            addChild(rightKeyNode)
        }
    }
}
