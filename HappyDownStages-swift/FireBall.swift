//
//  FireBall.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit

class FireBall: SKSpriteNode {

    private var screenWidth: Int = 0
    private var whichForFireBall: Int = 0

    func setScreenWidth(_ width: Int) {
        self.screenWidth = width
        whichForFireBall = Int.random(in: 0..<3)

        let fireballX: CGFloat
        switch whichForFireBall {
        case 0:
            fireballX = CGFloat(width) / 6 * 1  // 1/6 處
        case 1:
            fireballX = CGFloat(width) / 6 * 3  // 1/2 處
        case 2:
            fireballX = CGFloat(width) / 6 * 5  // 5/6 處
        default:
            fireballX = CGFloat(width) / 2
        }

        self.position.x = fireballX
    }

    func moveDy(_ dy: CGFloat, dx: CGFloat) {
        let newX = self.position.x - dx
        let newY = self.position.y - dy
        self.position = CGPoint(x: newX, y: newY)
    }
}
