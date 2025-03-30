//
//  WinDialogViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import UIKit

class WinDialogViewController: UIViewController {

    weak var gameDelegate: GameDelegate?
    var level: Int = 0

    @IBOutlet weak var goToMenuBtn: UIButton!
    @IBOutlet weak var goToNextLevel: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goToMenuClick(_ sender: Any) {
        gameDelegate?.goToMenu()
    }

    @IBAction func goToNextLevelClick(_ sender: Any) {
        gameDelegate?.goToNextLevel()
    }
}
