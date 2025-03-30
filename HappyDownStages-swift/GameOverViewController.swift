//
//  GameOverViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/3/30.
//

import UIKit

class GameOverViewController: UIViewController, UITextFieldDelegate {
    
    weak var gameDelegate: GameDelegate?
    
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
            let alert = UIAlertView(title: "", message: NSLocalizedString("CannotNull", comment: ""), delegate: nil, cancelButtonTitle: "ok")
            alert.show()
            return
        }
        
        let manager = DatabaseManager.shared
        manager.insert(name: name, score: gameScore)
        
        let alert = UIAlertView(title: "", message: "success", delegate: nil, cancelButtonTitle: "ok")
        
        gameOverTitleLabel.isHidden = true
        gameScoreLabel.isHidden = true
        nameEditView.isHidden = true
        submitButton.isHidden = true
        
        alert.show()
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
}

// Helper object to mimic UIAlertViewDelegate with a closure
class MyObject: NSObject, UIAlertViewDelegate {
    var okBlock: (() -> Void)?
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        okBlock?()
    }
}
