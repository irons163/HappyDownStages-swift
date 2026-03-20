//
//  GameLevelViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import UIKit

final class GameLevelViewController: UIViewController {

    @IBOutlet weak var girlCheckView: UIImageView!
    @IBOutlet weak var boyCheckView: UIImageView!
    private var girlButton: UIButton?
    private var boyButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        ensureGenderButtons()
        updateGenderUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutGenderButtons()
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

    private func ensureGenderButtons() {
        if girlButton == nil {
            let button = UIButton(type: .custom)
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(girlClick(_:)), for: .touchUpInside)
            view.addSubview(button)
            girlButton = button
        }
        if boyButton == nil {
            let button = UIButton(type: .custom)
            button.backgroundColor = .clear
            button.addTarget(self, action: #selector(boyClick(_:)), for: .touchUpInside)
            view.addSubview(button)
            boyButton = button
        }
    }

    private func layoutGenderButtons() {
        guard let girlButton = girlButton, let boyButton = boyButton else { return }

        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let baseY = safeFrame.minY + safeFrame.height * 0.38
        let selectionHeight = max(380, safeFrame.height * 0.42)
        let selectionWidth = max(200, safeFrame.width * 0.42)
        let leftCenterX = safeFrame.minX + safeFrame.width * 0.30
        let rightCenterX = safeFrame.minX + safeFrame.width * 0.73

        let girlFrame = selectionFrame(centerX: leftCenterX,
                                       y: baseY,
                                       width: selectionWidth,
                                       height: selectionHeight,
                                       in: safeFrame)
        let boyFrame = selectionFrame(centerX: rightCenterX,
                                      y: baseY,
                                      width: selectionWidth,
                                      height: selectionHeight,
                                      in: safeFrame)

        girlButton.frame = girlFrame
        boyButton.frame = boyFrame

        positionCheckView(girlCheckView, over: girlFrame, centerX: leftCenterX)
        positionCheckView(boyCheckView, over: boyFrame, centerX: rightCenterX)

        view.bringSubviewToFront(girlButton)
        view.bringSubviewToFront(boyButton)
        view.bringSubviewToFront(girlCheckView)
        view.bringSubviewToFront(boyCheckView)
    }

    private func selectionFrame(centerX: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, in bounds: CGRect) -> CGRect {
        var frame = CGRect(x: centerX - width / 2, y: y, width: width, height: height)
        if frame.minX < bounds.minX {
            frame.origin.x = bounds.minX
        }
        if frame.maxX > bounds.maxX {
            frame.origin.x = bounds.maxX - frame.width
        }
        if frame.minY < bounds.minY {
            frame.origin.y = bounds.minY
        }
        if frame.maxY > bounds.maxY {
            frame.origin.y = bounds.maxY - frame.height
        }
        return frame
    }

    private func positionCheckView(_ view: UIImageView, over frame: CGRect, centerX: CGFloat) {
        let y = frame.minY + view.bounds.height / 2 + 24
        view.center = CGPoint(x: centerX, y: y)
    }
}
