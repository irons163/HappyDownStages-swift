//
//  MainMenuViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let gameCenterUtil = GameCenterUtil.shared
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.authenticateLocalUser(from: self)
        gameCenterUtil.submitAllSavedScores()
    }

    @IBAction func startGameClick(_ sender: Any) {
        if let gameLevelVC = storyboard?.instantiateViewController(withIdentifier: "GameLevelCollectionViewController") as? GameLevelCollectionViewController {
            navigationController?.pushViewController(gameLevelVC, animated: true)
        }
    }

    @IBAction func rankClick(_ sender: Any) {
        if let rankVC = storyboard?.instantiateViewController(withIdentifier: "RankViewController") as? RankViewController {
            navigationController?.pushViewController(rankVC, animated: true)
        }
    }
}
