//
//  RankTableViewCell.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

final class RankTableViewCell: UITableViewCell {
    
    @IBOutlet private var rankLabel: UILabel!
    @IBOutlet private var scoreLabel: UILabel!
    @IBOutlet private var nameLabel: UILabel!
    private let backgroundImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupProgrammaticViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureAppearance()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundImageView.frame = contentView.bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true

        let width = contentView.bounds.width
        let height = contentView.bounds.height
        let columnWidth = width / 3

        rankLabel?.frame = CGRect(x: 0, y: 0, width: columnWidth, height: height)
        scoreLabel?.frame = CGRect(x: columnWidth, y: 0, width: columnWidth, height: height)
        nameLabel?.frame = CGRect(x: columnWidth * 2, y: 0, width: columnWidth, height: height)

        rankLabel?.textAlignment = .center
        scoreLabel?.textAlignment = .center
        nameLabel?.textAlignment = .center
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state if needed
    }

    private func setupProgrammaticViews() {
        if backgroundImageView.superview == nil {
            backgroundImageView.image = UIImage(named: "rank_bot.png")
            contentView.addSubview(backgroundImageView)
        }

        if rankLabel == nil {
            rankLabel = UILabel()
            contentView.addSubview(rankLabel)
        }
        if scoreLabel == nil {
            scoreLabel = UILabel()
            contentView.addSubview(scoreLabel)
        }
        if nameLabel == nil {
            nameLabel = UILabel()
            contentView.addSubview(nameLabel)
        }
        configureAppearance()
    }

    private func configureAppearance() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none
        [rankLabel, scoreLabel, nameLabel].forEach { label in
            label?.textColor = .white
            label?.shadowColor = UIColor.black.withAlphaComponent(0.45)
            label?.shadowOffset = CGSize(width: 0, height: 1)
        }
    }
}
