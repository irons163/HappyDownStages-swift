//
//  WinDialogViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import UIKit

final class WinDialogViewController: UIViewController {

    weak var gameDelegate: GameDelegate?
    var level: Int = 0

    @IBOutlet weak var goToMenuBtn: UIButton!
    @IBOutlet weak var goToNextLevel: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutWinDialog()
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

    private func styleButtons() {
        let buttons = [goToMenuBtn, goToNextLevel].compactMap { $0 }
        for button in buttons {
            button.adjustsImageWhenHighlighted = true
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 6
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
    }

    private func layoutWinDialog() {
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let buttons = [goToMenuBtn, goToNextLevel].compactMap { $0 }
        guard buttons.count == 2 else { return }

        let maxButtonWidth = min(safeFrame.width * 0.4, 180)
        for button in buttons {
            if let image = button.currentImage {
                let ratio = image.size.height / image.size.width
                button.bounds.size = CGSize(width: maxButtonWidth, height: maxButtonWidth * ratio)
            }
        }

        let spacing: CGFloat = 16
        let totalWidth = buttons[0].bounds.width + buttons[1].bounds.width + spacing
        let startX = safeFrame.midX - totalWidth / 2
        let yPos = safeFrame.midY + 40

        buttons[0].frame.origin = CGPoint(x: startX, y: yPos)
        buttons[1].frame.origin = CGPoint(x: startX + buttons[0].bounds.width + spacing, y: yPos)

        if let winImage = view.subviews.compactMap({ $0 as? UIImageView }).first {
            let maxWidth = min(safeFrame.width * 0.7, winImage.image?.size.width ?? safeFrame.width * 0.7)
            let ratio = (winImage.image?.size.height ?? 1) / (winImage.image?.size.width ?? 1)
            winImage.bounds.size = CGSize(width: maxWidth, height: maxWidth * ratio)
            winImage.center = CGPoint(x: safeFrame.midX, y: yPos - winImage.bounds.height / 2 - 24)
        }
    }
}
