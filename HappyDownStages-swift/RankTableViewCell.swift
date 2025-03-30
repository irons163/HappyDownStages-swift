//
//  RankTableViewCell.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

class RankTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state if needed
    }
}
