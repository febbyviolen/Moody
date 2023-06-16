//
//  AddStickerViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/16.
//

import UIKit
import KTCenterFlowLayout

class AddStickerViewController: UIViewController {
    
    @IBOutlet weak var pullDownButton: UIButton!
    @IBOutlet weak var diary: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var clockTabBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionViewSetup()
        textViewSetup()
        setupPlaceholder()
        setup()
    }
}

extension AddStickerViewController: UITextViewDelegate {
    private func setup() {
        dateLabel.text = Date().description
        clockTabBarButton.target = self
        clockTabBarButton.action = #selector(addTime)
        
        pullDownButton.showsMenuAsPrimaryAction = true
        pullDownButton.menu = addMenuItems()
    }
    
    private func textViewSetup(){
        diary.delegate = self
        let padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        diary.textContainerInset = padding
    }
    
    private func collectionViewSetup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 4 
        
        collectionView.collectionViewLayout = layout
    }
    
    private func setupPlaceholder() {
        let placeholderText = "오늘 하루를 기록해보세요"
        let placeholderColor = UIColor.lightGray
        
        diary.text = placeholderText
        diary.textColor = placeholderColor
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setupPlaceholder()
        }
    }
    
    @objc func addTime(){
        if diary.textColor == UIColor.lightGray {
            diary.textColor = UIColor.black
            diary.text = "오후 2시 "
        }
        else { diary.text += "오후 2시 " }
    }
    
    private func addMenuItems() -> UIMenu {
        let deleteTitle = NSAttributedString(string: "삭제", attributes: [.foregroundColor: UIColor.red])
        let deleteAction = UIAction(title: "", image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal), handler: { (_) in
            // Delete action handler
        })
        deleteAction.setValue(deleteTitle, forKey: "attributedTitle")
        
        let menuItems = UIMenu(title: "", options: .displayInline, children: [
            UIAction(title: "수정", image: UIImage(systemName: "pencil"), handler: { (_) in
                //
            }),
            deleteAction
        ])
        
        return menuItems
    }
}

extension AddStickerViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        return CGSize(width: 60, height: 70)
    }
    
}
