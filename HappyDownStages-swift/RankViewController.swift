//
//  RankViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

final class RankViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var items: [Entity] = []
    private var manager: DatabaseManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RankTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHeader()
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

    private func layoutHeader() {
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        let labels = view.subviews.compactMap { $0 as? UILabel }
        let buttons = view.subviews.compactMap { $0 as? UIButton }
        if let background = view.subviews.compactMap({ $0 as? UIImageView }).first {
            background.frame = view.bounds
        }

        for label in labels {
            label.textColor = .white
            label.shadowColor = UIColor.black.withAlphaComponent(0.4)
            label.shadowOffset = CGSize(width: 0, height: 1)
        }

        if let titleLabel = labels.first(where: { $0.text?.lowercased().contains("leader") == true }) {
            titleLabel.frame = CGRect(x: safeFrame.minX, y: safeFrame.minY + 8, width: safeFrame.width, height: 24)
            titleLabel.textAlignment = .center
        }

        if let backButton = buttons.first(where: { $0.currentTitle == "Back" }) {
            backButton.frame.origin = CGPoint(x: safeFrame.minX + 8, y: safeFrame.minY + 6)
        }

        if let gcButton = buttons.first(where: { $0.currentImage != nil && $0.currentTitle == "Button" }) {
            gcButton.frame.origin = CGPoint(x: safeFrame.maxX - gcButton.frame.width - 8, y: safeFrame.minY + 4)
        }

        let columnY = safeFrame.minY + 44
        let columnWidth = safeFrame.width / 3
        let columnLabels = labels.filter { ["rank", "score", "name"].contains($0.text?.lowercased() ?? "") }
        for (index, label) in columnLabels.enumerated() {
            label.frame = CGRect(x: safeFrame.minX + columnWidth * CGFloat(index), y: columnY, width: columnWidth, height: 20)
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 16)
        }
    }
}
