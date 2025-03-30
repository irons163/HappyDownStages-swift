//
//  GameLevelViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import UIKit

class GameLevelViewController: UIViewController {

    @IBOutlet weak var girlCheckView: UIImageView!
    @IBOutlet weak var boyCheckView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateGenderUI()
    }

    @IBAction func girlClick(_ sender: Any) {
        GameData.playerSex = .girl
        updateGenderUI()
    }

    @IBAction func boyClick(_ sender: Any) {
        GameData.playerSex = .boy
        updateGenderUI()
    }

    @IBAction func playClick(_ sender: Any) {
        if let viewController = storyboard?.instantiateViewController(withIdentifier: "ViewController") {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    private func updateGenderUI() {
        girlCheckView.isHidden = GameData.playerSex != .girl
        boyCheckView.isHidden = GameData.playerSex != .boy
    }
}
