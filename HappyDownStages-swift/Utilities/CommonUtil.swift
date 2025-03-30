//
//  CommonUtil.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import SpriteKit

class CommonUtil: SKSpriteNode {

    static let shared = CommonUtil()

    var SLIDERSPEED: CGFloat = 0.0

    private init() {
        super.init(texture: nil, color: .clear, size: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
