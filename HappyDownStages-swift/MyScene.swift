//
//  MyScene.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit
import GameplayKit // For potential random number generation, though arc4random is used

class MyScene: SKScene {

    // MARK: - Static Properties & Constants

    static let infinityLevel = 13 // start level: 0

    // Movement States
    static let stay = 0
    static let left = 1
    static let right = 2

    // Static Game State
    static var gameFlag = true
    static var gameStop = false // Needs proper initialization if used statically

    // Static Background
    static var nextBackground: SKTexture?

    // Game Constants
    static let gameTime = 60
    static let footboardWidthPercent: CGFloat = 4
    static let smoothDeviation: CGFloat = 2

    // Static Reference (Be cautious with static mutable state like this)
    // Consider if this truly needs to be static or instance-based
    static var toolExplodingUtil: ToolUtil?

    // MARK: - Properties

    // Delegate
    weak var gameDelegate: GameDelegate?

    // Timing
    var lastSpawnTimeInterval: TimeInterval = 0
    var lastUpdateTimeInterval: TimeInterval = 0
    var lastSpawnCreateFootboardTimeInterval: TimeInterval = 0
    var gameTimer: Timer?
    var readyTimer: Timer?
    var activeTimers: [Timer] = [] // Keep track of timers to invalidate

    // Scene Dimensions & Configuration
    var sceneHeight: CGFloat = 0
    var sceneWidth: CGFloat = 0
    var level: Int = 0
    var backgroundTexture: SKTexture? // Initial background

    // Game State & Scores
    var playerDownOnFootBoard = false
    var playerStandOnFootboard = false
    var readyFlag = true
    var readyStep = 0
    var gameSuccess = false
    var moveDirection = MyScene.stay
    var isPressLeftMoveBtn = false
    var isPressRightMoveBtn = false
    var scoreMultiple = 100
    var isGameFinish = false
    var isMoving = false
    var gameTimerCount = 0 // Renamed from 'count'
    var drawCount = 0 // Counter for footboard generation timing
    var life = 90 // Start life

    // Physics & Movement Speeds
    var baseSpeed: CGFloat = 0.0
//    var speed: CGFloat = 0.0 // Current background/footboard upward speed
    var playerWalkSpeed: CGFloat = 0.0 // Speed induced by conveyor belts
    var downSpeed: CGFloat = 0.0 // Player falling speed
    var moveSpeed: CGFloat = 0.0 // Player left/right movement speed

    // Game Elements & Nodes
    var player: Player?
    var initialFootboard: Footboard? // The very first footboard
    var currentXs: [CGFloat] = [] // X-positions for next footboard generation line
    var footboards: [[Footboard]] = [] // Array of arrays (lines) of footboards
    // var footboardsTheSameLine: [Footboard] = [] // Temp var, better handled locally
    var fireballs: [FireBall] = []
    var randomBackgroundIDs: [String] = ["bg01", "bg02", "bg03"] // Background names

    // Nodes (using Optional '?' as they are created in setup methods)
    var backgroundNode: SKSpriteNode?
    var secondBackgroundNode: SKSpriteNode?
    var topSpikedBar: SKSpriteNode?
    var redFlashNode: SKSpriteNode? // Node for damage indication
    var lifeBgNode: SKSpriteNode?
    var lifeNode: SKSpriteNode? // The actual HP bar fill
    var readyLabel: SKLabelNode?
    var gameTimerLabel: SKLabelNode? // Shows remaining/elapsed time
    var leftKeyNode: SKSpriteNode?
    var rightKeyNode: SKSpriteNode?
    var myAdView: MyADView?

    // UI Nodes for Timer Display
    var timeMinuteTensDigital: SKSpriteNode?
    var timeMinuteSingalDigital: SKSpriteNode?
    var timeQmark: SKSpriteNode?
    var timeScecondTensDigital: SKSpriteNode?
    var timeSecondSingalDigital: SKSpriteNode?

