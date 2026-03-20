//
//  MyScene.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit
import GameplayKit // For potential random number generation, though arc4random is used

final class MyScene: SKScene {

    // MARK: - Static Properties & Constants

    static let infinityLevel = 13 // start level: 0

    static let config = GameConfig()

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
    static let gameTime = config.gameTime
    static let footboardWidthPercent = config.footboardWidthPercent
    static let smoothDeviation = config.smoothDeviation

    // Static Reference (Be cautious with static mutable state like this)
    // Consider if this truly needs to be static or instance-based
    static var toolExplodingUtil: ToolUtil?

    // MARK: - Properties

    // Delegate
    weak var gameDelegate: GameDelegate?

    // State
    var state = GameState()

    // Systems
    lazy var collisionSystem = CollisionSystem(scene: self)
    lazy var footboardSpawner = FootboardSpawner(scene: self)

    // Timing
    var gameTimer: Timer?
    var readyTimer: Timer?
    var activeTimers: [Timer] = [] // Keep track of timers to invalidate

    // Scene Dimensions & Configuration
    var sceneHeight: CGFloat = 0
    var sceneWidth: CGFloat = 0
    var level: Int = 0
    var backgroundTexture: SKTexture? // Initial background

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
