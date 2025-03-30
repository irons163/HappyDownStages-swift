//
//  RankViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

class RankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [Entity] = []
    private var manager: DatabaseManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        loadData()
    }

    private func loadData() {
        manager = DatabaseManager.shared
        items = manager?.load() as? [Entity] ?? []
        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "Cell"

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? RankTableViewCell
            ?? RankTableViewCell(style: .default, reuseIdentifier: identifier)

        let item = items[indexPath.row]
        cell.rankLabel.text = "\(indexPath.row + 1)"
        cell.scoreLabel.text = item.score?.stringValue
        cell.nameLabel.text = item.name

        return cell
    }

    // MARK: - Actions

    @IBAction func rankClick(_ sender: Any) {
        showRankView()
    }

    @IBAction func backClick(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    private func showRankView() {
        let gameCenterUtil = GameCenterUtil.shared
        _ = gameCenterUtil.isGameCenterAvailable() // Call if needed
        gameCenterUtil.showGameCenter(from: self)
        gameCenterUtil.submitAllSavedScores()
    }
}
