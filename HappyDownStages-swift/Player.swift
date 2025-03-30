//
//  Player.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit

class Player: SKSpriteNode {

    private var bitmapUtil = BitmapUtil.shared
    private var commonUtil = CommonUtil.shared

    private var bitmap: SKTexture?
    private var walkBitmap01: SKTexture?
    private var walkBitmap02: SKTexture?
    private var walkBitmap03: SKTexture?
    private var downBitmap: SKTexture?
    private var injureBitmap: SKTexture?

    private var x: CGFloat = 0
    private var y: CGFloat = 0
    private var width: CGFloat = 0
    private var height: CGFloat = 0
    private var walkCount: Int = 0
    private var isInjure: Bool = false

    convenience init() {
        self.init(texture: nil, color: .clear, size: .zero)
    }

    func initPlayer(x: CGFloat, y: CGFloat, height: CGFloat? = nil, width: CGFloat? = nil) {
        self.x = x
        self.y = y

        // 根據性別設定角色圖片
        setPlayerBitmapLeft()

        self.height = height ?? self.size.height
        self.width = width ?? self.size.width

        self.y -= self.height
        self.position = CGPoint(x: self.x, y: self.y)
    }

    func draw(dy: CGFloat, dx: CGFloat, isInjure: Bool) {
        if isInjure {
            self.isInjure = true
            DispatchQueue.global().async {
                usleep(300_000)
                DispatchQueue.main.async {
                    self.isInjure = false
                }
            }
        }
        draw(dy: dy, dx: dx)
    }

    private func draw(dy: CGFloat, dx: CGFloat) {
        y += dy
        x += dx
        self.position = CGPoint(x: x, y: y)

        if isInjure {
//            x += dx
            self.position = CGPoint(x: x, y: y)
            self.texture = injureBitmap
            walkCount = 0
            return
        }

        if dx == 0 && dy >= 0 {
            self.texture = walkBitmap02
            walkCount = 0
        } else if dy < 0 {
            self.texture = downBitmap
            walkCount = 0
        } else if commonUtil.SLIDERSPEED == dx || commonUtil.SLIDERSPEED == -dx {
            self.texture = walkBitmap02
            walkCount = 0
        } else {
            if walkCount % 2 == 0 {
                self.texture = walkBitmap02
            } else if walkCount % 3 == 0 {
                self.texture = walkBitmap01
            } else {
                self.texture = walkBitmap03
            }
            walkCount += 1
        }
    }

    func updateBitmap(type: Int) {
        if type == MyScene.left {
            setPlayerBitmapLeft()
        } else if type == MyScene.right {
            setPlayerBitmapRight()
        }
    }

    private func setPlayerBitmapLeft() {
        if GameData.playerSex == .girl {
            bitmap = bitmapUtil.player_girl_left02_bitmap
            walkBitmap01 = bitmapUtil.player_girl_left01_bitmap
            walkBitmap02 = bitmapUtil.player_girl_left02_bitmap
            walkBitmap03 = bitmapUtil.player_girl_left03_bitmap
            downBitmap = bitmapUtil.player_girl_down_left_bitmap
            injureBitmap = bitmapUtil.player_girl_injure_left_bitmap
        } else {
            bitmap = bitmapUtil.player_boy_left02_bitmap
            walkBitmap01 = bitmapUtil.player_boy_left01_bitmap
            walkBitmap02 = bitmapUtil.player_boy_left02_bitmap
            walkBitmap03 = bitmapUtil.player_boy_left03_bitmap
            downBitmap = bitmapUtil.player_boy_down_left_bitmap
            injureBitmap = bitmapUtil.player_boy_injure_left_bitmap
        }
        self.texture = bitmap
    }

    private func setPlayerBitmapRight() {
        if GameData.playerSex == .girl {
            bitmap = bitmapUtil.player_girl_right02_bitmap
            walkBitmap01 = bitmapUtil.player_girl_right01_bitmap
            walkBitmap02 = bitmapUtil.player_girl_right02_bitmap
            walkBitmap03 = bitmapUtil.player_girl_right03_bitmap
            downBitmap = bitmapUtil.player_girl_down_right_bitmap
            injureBitmap = bitmapUtil.player_girl_injure_right_bitmap
        } else {
            bitmap = bitmapUtil.player_boy_right02_bitmap
            walkBitmap01 = bitmapUtil.player_boy_right01_bitmap
            walkBitmap02 = bitmapUtil.player_boy_right02_bitmap
            walkBitmap03 = bitmapUtil.player_boy_right03_bitmap
            downBitmap = bitmapUtil.player_boy_down_right_bitmap
            injureBitmap = bitmapUtil.player_boy_injure_right_bitmap
        }
        self.texture = bitmap
    }

    // MARK: - Getters & Setters

    func getX() -> CGFloat { return x }
    func getY() -> CGFloat { return y }
    func getHeight() -> CGFloat { return height }
    func getWidth() -> CGFloat { return width }

    func setX(_ inputX: CGFloat) {
        x = inputX
        self.position = CGPoint(x: x, y: self.position.y)
    }

    func setY(_ inputY: CGFloat) {
        y = inputY
        self.position = CGPoint(x: self.position.x, y: y)
    }
}
