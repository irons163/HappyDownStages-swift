//
//  Footboard.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit

class Footboard: SKSpriteNode {
    
    enum ToolType: Int {
        case notool = 0
        case bomb = 1
        case cure = 2
        case bombExplode = 3
        case eatManTree = 4
    }
    
    var tool: ToolUtil?
    
    private var bitmapUtil = BitmapUtil.shared
    private var x: CGFloat = 0
    private var y: CGFloat = 0
    private var bitmap: SKTexture?
    private var bitmap1: SKTexture?
    private var bitmap2: SKTexture?
    private var bitmap3: SKTexture?
    
    private var height: CGFloat = 0
    private var width: CGFloat = 0
    var which: Int = 0
    private var animStep: Int = 0
    var toolNum: Int = 0

    override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    convenience init() {
        self.init(texture: nil, color: .clear, size: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setFrame(x: CGFloat, y: CGFloat, h: CGFloat, w: CGFloat) {
        self.x = x
        self.y = y
        self.height = h
        self.width = w
        self.position = CGPoint(x: self.x, y: self.y)
        self.size = CGSize(width: w, height: h)
        
        toolNum = Footboard.NOTOOL
        which = Int.random(in: 0...5)
        
        switch which {
        case 0:
            bitmap = bitmapUtil.footboard_normal_bitmap
        case 1:
            bitmap1 = bitmapUtil.footboard_moving_left1_bitmap
            bitmap2 = bitmapUtil.footboard_moving_left2_bitmap
            bitmap3 = bitmapUtil.footboard_moving_left3_bitmap
            bitmap = bitmap1
        case 2:
            bitmap1 = bitmapUtil.footboard_moving_right1_bitmap
            bitmap2 = bitmapUtil.footboard_moving_right2_bitmap
            bitmap3 = bitmapUtil.footboard_moving_right3_bitmap
            bitmap = bitmap1
        case 3:
            bitmap1 = bitmapUtil.footboard_unstable1_bitmap
            bitmap2 = bitmapUtil.footboard_unstable2_bitmap
            bitmap3 = bitmapUtil.footboard_unstable3_bitmap
            bitmap = bitmap1
        case 4:
            bitmap1 = bitmapUtil.footboard_wood_bitmap
            bitmap2 = bitmapUtil.footboard_wood2_bitmap
            bitmap3 = bitmapUtil.footboard_wood3_bitmap
            bitmap = bitmap1
        case 5:
            bitmap = bitmapUtil.footboard_spiked_bitmap
        default:
            bitmap = bitmapUtil.footboard_normal_bitmap
        }
        
        self.texture = bitmap
        
        let random = Int.random(in: 0...5)
        if [1, 2, 4].contains(random) {
            toolNum = random
        } else {
            toolNum = Footboard.NOTOOL
        }
    }

    func drawDy(_ dy: CGFloat) {
        y += dy
        self.position.y = y
        
        switch which {
        case 1:
            switch animStep % 3 {
            case 0: bitmap = bitmapUtil.footboard_moving_left1_bitmap
            case 1: bitmap = bitmapUtil.footboard_moving_left2_bitmap
            default: bitmap = bitmapUtil.footboard_moving_left3_bitmap
            }
            animStep = (animStep + 1) % 3
        case 2:
            switch animStep % 3 {
            case 0: bitmap = bitmapUtil.footboard_moving_right1_bitmap
            case 1: bitmap = bitmapUtil.footboard_moving_right2_bitmap
            default: bitmap = bitmapUtil.footboard_moving_right3_bitmap
            }
            animStep = (animStep + 1) % 3
        case 3:
            if animStep < 10 {
                bitmap = bitmap1
            } else if animStep < 20 {
                bitmap = bitmap2
            } else if animStep < 28 {
                bitmap = bitmap3
            } else {
                bitmap = nil
            }
        case 4:
            if animStep < 10 {
                bitmap = bitmap1
            } else if animStep < 20 {
                bitmap = bitmap2
            } else if animStep < 28 {
                bitmap = bitmap3
            } else {
                bitmap = nil
            }
        default: break
        }

        if let bmp = bitmap {
            self.texture = bmp
        }
    }

    func setWhich(_ which: Int) {
        self.which = which
        animStep = 0
        setFrame(x: x, y: y, h: height, w: width)
    }

    func setToolNum(_ num: Int) {
        toolNum = num
    }

    func getToolNum() -> Int {
        return toolNum
    }

    func setCount() {
        if which == 3 || which == 4 {
            animStep += 1
        }
    }

    func getBitmap() -> SKTexture? {
        return bitmap
    }

    func getWhich() -> Int {
        return which
    }

    func getX() -> CGFloat {
        return x
    }

    func getY() -> CGFloat {
        return y
    }

    static var NOTOOL: Int { return ToolType.notool.rawValue }
    static var BOMB: Int { return ToolType.bomb.rawValue }
    static var CURE: Int { return ToolType.cure.rawValue }
    static var BOMB_EXPLODE: Int { return ToolType.bombExplode.rawValue }
    static var EAT_MAN_TREE: Int { return ToolType.eatManTree.rawValue }
}
