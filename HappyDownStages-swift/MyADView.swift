//
//  MyADView.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import SpriteKit
import UIKit

class MyADView: SKSpriteNode {
    
    static func createMyADView() -> MyADView {
        return MyADView(color: .clear, size: CGSize(width: 300, height: 250)) // adjust size as needed
    }

    var adClickable: Bool = false
    
    private var ads: [SKTexture] = []
    private var adsUrl: [String] = []
    private var adIndex: Int = 0
    private var button: SKSpriteNode!
    private var enableHideButton: Bool = false
    
    func startAd() {
        adClickable = true

        let catAdImageName = Bool.random() ? "unlimited_cat_world_ad" : "UnlimitedCatWorld_ad"
        
        ads = [
            SKTexture(imageNamed: "ad1.jpg"),
            SKTexture(imageNamed: NSLocalizedString("cat_shoot_ad", comment: "")),
            SKTexture(imageNamed: "2048_ad"),
            SKTexture(imageNamed: "Shoot_Learning_ad"),
            SKTexture(imageNamed: "cute_dudge_ad"),
            SKTexture(imageNamed: catAdImageName)
        ]
        
        adsUrl = [
            "http://itunes.apple.com/us/app/good-sleeper-counting-sheep/id998186214?l=zh&ls=1&mt=8",
            "http://itunes.apple.com/us/app/attack-on-giant-cat/id1000152033?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/2048-chinese-zodiac/id1024333772?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/shoot-learning-math/id1025414483?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/cute-dodge/id1018590182?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/unlimited-cat-world/id1000573724?l=zh&ls=1&mt=8"
        ]
        
        adIndex = 0
        self.texture = ads[adIndex]
        
        Timer.scheduledTimer(timeInterval: 2.0,
                             target: self,
                             selector: #selector(changeAd),
                             userInfo: nil,
                             repeats: true)

        button = SKSpriteNode(imageNamed: "btn_Close-hd")
        button.size = CGSize(width: 30, height: 30)
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
