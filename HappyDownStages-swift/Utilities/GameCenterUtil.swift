//
//  GameCenterUtil.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import Foundation
import GameKit
import UIKit

protocol PauseGameDelegate: AnyObject {
    func pauseGame()
}

class GameCenterUtil: NSObject, GKGameCenterControllerDelegate {
    
    static let shared = GameCenterUtil()
    weak var delegate: PauseGameDelegate?
    
    private var gameCenterAvailable: Bool = false
    
    private override init() {
        super.init()
        gameCenterAvailable = isGameCenterAvailable()
        if gameCenterAvailable {
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(authenticationChanged),
                                                   name: .GKPlayerAuthenticationDidChangeNotificationName,
                                                   object: nil)
        }
    }
    
    func isGameCenterAvailable() -> Bool {
        let reqSysVer = "4.1"
        let currSysVer = UIDevice.current.systemVersion
        let osVersionSupported = currSysVer.compare(reqSysVer, options: .numeric) != .orderedAscending
        return (NSClassFromString("GKLocalPlayer") != nil && osVersionSupported)
    }
    
    func authenticateLocalUser(from viewController: UIViewController) {
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { [weak self] authViewController, error in
            if let error = error {
                print("GameCenter Error: \(error.localizedDescription)")
            }
            if let authVC = authViewController {
                viewController.present(authVC, animated: true) {
                    self?.delegate?.pauseGame()
                }
            } else if localPlayer.isAuthenticated {
                localPlayer.loadDefaultLeaderboardIdentifier { leaderboardID, error in
                    if let error = error {
                        print("Load leaderboard ID error: \(error.localizedDescription)")
                    } else {
                        print("Authenticated successfully")
                    }
                }
            } else {
                print("Player not authenticated")
            }
        }
    }
    
    @objc func authenticationChanged() {
        if GKLocalPlayer.local.isAuthenticated {
            print("Authentication changed: player authenticated.")
        } else {
            print("Authentication changed: player not authenticated")
        }
    }
    
    func reportScore(_ score: Int64, forCategory category: String) {
        let scoreReporter = GKScore(leaderboardIdentifier: category)
        scoreReporter.value = score
        
        GKScore.report([scoreReporter]) { error in
            if let error = error {
                print("Score report error: \(error.localizedDescription)")
                do {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false)
                    self.storeScoreForLater(data)
                } catch {
                    print("Archiving score failed: \(error)")
                }
            } else {
                print("Score submitted successfully.")
            }
        }
    }
    
    private func storeScoreForLater(_ scoreData: Data) {
        var savedScores = UserDefaults.standard.array(forKey: "savedScores") as? [Data] ?? []
        savedScores.append(scoreData)
        UserDefaults.standard.set(savedScores, forKey: "savedScores")
    }
    
    func submitAllSavedScores() {
        guard var savedScores = UserDefaults.standard.array(forKey: "savedScores") as? [Data] else { return }
        UserDefaults.standard.removeObject(forKey: "savedScores")
        
        for scoreData in savedScores {
            if let scoreReporter = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(scoreData) as? GKScore {
                GKScore.report([scoreReporter]) { error in
                    if let error = error {
                        print("Resubmit error: \(error.localizedDescription)")
                        if let retryData = try? NSKeyedArchiver.archivedData(withRootObject: scoreReporter, requiringSecureCoding: false) {
                            self.storeScoreForLater(retryData)
                        }
                    } else {
                        print("Score resubmitted successfully.")
                    }
                }
            }
        }
    }
    
    func showGameCenter(from viewController: UIViewController) {
        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.leaderboardIdentifier = "com.xxxx.test"
        gcViewController.leaderboardTimeScope = .allTime
        
        viewController.present(gcViewController, animated: true) {
            self.delegate?.pauseGame()
        }
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
