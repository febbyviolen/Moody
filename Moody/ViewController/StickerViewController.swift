//
//  StickerViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/16.
//

import UIKit
import FirebaseFirestore

protocol StickerViewDelegate{
    func stickerTapped(controller: StickerViewController)
}

class StickerViewController: UIViewController {
    var delegate: StickerViewDelegate! = nil
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: PlainSegmentedControl!
    
    var moodSticker = Mood.allCases
    var lifeSticker = ["happy", "happy", "happy"]
    
    var showIndex = 0
    var selectedMoodSticker = ""
    
    let formatter = DateFormatter()
    var date = Date()
    var dateString : String {
        formatter.dateFormat = "yyyy.MM.dd EEEE"
        return formatter.string(from: date)
    }
    var monthString: String{
        formatter.dateFormat = "MM"
        return formatter.string(from: date)
    }
    
    let font = Font()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        setupFont()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = UICollectionViewFlowLayout()

    }
    
    @IBAction func segmentedControlAction(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            showIndex = 0
            collectionView.reloadData()
        case 1:
            showIndex = 1
            collectionView.reloadData()
        default:
            break
        }
    }
    
}

extension StickerViewController {
    func setupFont(){
        dateLabel.font = font.sub2Size
        titleLabel.font = font.title2Size
    }
    
    func setupUI(){
        dateLabel.text = dateString
        
        let attributes = [
            NSAttributedString.Key.font: font.sub2Size,
            NSAttributedString.Key.foregroundColor: UIColor.gray
        ]
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)

    }
}

extension StickerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch showIndex {
        case 0:
            selectedMoodSticker = moodSticker[indexPath.item].imgName
            // Do something with the selected mood sticker
            delegate.stickerTapped(controller: self)
            
            print("Selected mood sticker: \(selectedMoodSticker)")
        case 1:
            let selectedLifeSticker = lifeSticker[indexPath.item]
            // Do something with the selected life sticker
            print("Selected life sticker: \(selectedLifeSticker)")
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch showIndex {
        case 0:
            return moodSticker.count
        case 1:
            return lifeSticker.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerCell
        switch showIndex {
        case 0:
            cell.stickerImg.image = UIImage(named: moodSticker[indexPath.item].imgName) 
            
        case 1:
            let selectedLifeSticker = lifeSticker[indexPath.item]
            // Do something with the selected life sticker
            print("Selected life sticker: \(selectedLifeSticker)")
        default:
            break
        }
        
        cell.isSelected = (indexPath == collectionView.indexPathsForSelectedItems?.first)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        let itemSpacing: CGFloat = 5 // Adjust the item spacing as needed
        let availableWidth = collectionView.bounds.width - itemSpacing
        let cellWidth = availableWidth / 4 // Adjust the number of cells per row as needed
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0 // Adjust the line spacing as needed
    }
}


//MARK: CUSTOM UISEGMENTEDCONTROL
class PlainSegmentedControl: UISegmentedControl {
    
    let font = Font()
    
    override init(items: [Any]?) {
        super.init(items: items)

        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear

        // Use a clear image for the background and the dividers
        let tintColorImage = UIImage(color: UIColor.clear, size: CGSize(width: 1, height: 32))
        setBackgroundImage(tintColorImage, for: .normal, barMetrics: .default)
        setDividerImage(tintColorImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        // Set some default label colors
        setTitleTextAttributes([.foregroundColor: UIColor.gray, NSAttributedString.Key.font: font.subSize], for: .normal)
        
        setTitleTextAttributes([
            .foregroundColor: UIColor.black,
            .underlineStyle: NSUnderlineStyle.double.rawValue,
            .underlineColor: UIColor.gray,
            NSAttributedString.Key.font: font.subSize],
                               for: .selected)
    }
}

extension UIImage {
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.set()
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        self.init(data: image.pngData()!)!
    }
}
