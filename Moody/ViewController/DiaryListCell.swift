//
//  DiaryListCell.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/22.
//

import Foundation
import UIKit
import KTCenterFlowLayout

class DiaryListCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var storyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var view: UIView!
    var item = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 8
        
        collectionView.collectionViewLayout = layout
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        view.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10))
        view.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return item.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerCell
        
        cell.stickerImg.image = UIImage(named: item[indexPath.item])
        cell.stickerImg.isHidden = false
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        return CGSize(width: 60, height: 70)
    }

}