    // Game Element Dimensions
    var footboardHeight: CGFloat = 0
    var footboardWidth: CGFloat = 0

    // Player Landing Helper
    var whichFootboard = 0 // Type of footboard player landed on (0=normal, 1=left, 2=right, 5=spikes)

    // Configuration Constants (Consider making these static if they don't change per instance)
    var distanceMultiple: CGFloat = 10
    var minimumDistanceBetweenFootboards: CGFloat = 30

    // Utilities (Assuming they are singletons or initialized here)
    let bitmapUtil = BitmapUtil.shared // Assumes Singleton access
    let commonUtil = CommonUtil.shared // Assumes Singleton access
    
    var firstBgHeight: CGFloat = 0.0
    var secondBgHeight: CGFloat = 0.0

    // MARK: - Initialization

    // Convenience initializer matching the Obj-C factory method
    convenience init(size: CGSize, background: SKTexture, height: CGFloat, width: CGFloat, level: Int) {
        self.init(size: size) // Call the designated initializer

        // Set properties AFTER calling self.init()
        self.backgroundTexture = background
        self.sceneHeight = height // Or use size.height
        self.sceneWidth = width   // Or use size.width
        self.level = level

        // Now setup the scene based on these properties
        setupScene()
    }

    // Designated initializer
    override init(size: CGSize) {
        super.init(size: size)
        // Minimal setup here, most is deferred to setupScene/setupGame
        // which are called by the convenience init or didMove(to:)
        self.sceneWidth = size.width
        self.sceneHeight = size.height
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Called when the scene is presented
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        view.isMultipleTouchEnabled = true

        // If not initialized through the convenience init, setup might be needed here
        // Check if setupScene has already run if using both init paths.
        if backgroundNode == nil { // Simple check to see if setup ran
             // If backgroundTexture wasn't provided via convenience init, load a default?
             // backgroundTexture = SKTexture(imageNamed: "default_bg") // Example
             setupScene()
        }
    }

    // MARK: - Scene Setup

