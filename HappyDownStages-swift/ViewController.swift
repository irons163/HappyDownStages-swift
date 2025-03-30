//
//  ViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/29.
//

import UIKit
import SpriteKit

protocol GameDelegate: AnyObject {
    func showWinDialog()
    func showLoseDialog(score: Int)
    func goToMenu()
    func goToNextLevel()
    func restart()
}

class ViewController: UIViewController, GameDelegate {

    var winDialogViewController: WinDialogViewController?
    var level: Int = 0
    var scene: MyScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }
        skView.showsFPS = true
        skView.showsNodeCount = true

        let willPlayLevel = UserDefaults.standard.integer(forKey: "willPlaylevel")
        level = willPlayLevel

        let background = TextureHelper.backgrounds()[willPlayLevel]
        scene = MyScene(size: skView.bounds.size, background: background, height: skView.bounds.height, width: skView.bounds.width, level: willPlayLevel)
        scene?.scaleMode = .aspectFill
        scene?.gameDelegate = self

        skView.showsFPS = false
        skView.showsNodeCount = false
        if let scene = scene {
            skView.presentScene(scene)
        }
    }

    func showWinDialog() {
        guard let winDialogVC = storyboard?.instantiateViewController(withIdentifier: "WinDialogViewController") as? WinDialogViewController else { return }
        winDialogVC.gameDelegate = self
        winDialogVC.modalPresentationStyle = .overCurrentContext
        winDialogVC.view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)

        self.navigationController?.providesPresentationContextTransitionStyle = true
        self.navigationController?.definesPresentationContext = true
        self.navigationController?.present(winDialogVC, animated: true, completion: nil)

        winDialogViewController = winDialogVC
    }

    func showLoseDialog(score: Int) {
        guard let gameOverVC = storyboard?.instantiateViewController(withIdentifier: "GameOverViewController") as? GameOverViewController else { return }
        gameOverVC.gameDelegate = self
        gameOverVC.setScore(score)
        gameOverVC.modalPresentationStyle = .overCurrentContext
        gameOverVC.view.backgroundColor = UIColor(white: 1.0, alpha: 0.5)

        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.navigationController?.present(gameOverVC, animated: true, completion: nil)
    }

    func goToMenu() {
        if winDialogViewController != nil {
            winDialogViewController?.dismiss(animated: true, completion: nil)
        }
        navigationController?.popToRootViewController(animated: true)
    }

    func goToNextLevel() {
        guard let skView = self.view as? SKView else { return }

        let nextBackground: SKTexture?
        if level + 1 <= MyScene.infinityLevel {
            nextBackground = TextureHelper.backgrounds()[level + 1]
        } else {
            nextBackground = nil
        }

        if let background = nextBackground {
            scene = MyScene(size: skView.bounds.size, background: background, height: skView.bounds.height, width: skView.bounds.width, level: level + 1)
            scene?.scaleMode = .aspectFill
            scene?.gameDelegate = self

            skView.showsFPS = false
            skView.showsNodeCount = false
            if let scene = scene {
                skView.presentScene(scene)
            }
        }

        winDialogViewController?.dismiss(animated: true, completion: nil)
        level += 1
    }

    func restart() {
        level -= 1
        goToNextLevel()
    }

    func getRandomBgResId() -> String? {
        return scene?.getRandomBgResId()
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
}
