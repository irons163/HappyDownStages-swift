//
//  AppConstants.swift
//  HappyDownStages-swift
//
//  Created by Codex on 2025/04/01
//

import Foundation
import CoreGraphics

enum AppConstants {

    enum UserDefaultsKey {
        static let launchCount = "launchCount"
        static let level = "level"
        static let willPlayLevel = "willPlaylevel"
        static let savedScores = "savedScores"
    }

    enum Leaderboard {
        static let reportId = "com.irons.HappyDownStages"
        static let displayId = "com.xxxx.test"
    }

    enum Ads {
        static let changeInterval: TimeInterval = 2.0
        static let closeButtonSize = CGSize(width: 30, height: 30)
        static let closeButtonImageName = "btn_Close-hd"
        static let defaultAdSize = CGSize(width: 300, height: 250)
        static let catAdNames = ["unlimited_cat_world_ad", "UnlimitedCatWorld_ad"]
        static let localizedCatShootKey = "cat_shoot_ad"
        static let imageNames = [
            "ad1.jpg",
            "2048_ad",
            "Shoot_Learning_ad",
            "cute_dudge_ad"
        ]
        static let urls = [
            "http://itunes.apple.com/us/app/good-sleeper-counting-sheep/id998186214?l=zh&ls=1&mt=8",
            "http://itunes.apple.com/us/app/attack-on-giant-cat/id1000152033?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/2048-chinese-zodiac/id1024333772?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/shoot-learning-math/id1025414483?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/cute-dodge/id1018590182?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/unlimited-cat-world/id1000573724?l=zh&ls=1&mt=8"
        ]
    }
}