    private func setupScene() {
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


    private func setupGame() {
        // Reset Game State Variables
        baseSpeed = sceneWidth / 240.0
        speed = baseSpeed // Initial speed
        playerDownOnFootBoard = false
        playerStandOnFootboard = false
        readyFlag = true
        readyStep = 0
        playerWalkSpeed = 0
        whichFootboard = 0
        gameTimerCount = 0
        gameSuccess = false
        moveDirection = MyScene.stay
        scoreMultiple = 100
        downSpeed = baseSpeed // Falling speed related to base speed
        commonUtil.SLIDERSPEED = baseSpeed
        moveSpeed = commonUtil.SLIDERSPEED * 3 + CGFloat(level) * 0.6 // Player horizontal speed
        MyScene.gameStop = false
        isMoving = false
        isGameFinish = false
        life = 90

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
        speed = baseSpeed + CGFloat(level) * 0.6

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
        initialFootboard?.setFrame(x: initialX, y: 0 + footboardHeight, h: footboardHeight, w: footboardWidth) // Y adjusted for anchor point? Check Footboard.setFrame
        initialFootboard?.anchorPoint = CGPoint(x: 0, y: 1) // Top-left anchor
        initialFootboard?.position = CGPoint(x: initialX, y: 0 + footboardHeight) // Set position based on anchor
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


        // Player Setup (Ensure bitmapUtil provides textures/sizes)
        guard let playerTexture = bitmapUtil.player_girl_left01_bitmap,
              let playerSize = bitmapUtil.player_girl_left01_size else {
             print("Error: Missing player texture or size")
             return
        }
        let playerInitialX = sceneWidth / 2
        // Place player slightly above the initial footboard
        let playerInitialY = (initialFootboard?.position.y ?? 0) + playerSize.height + 80 // Adjust Y based on anchor and desired position

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

    private func setupUIElements() {
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

    // MARK: - Game Loop

    override func update(_ currentTime: TimeInterval) {
        // --- Delta Time Calculation ---
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime // First frame
        }
        let dt = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        // Handle pauses or large gaps
        let timeSinceLast = (dt > 1.0) ? (1.0 / 60.0) : dt // Clamp delta time


        // --- Ready State ---
        if readyFlag && readyTimer == nil {
            initReadyTimer()
        }

        // --- Game Paused / Not Ready ---
        guard MyScene.gameFlag && !readyFlag else {
            // Allow ad view updates even if game is paused?
            myAdView?.startAd() // Assuming an update method exists
            return
        }

        // --- Start Game Timer ---
        if gameTimer == nil {
             initGameTimer() // Start the game timer only once game is running
        }


        // --- Check Win Condition (Time Limit) ---
        if level < MyScene.infinityLevel && gameTimerCount >= MyScene.gameTime {
             gameSuccess = true
             handleGameEnd() // Use a unified end function
             return // Stop further updates this frame
        }


        // --- Update Ad ---
        myAdView?.startAd() // Assuming an update method exists


        // --- Update Game Elements Based on Time Delta ---
        updateGameElements(timeSinceLast: timeSinceLast)


        // --- Check Lose Conditions ---
         if life <= 0 || (player?.position.y ?? sceneHeight + 1) < 0 { // Player fell off bottom
             if !isGameFinish { // Prevent multiple calls
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
        lastSpawnTimeInterval += timeSinceLast
        lastSpawnCreateFootboardTimeInterval += timeSinceLast
        
        guard lastSpawnTimeInterval >= 0.1 else {
            return
        }
        
        lastSpawnTimeInterval = 0

        // --- Background Scrolling ---
        scrollBackground()

        // --- Footboard Generation ---
        // Throttle footboard creation based on time/distance scrolled
        // Obj-C used drawCount % interval. Let's use time interval for smoother scaling.
        // Calculate interval based on speed. Faster speed -> shorter interval.
        let footboardCreationInterval = TimeInterval( (baseSpeed * 6 / speed) )
        if lastSpawnCreateFootboardTimeInterval > footboardCreationInterval {
            lastSpawnCreateFootboardTimeInterval = 0 // Reset timer
            createFootboards()
            // spawnFireball() // Maybe spawn fireballs less frequently?
        }

        // --- Update Existing Elements ---
        var isInjure = false // Track if player hit something this frame
        var isDrawPlayer = true // Flag from Obj-C, might not be needed if player update is consolidated

        // Update Footboards and Check Collisions
        playerStandOnFootboard = false // Reset before checking
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
                 life = 0 // Instant kill
            }
        }


        // --- Update Player ---
        updatePlayerMovement(isOnGround: playerStandOnFootboard, contactY: playerContactY, isInjured: isInjure)


        // --- Update UI ---
        if !gameSuccess {
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

    private func createFootboards() {
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

            for i in 0..<numToCreateFromThis {
                 if createdCount >= boardsToCreateTotal { break }

                 // Calculate horizontal offset (des in Obj-C)
                 var randomOffset = CGFloat(Int.random(in: 7...20)) // 7-20 range from Obj-C logic
                 randomOffset = (Int.random(in: 0...1) == 0) ? -randomOffset : randomOffset // Random direction
                 randomOffset *= distanceMultiple

                 // Calculate new X position
                 var newX = sourceX + randomOffset

                 // Clamp X position within screen bounds, leaving space if creating two
                 let minX: CGFloat = (numToCreateFromThis == 2 && i == 0) ? 0 : minimumDistanceBetweenFootboards
                 let maxX: CGFloat = (numToCreateFromThis == 2 && i == 1) ? sceneWidth - footboardWidth : sceneWidth - footboardWidth - minimumDistanceBetweenFootboards

                 newX = max(minX, newX) // Clamp minimum to 0
                 newX = min(maxX, newX) // Clamp maximum

                 // Avoid overlap if creating two from the same source or close sources
                 if !nextXs.isEmpty {
                     let lastX = nextXs.last!
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
                 let spawnY: CGFloat = -footboardHeight // Adjust if anchor point is not (0,1)

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


    private func updateAndCheckFootboards( _ isInjure: inout Bool, _ playerContactY: inout CGFloat?) {
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
                 let playerLeftX = player.position.x - player.size.width * player.anchorPoint.x + MyScene.smoothDeviation * 2 // Adjusted collision box
                 let playerRightX = player.position.x + player.size.width * (1.0 - player.anchorPoint.x) - MyScene.smoothDeviation * 2 // Adjusted collision box

                 let boardTopY = board.position.y // Since anchor is (0,1)
                 let boardBottomY = board.position.y - board.size.height
                 let boardLeftX = board.position.x
                 let boardRightX = board.position.x + board.size.width

                // Conditions for potential landing:
                // 1. Player is horizontally overlapping the board.
                // 2. Player *was* above the board in the previous frame(s).
                // 3. Player's bottom is now at or just below the board's top.
                let horizontalOverlap = playerRightX > boardLeftX && playerLeftX < boardRightX
                // Check vertical position relative to board top, allowing for slight penetration due to falling speed
                let verticalLanding = playerBottomY <= boardTopY && playerBottomY > boardTopY - (downSpeed + speed + 5) // Allow tolerance

                 if horizontalOverlap && verticalLanding && !playerStandOnFootboard { // Only land once per frame check
                     print("Landing on board!")
                     playerStandOnFootboard = true
                     playerContactY = boardTopY // The Y position player should be moved to

                     if playerDownOnFootBoard {
                         // Handle board types (conveyor, spikes)
                         handleBoardLandingEffect(board, &isInjure)

                         // Handle tool collision *on landing*
                         handleToolCollision(board, &isInjure)
                         
                         playerDownOnFootBoard = false // Reset flag indicating falling state
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
                if board.tool != nil && board.toolNum != Footboard.BOMB_EXPLODE { // Don't check collision with explosion itself here
                      let toolFrame = board.tool!.calculateAccumulatedFrame() // Get tool's frame in scene coordinates
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
            // case Footboard.BOMB_EXPLODE: // Explosion is handled separately
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
        playerWalkSpeed = 0 // Reset speed effect unless overridden

        switch board.which {
        case 1: // Left Conveyor
            whichFootboard = 1
            playerWalkSpeed = commonUtil.SLIDERSPEED // Move player left (assuming negative dx in updatePlayer)
            // moveDirection = MyScene.left // Or just apply speed?
        case 2: // Right Conveyor
            whichFootboard = 2
            playerWalkSpeed = -commonUtil.SLIDERSPEED // Move player right (assuming positive dx in updatePlayer)
            // moveDirection = MyScene.right
        case 5: // Spikes
             whichFootboard = 5 // Or just apply damage immediately?
             isInjure = true
             life -= 30
             applyDamageFlash()
        default: // Normal board
             whichFootboard = 0
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
                 life -= 60
                 applyDamageFlash()
                 // Trigger explosion visual
                 createExplosion(at: tool.position) // Use tool's position
                 // Remove bomb tool, mark board as having no tool now
                 tool.removeFromParent()
                 board.tool = nil
                 board.toolNum = Footboard.NOTOOL // Prevent re-triggering

             case Footboard.CURE:
                 life = 90 // Full heal
                 // Remove cure tool
                 tool.removeFromParent()
                 board.tool = nil
                 board.toolNum = Footboard.NOTOOL

             case Footboard.EAT_MAN_TREE:
                 tool.doEat() // Tell the tree tool to start eating animation
                 if tool.isEated() { // Check if the eating animation completed this frame
                     isInjure = true
                     life -= 30
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
                 if let tool = board.tool {
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
                 life = 0 // Fireball is instant kill
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
             playerDownOnFootBoard = false // Not falling
         } else {
             // Apply gravity (downSpeed)
             dy = -downSpeed
             playerDownOnFootBoard = true // Now considered falling
         }

         // --- Horizontal Movement ---
         if moveDirection == MyScene.left {
              if player.position.x - player.size.width * player.anchorPoint.x > 0 { // Check left bound
                  dx = -moveSpeed // Move left
              } else {
                  dx = 0 // Stop at boundary
                  // Optionally stop player animation?
              }
          } else if moveDirection == MyScene.right {
              if player.position.x + player.size.width * (1.0 - player.anchorPoint.x) < sceneWidth { // Check right bound
                  dx = moveSpeed // Move right
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
              dx -= playerWalkSpeed // Apply board-induced speed (subtract because dx is positive right)
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


    // MARK: - Event Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let view = self.view else { return } // Need view for coordinate conversion if using view coordinates

        // Ad View Touch Handling (Pass touches, let the ad view check)
        myAdView?.touchesBegan(touches, with: event)

        for touch in touches {
            let location = touch.location(in: self) // Location in scene coordinates

            if let leftKey = leftKeyNode, leftKey.contains(location) {
                isPressLeftMoveBtn = true
                moveDirection = MyScene.left
                player?.updateBitmap(type: MyScene.left) // Tell player to use left-facing animation
            } else if let rightKey = rightKeyNode, rightKey.contains(location) {
                isPressRightMoveBtn = true
                moveDirection = MyScene.right
                player?.updateBitmap(type: MyScene.right) // Tell player to use right-facing animation
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
         // Optional: Handle dragging off buttons if needed
         for touch in touches {
             let location = touch.location(in: self)
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
            isPressLeftMoveBtn = false
        }
        if rightReleased {
            isPressRightMoveBtn = false
        }


        // Determine new move state based on which buttons are *still* pressed
        if isPressLeftMoveBtn {
            moveDirection = MyScene.left
            player?.updateBitmap(type: MyScene.left) // Ensure correct animation
        } else if isPressRightMoveBtn {
            moveDirection = MyScene.right
            player?.updateBitmap(type: MyScene.right) // Ensure correct animation
        } else {
             moveDirection = MyScene.stay
             isMoving = false // Reset moving flag if used for animation triggers
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


    // MARK: - Game State & Timers

    private func initReadyTimer() {
        readyStep = 0
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

         if readyStep == 0 {
             readyLabel.text = "READY"
             // Recenter label if needed (text length changes)
             readyLabel.position = CGPoint(x: frame.midX, y: frame.midY)
             readyLabel.isHidden = false
         } else if readyStep < 4 { // Counts 3, 2, 1
             readyLabel.text = "\(4 - readyStep)"
             readyLabel.position = CGPoint(x: frame.midX, y: frame.midY) // Recenter
         } else if readyStep == 4 {
             readyLabel.text = "GO!" // Optional "GO!" message
             readyLabel.position = CGPoint(x: frame.midX, y: frame.midY)
         } else { // readyStep >= 5
             readyLabel.isHidden = true
             readyTimer?.invalidate()
             readyFlag = false // Ready sequence finished, start the game
             return
         }
         readyStep += 1
    }


    private func initGameTimer() {
        gameTimerCount = 0 // Reset count
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
         guard MyScene.gameFlag && !readyFlag else {
             // Consider invalidating timer here if game ended unexpectedly
             return
         }

         gameTimerCount += 1


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


    // MARK: - UI Updates

    private func initTimeNode() {
        let timeNodeSize = CGSize(width: 30, height: 30)
        let timeTextures = TextureHelper.timeTextures()
        guard timeTextures.count > 10 else {
             print("Error: Missing time textures")
             return
        }
        let yPos = sceneHeight - timeNodeSize.height / 2 - 45 - 50 // Match Obj-C positioning

        timeMinuteTensDigital = SKSpriteNode(texture: timeTextures[0])
        timeMinuteTensDigital?.size = timeNodeSize
        timeMinuteTensDigital?.position = CGPoint(x: 0 + timeNodeSize.width * 0.5, y: yPos)

        timeMinuteSingalDigital = SKSpriteNode(texture: timeTextures[0])
        timeMinuteSingalDigital?.size = timeNodeSize
        timeMinuteSingalDigital?.position = CGPoint(x: timeMinuteTensDigital!.position.x + timeNodeSize.width, y: yPos)

        timeQmark = SKSpriteNode(texture: timeTextures[10]) // Colon texture
        timeQmark?.size = timeNodeSize
        timeQmark?.position = CGPoint(x: timeMinuteSingalDigital!.position.x + timeNodeSize.width, y: yPos)

        timeScecondTensDigital = SKSpriteNode(texture: timeTextures[0])
        timeScecondTensDigital?.size = timeNodeSize
        timeScecondTensDigital?.position = CGPoint(x: timeQmark!.position.x + timeNodeSize.width, y: yPos)

        timeSecondSingalDigital = SKSpriteNode(texture: timeTextures[0])
        timeSecondSingalDigital?.size = timeNodeSize
        timeSecondSingalDigital?.position = CGPoint(x: timeScecondTensDigital!.position.x + timeNodeSize.width, y: yPos)


        // Add nodes to scene
        [timeMinuteTensDigital, timeMinuteSingalDigital, timeQmark, timeScecondTensDigital, timeSecondSingalDigital].forEach { node in
            if let node = node {
                 node.zPosition = 50
                 addChild(node)
            }
        }
    }


    private func setTimeTextures() {
        let displayTime: Int
        if level < MyScene.infinityLevel {
             displayTime = max(0, MyScene.gameTime - gameTimerCount) // Countdown
        } else {
             displayTime = gameTimerCount // Count up for infinity mode
        }

        // gameTimerLabel?.text = "\(displayTime)" // Update simple label if used

        // Update digital display nodes
        let minutes = displayTime / 60
        let seconds = displayTime % 60

        timeMinuteTensDigital?.texture = getTimeTexture(for: (minutes / 10) % 10)
        timeMinuteSingalDigital?.texture = getTimeTexture(for: minutes % 10)
        timeScecondTensDigital?.texture = getTimeTexture(for: seconds / 10)
        timeSecondSingalDigital?.texture = getTimeTexture(for: seconds % 10)
    }


    private func getTimeTexture(for digit: Int) -> SKTexture? {
        let textures = TextureHelper.timeTextures()
        guard digit >= 0 && digit <= 9 else {
             return textures.first // Return '0' texture or nil on error
        }
        return textures[digit]
    }


    private func changeHpBar() {
        guard let lifeNode = lifeNode, let lifeBgNode = lifeBgNode else { return }

        let maxLife: CGFloat = 90.0
        let currentLife = CGFloat(max(0, life)) // Ensure life isn't negative

        // Calculate width based on life percentage
        let bgWidth: CGFloat = sceneWidth / 3.0 + 6 // Background slightly wider
        let maxFillWidth: CGFloat = sceneWidth / 3.0 // Max width of the fill part
        let hpBarWidth = maxFillWidth * (currentLife / maxLife)

        // Positioning (Top Right)
        let yPos = sceneHeight - lifeNode.size.height / 2 - 45 - 50 // Match timer Y pos? Adjust as needed
        let offsetX: CGFloat = 15 // Offset from the right edge

        // Set sizes
        lifeNode.size = CGSize(width: hpBarWidth, height: 26) // Height from Obj-C
        lifeBgNode.size = CGSize(width: bgWidth, height: 36) // Height from Obj-C

        // Set anchors (Left edge for fill, Center or Left for background)
        lifeNode.anchorPoint = CGPoint(x: 0, y: 0.5) // Anchor left-middle for width scaling
        lifeBgNode.anchorPoint = CGPoint(x: 1.0, y: 0.5) // Anchor right-middle for positioning

        // Set positions
        lifeBgNode.position = CGPoint(x: sceneWidth - offsetX, y: yPos)
        // Position lifeNode's left edge relative to the background's right edge (minus padding)
        lifeNode.position = CGPoint(x: lifeBgNode.position.x - lifeBgNode.size.width + 3, y: yPos) // +3 for padding inside bg

        lifeBgNode.zPosition = 48
        lifeNode.zPosition = 49 // Fill on top of background
    }

    // MARK: - Game Over & Score

    private func handleGameEnd() {
        guard !isGameFinish else { return } // Prevent multiple calls
        isGameFinish = true
        MyScene.gameFlag = false // Stop game logic

        // Invalidate timers
        gameTimer?.invalidate()
        readyTimer?.invalidate()
        activeTimers.removeAll() // Clear timer list


        // Determine win/lose and act accordingly
        if gameSuccess {
             // Save progress if needed
             let maxLevel = UserDefaults.standard.integer(forKey: "level")
             if maxLevel < MyScene.infinityLevel && level >= maxLevel {
                 let nextLevel = level + 1 // Should be maxLevel + 1? Check Obj-C logic carefully
                 UserDefaults.standard.set(nextLevel, forKey: "level")
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
        let timeScore = (level < MyScene.infinityLevel) ? (MyScene.gameTime * level * scoreMultiple) : (gameTimerCount * scoreMultiple) // Score based on time survived in infinity
        let countScore = gameTimerCount * scoreMultiple // Or is 'count' something else? Check Obj-C 'count' usage. Assuming it's game time.
        let finalScore = timeScore + countScore // Combine scores? Obj-C logic was a bit ambiguous: GAME_TIME * level * SCORE_MULTIPLE + count * SCORE_MULTIPLE

        // Report score to Game Center
        GameCenterUtil.shared.reportScore(Int64(finalScore), forCategory: "com.irons.HappyDownStages") // Use correct leaderboard ID

        // Show lose dialog via delegate
        gameDelegate?.showLoseDialog(score: finalScore)
    }

    // MARK: - Utilities

    func getRandomBgResId() -> String {
        guard !randomBackgroundIDs.isEmpty else { return "new_bg1" } // Default fallback
        let index = Int.random(in: 0..<randomBackgroundIDs.count)
        return randomBackgroundIDs[index]
    }


    func setAdClickable(_ clickable: Bool) {
        myAdView?.adClickable = clickable
    }

    private func applyDamageFlash() {
         redFlashNode?.isHidden = false
         // Optional: Add a fade out action for the flash effect
         // redFlashNode?.run(SKAction.sequence([
         //     SKAction.fadeIn(withDuration: 0.05),
         //     SKAction.fadeOut(withDuration: 0.15)
         // ]))
    }


    // MARK: - Static Accessors (If needed, direct access often preferred in Swift)

    // Static func setNextBackground(nextBg: SKTexture?) {
    //     MyScene.nextBackground = nextBg
    // }
    // Static func getGameFlag() -> Bool {
    //     return MyScene.gameFlag
    // }
    // Static func setGameFlag(_ flag: Bool) {
    //     MyScene.gameFlag = flag
    // }
    // Static func getFootboardWidthPercent() -> CGFloat {
    //     return MyScene.footboardWidthPercent
    // }
}

// MARK: - Extensions for Helper Classes (Placeholders)

// Assume these classes/structs exist elsewhere in your project

protocol PlayerProtocol { // Example protocol if Player is complex
    func initPlayer(x: CGFloat, y: CGFloat, h: CGFloat, w: CGFloat)
    func updateBitmap(_ direction: Int)
    func drawDy(_ dy: CGFloat, dx: CGFloat, isInjure: Bool)
}

protocol ToolUtilProtocol {
    var tool_x: CGFloat { get }
    var tool_y: CGFloat { get }
    var tool_width: CGFloat { get }
    var isExploding: Bool { get }

    func setToolUtil(x: CGFloat, y: CGFloat, type: Int)
    func draw(_ speed: CGFloat) // Or func update(deltaTime: TimeInterval)
    func doEat()
    func isEated() -> Bool
}
