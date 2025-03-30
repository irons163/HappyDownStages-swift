//
//  GameLevelCollectionViewController.swift
//  HappyDownStages-swift
//
//  Created by Phil on 2025/4/1.
//

import UIKit

class GameLevelCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if needed
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MyScene.infinityLevel + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "Cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

        if let photoImageView = cell.viewWithTag(100) as? UIImageView {
            photoImageView.image = BitmapUtil.shared.getNumberImage((indexPath.item + 1) / 10)
        }

        if let photoImageView2 = cell.viewWithTag(200) as? UIImageView {
            photoImageView2.image = BitmapUtil.shared.getNumberImage((indexPath.item + 1) % 10)
        }

        if let photoImageView3 = cell.viewWithTag(300) as? UIImageView {
            let maxLevel = UserDefaults.standard.integer(forKey: "level")
            photoImageView3.isHidden = indexPath.item <= maxLevel
        }

        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let gameLevelVC = storyboard?.instantiateViewController(withIdentifier: "GameLevelViewController") as? GameLevelViewController {
            let willPlayLevel = indexPath.item
            UserDefaults.standard.set(willPlayLevel, forKey: "willPlaylevel")
            UserDefaults.standard.synchronize()

            navigationController?.pushViewController(gameLevelVC, animated: true)
        }
    }
}
