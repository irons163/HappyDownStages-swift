//
//  GameOverViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import UIKit

final class GameOverViewController: UIViewController, UITextFieldDelegate {
    
    weak var gameDelegate: GameDelegate?
    
    @IBOutlet private weak var titleImageView: UIImageView!
    @IBOutlet weak var gameOverTitleLabel: UILabel!
    @IBOutlet weak var gameScoreLabel: UILabel!
    @IBOutlet weak var nameEditView: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    private var gameScore: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameScoreLabel.text = "\(gameScore)"
        gameScoreLabel.sizeToFit()
        nameEditView.delegate = self

        nameEditView.borderStyle = .roundedRect
        nameEditView.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        nameEditView.textColor = .darkText
        nameEditView.layer.cornerRadius = 8
        nameEditView.layer.masksToBounds = true

        submitButton.layer.cornerRadius = 8
        submitButton.layer.masksToBounds = true
        submitButton.layer.shadowColor = UIColor.black.cgColor
        submitButton.layer.shadowOpacity = 0.2
        submitButton.layer.shadowRadius = 4
        submitButton.layer.shadowOffset = CGSize(width: 0, height: 2)

        titleImageView.contentMode = .scaleAspectFit
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutGameOver()
    }
    
    func setScore(_ score: Int) {
        self.gameScore = score
    }
    
    @IBAction func goToMenu(_ sender: Any) {
        dismiss(animated: true) {
            self.gameDelegate?.goToMenu()
        }
    }
    
    @IBAction func sendScore(_ sender: Any) {
        guard let name = nameEditView.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            showAlert(message: NSLocalizedString("CannotNull", comment: ""))
            return
        }
        
        let manager = DatabaseManager.shared
        manager.insert(name: name, score: gameScore)
        
        gameOverTitleLabel.isHidden = true
        gameScoreLabel.isHidden = true
        nameEditView.isHidden = true
        submitButton.isHidden = true

        showAlert(message: "success")
    }
    
    @IBAction func restartClick(_ sender: Any) {
        dismiss(animated: true) {
            self.gameDelegate?.restart()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    private func layoutGameOver() {
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let contentWidth = min(safeFrame.width * 0.8, 300)

        gameOverTitleLabel.sizeToFit()
        gameScoreLabel.sizeToFit()

        let imageMaxWidth = min(safeFrame.width * 0.7, 320)
        let imageRatio = (titleImageView.image?.size.height ?? 1) / (titleImageView.image?.size.width ?? 1)
        let imageHeight = imageMaxWidth * imageRatio

        let scoreHeight = gameScoreLabel.bounds.height
        let fieldHeight: CGFloat = 44

        let actionButtons = findActionButtons()
        let actionSizes = actionButtons.map { sizeForButton($0, maxWidth: min(safeFrame.width * 0.3, 120)) }
        let actionRowHeight = actionSizes.map { $0.height }.max() ?? 0

        let submitSize = sizeForButton(submitButton, maxWidth: min(safeFrame.width * 0.7, 260))

        let totalHeight = imageHeight + 12 + actionRowHeight + 16 + scoreHeight + 20 + fieldHeight + 16 + submitSize.height
        let startY = safeFrame.midY - totalHeight / 2

        titleImageView.frame = CGRect(x: safeFrame.midX - imageMaxWidth / 2,
                                      y: startY,
                                      width: imageMaxWidth,
                                      height: imageHeight)

        layoutActionButtons(actionButtons, top: titleImageView.frame.maxY + 12, safeFrame: safeFrame)

        gameOverTitleLabel.isHidden = true

        gameScoreLabel.frame = CGRect(x: safeFrame.midX - contentWidth / 2,
                                      y: titleImageView.frame.maxY + 12 + actionRowHeight + 16,
                                      width: contentWidth,
                                      height: scoreHeight)
        gameScoreLabel.textAlignment = .center

        nameEditView.frame = CGRect(x: safeFrame.midX - contentWidth / 2,
                                    y: gameScoreLabel.frame.maxY + 20,
                                    width: contentWidth,
                                    height: fieldHeight)

        submitButton.bounds.size = submitSize
        submitButton.center = CGPoint(x: safeFrame.midX, y: nameEditView.frame.maxY + 16 + submitSize.height / 2)

        hideLegacyLabels()
    }

    private func allSubviews(of view: UIView) -> [UIView] {
        return view.subviews + view.subviews.flatMap { allSubviews(of: $0) }
    }

    private func hideLegacyLabels() {
        let labels = allSubviews(of: view).compactMap { $0 as? UILabel }
        let legacyTexts = ["score:", "name:", "leader board"]
        for label in labels where legacyTexts.contains(label.text?.lowercased() ?? "") {
            label.isHidden = true
        }
    }

    private func findActionButtons() -> [UIButton] {
        let buttons = allSubviews(of: view).compactMap { $0 as? UIButton }
        return buttons.filter { $0 !== submitButton }
    }

    private func layoutActionButtons(_ buttons: [UIButton], top: CGFloat, safeFrame: CGRect) {
        guard buttons.count > 0 else { return }
        let maxButtonWidth = min(safeFrame.width * 0.3, 120)
        let spacing: CGFloat = 12

        var sizes: [CGSize] = []
        for button in buttons {
            let size = sizeForButton(button, maxWidth: maxButtonWidth)
            sizes.append(size)
        }

        let totalWidth = sizes.reduce(0) { $0 + $1.width } + spacing * CGFloat(max(0, buttons.count - 1))
        var x = safeFrame.midX - totalWidth / 2
        for (index, button) in buttons.enumerated() {
            button.bounds.size = sizes[index]
            button.frame.origin = CGPoint(x: x, y: top)
            x += sizes[index].width + spacing
        }
    }

    private func sizeForButton(_ button: UIButton, maxWidth: CGFloat) -> CGSize {
        if let image = button.currentImage {
            let ratio = image.size.height / image.size.width
            return CGSize(width: maxWidth, height: maxWidth * ratio)
        }
        return CGSize(width: maxWidth, height: 44)
    }

    private func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "ok", style: .default))
        present(alertController, animated: true)
    }
}
