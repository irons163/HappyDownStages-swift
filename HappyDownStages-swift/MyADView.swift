//
//  MyADView.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import SpriteKit
import UIKit

final class MyADView: SKSpriteNode {
    
    static func createMyADView() -> MyADView {
        return MyADView(color: .clear, size: AppConstants.Ads.defaultAdSize) // adjust size as needed
    }

    var adClickable: Bool = false
    
    private var ads: [SKTexture] = []
    private var adsUrl: [String] = []
    private var adIndex: Int = 0
    private var button: SKSpriteNode!
    private var enableHideButton: Bool = false
    
    func startAd() {
        adClickable = true

        let fallbackCatAdName = AppConstants.Ads.catAdNames.first ?? "unlimited_cat_world_ad"
        let catAdImageName = AppConstants.Ads.catAdNames.randomElement() ?? fallbackCatAdName

        ads = [
            SKTexture(imageNamed: AppConstants.Ads.imageNames[0]),
            SKTexture(imageNamed: NSLocalizedString(AppConstants.Ads.localizedCatShootKey, comment: "")),
            SKTexture(imageNamed: AppConstants.Ads.imageNames[1]),
            SKTexture(imageNamed: AppConstants.Ads.imageNames[2]),
            SKTexture(imageNamed: AppConstants.Ads.imageNames[3]),
            SKTexture(imageNamed: catAdImageName)
        ]

        adsUrl = AppConstants.Ads.urls

        adIndex = 0
        self.texture = ads[adIndex]

        Timer.scheduledTimer(timeInterval: AppConstants.Ads.changeInterval,
                             target: self,
                             selector: #selector(changeAd),
                             userInfo: nil,
                             repeats: true)

        button = SKSpriteNode(imageNamed: AppConstants.Ads.closeButtonImageName)
        button.size = AppConstants.Ads.closeButtonSize
        button.position = CGPoint(x: self.size.width / 2 - button.size.width, y: self.size.height - button.size.height)
        button.anchorPoint = CGPoint(x: 0, y: 0)
        button.zPosition = 5
        addChild(button)

        enableHideButton = false
        button.isHidden = !enableHideButton
    }

    @objc func changeAd() {
        adIndex = (adIndex + 1) % ads.count
        self.texture = ads[adIndex]
    }

    func doClick() {
        guard let url = URL(string: adsUrl[adIndex]) else { return }
        UIApplication.shared.open(url)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !self.isHidden else { return }
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        if enableHideButton && button.contains(location) {
            self.isHidden = true
        } else if adClickable && location.y > 0 {
            doClick()
        }
    }
}
