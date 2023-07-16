//
//  StickerCell.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/16.
//

import Foundation
import UIKit

protocol StickerCellDelegate: AnyObject {
    func deleteSticker(cell: StickerCell)
}

class StickerCell: UICollectionViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet var stickerImg: UIImageView!
    
    private var isWiggling = false
    var delegate: StickerCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the delete button
        deleteButton.isHidden = true
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        stickerImg.alpha = 1.0
        
        // Add long press gesture recognizer to the cell
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        addGestureRecognizer(longPressGesture)
    }
    
    // Handle the long press gesture
    @objc private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            // Show the delete button and overlay view
            deleteButton.isHidden = false
            stickerImg.alpha = 0.5
            
            // Perform the wiggle animation
            wiggleAnimation()
            isWiggling = true
        }
    }
    
    // Perform the wiggle animation
    private func wiggleAnimation() {
        let rotationAngle = CGFloat.pi / 180.0 * 5.0
        
        let wiggleAnimation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggleAnimation.values = [-rotationAngle, rotationAngle]
        wiggleAnimation.autoreverses = true
        wiggleAnimation.duration = 0.15
        wiggleAnimation.repeatCount = .infinity
        
        layer.add(wiggleAnimation, forKey: "wiggleAnimation")
    }
    
    // Stop the wiggle animation
    private func stopWiggleAnimation() {
        layer.removeAnimation(forKey: "wiggleAnimation")
    }
    
    // Handle delete button tapped
    @objc private func deleteButtonTapped() {
        delegate?.deleteSticker(cell: self)
        print("delete")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset the cell state
       resetState()
    }
    
    func resetState() {
        if isWiggling {
            stopWiggleAnimation()
            deleteButton.isHidden = true
            stickerImg.alpha = 1.0
            isWiggling = false
        }
    }
    
}

class StickerCell2: UICollectionViewCell {
    @IBOutlet var stickerImg: UIImageView!
}

//MARK: COMING SOON CELL
class comingSoonCell: UICollectionViewCell {
    @IBOutlet var label: UILabel!

}
