//
//  MainMenuViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

final class MainMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        styleMenuButtons()

        let gameCenterUtil = GameCenterUtil.shared
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.authenticateLocalUser(from: self)
        gameCenterUtil.submitAllSavedScores()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutMenu()
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

    private func styleMenuButtons() {
        let buttons = view.subviews.compactMap { $0 as? UIButton }
        for button in buttons {
            button.adjustsImageWhenHighlighted = true
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 6
            button.layer.shadowOffset = CGSize(width: 0, height: 3)
        }
    }

    private func layoutMenu() {
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let imageViews = view.subviews.compactMap { $0 as? UIImageView }
        if let background = imageViews.first {
            background.frame = view.bounds
        }

        let buttons = view.subviews.compactMap { $0 as? UIButton }
        let sortedButtons = buttons.sorted { $0.frame.minY < $1.frame.minY }
        guard sortedButtons.count >= 2 else { return }

        let primaryButton = sortedButtons[0]
        let secondaryButton = sortedButtons[1]

        let maxButtonWidth = min(safeFrame.width * 0.7, 260)
        if let image = primaryButton.currentImage {
            let ratio = image.size.height / image.size.width
            primaryButton.bounds.size = CGSize(width: maxButtonWidth, height: maxButtonWidth * ratio)
        }
        if let image = secondaryButton.currentImage {
            let ratio = image.size.height / image.size.width
            secondaryButton.bounds.size = CGSize(width: maxButtonWidth * 0.85, height: maxButtonWidth * 0.85 * ratio)
        }

        let totalHeight = primaryButton.bounds.height + secondaryButton.bounds.height + 24
        let startY = safeFrame.midY - totalHeight / 2

        primaryButton.center = CGPoint(x: safeFrame.midX, y: startY + primaryButton.bounds.height / 2)
        secondaryButton.center = CGPoint(x: safeFrame.midX, y: primaryButton.frame.maxY + 24 + secondaryButton.bounds.height / 2)
    }
}
