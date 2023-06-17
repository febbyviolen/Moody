//
//  StickerCell.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/16.
//

import Foundation
import UIKit

class StickerCell: UICollectionViewCell {
    @IBOutlet var stickerImg: UIImageView!

}

class StickerCell2: UICollectionViewCell {
    @IBOutlet var stickerImg: UIImageView!
    
    override var isSelected: Bool{
        didSet{
            if isSelected {
                stickerImg.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } else {
                stickerImg.transform = CGAffineTransform.identity
            }
        }
    }

}
