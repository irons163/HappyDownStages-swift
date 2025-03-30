//
//  ToolUtil.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit

class ToolUtil: SKSpriteNode {

    var isExploding: Bool = false

    private var toolX: CGFloat = 0
    private var toolY: CGFloat = 0
    private var toolWidth: Int = 30
    private var type: Int = 0

    private var eatTimer: Timer?
    private var bombExplodeTimer: Timer?
    private var isEatedFlag = false
    private var eatStep = 0

    func setToolUtil(x: CGFloat, y: CGFloat, type: Int) {
        let bitmapUtil = BitmapUtil.shared
        self.type = type

        switch type {
        case Footboard.BOMB:
            self.texture = bitmapUtil.tool_bomb_bitmap
        case Footboard.BOMB_EXPLODE:
            self.texture = bitmapUtil.tool_bomb_explosion_bitmap
            isExploding = true
            bombExplodeTimer?.invalidate()
            bombExplodeTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                self.isExploding = false
            }
        case Footboard.EAT_MAN_TREE:
            self.texture = bitmapUtil.toll_eat_man_tree2_bitmap
        default:
            self.texture = bitmapUtil.toll_cure_bitmap
        }

        toolX = x - CGFloat(toolWidth) / 2
        toolY = y

        self.size = CGSize(width: toolWidth, height: toolWidth)
        self.position = CGPoint(x: toolX, y: toolY)
        self.anchorPoint = CGPoint(x: 0, y: 0)
    }

    func draw(dy: CGFloat) {
        toolY += dy
        self.position = CGPoint(x: toolX, y: toolY)
    }

    func getToolX() -> CGFloat {
        return toolX
    }

    func getToolWidth() -> Int {
        return toolWidth
    }

    func doEat() {
        guard type == Footboard.EAT_MAN_TREE, eatTimer == nil else { return }

        eatTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            self.updateEatAnimation()
        }
    }

    private func updateEatAnimation() {
        let bitmapUtil = BitmapUtil.shared
        switch eatStep {
        case 0:
            self.texture = bitmapUtil.toll_eat_man_tree_bitmap
            eatStep += 1
        case 1:
            self.texture = bitmapUtil.toll_eat_man_tree3_bitmap
            isEatedFlag = true
            eatStep += 1
        default:
            self.texture = bitmapUtil.toll_eat_man_tree2_bitmap
            eatStep = 0
            isEatedFlag = false
            eatTimer?.invalidate()
            eatTimer = nil
        }
    }

    func isEated() -> Bool {
        if isEatedFlag {
            isEatedFlag = false
            return true
        }
        return false
    }
}
