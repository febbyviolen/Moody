//
//  AddStickerViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/16.
//

import UIKit
import KTCenterFlowLayout

class DiaryDetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var pullDownButton: UIButton!
    @IBOutlet weak var diary: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var clockTabBarButton: UIBarButtonItem!
    
    let formatter = DateFormatter()
    let font = Font()
    var date = Date()
    var dateString : String {
        formatter.dateFormat = "yyyy.MM.dd EEEE"
        return formatter.string(from: date)
    }
    
    var sticker: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionViewSetup()
        textViewSetup()
        setupPlaceholder()
        setup()
        fontSetup()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        performSegue(withIdentifier: "showSticker", sender: self)
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSticker" {
            if let VC = segue.destination as? StickerViewController {
                VC.date = date
            }
        }
    }
    
}

extension DiaryDetailViewController: UITextViewDelegate {
    //swipe back
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func fontSetup() {
        dateLabel.font = font.dateSize
        diary.font = font.subSize
    }

    private func setup() {
        dateLabel.text = dateString
        clockTabBarButton.target = self
        clockTabBarButton.action = #selector(addTime)
        
        pullDownButton.showsMenuAsPrimaryAction = true
        pullDownButton.menu = addMenuItems()
        
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func textViewSetup(){
        diary.delegate = self
        let padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        diary.textContainerInset = padding
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Resign first responder status of the text view when tapped outside
        if !diary.bounds.contains(gestureRecognizer.location(in: diary)) {
            diary.resignFirstResponder()
        }
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
    
    
    //MENU
    private func addMenuItems() -> UIMenu {
        //deleteAction
        let deleteTitle = NSAttributedString(string: "삭제", attributes: [.foregroundColor: UIColor.red, .font: font.subSize])
        let deleteAction = UIAction(title: "", image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal), handler: { (_) in
            // Delete action handler
        })
        deleteAction.setValue(deleteTitle, forKey: "attributedTitle")
        
        //shareAction
        let shareTitle = NSAttributedString(string: "공유", attributes: [.foregroundColor: UIColor.black, .font: font.subSize])
        let shareAction = UIAction(title: "공유", image: UIImage(systemName: "square.and.arrow.up"), handler: { (_) in
            // Action action handler
        })
        shareAction.setValue(shareTitle, forKey: "attributedTitle")
        
        //menu items
        let menuItems = UIMenu(title: "", options: .displayInline, children: [
            shareAction,
            deleteAction
        ])
        
        return menuItems
    }
}

//MARK: UICOLLECTIONVIEW
extension DiaryDetailViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sticker.count == 0 ? 1 : sticker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerCell
        
        if sticker.count == 0 {
            cell.stickerImg.image = UIImage(systemName: "plus.circle.fill")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
            cell.stickerImg.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } else {
            cell.stickerImg.image = UIImage(named: sticker[indexPath.item])
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        return CGSize(width: 60, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSticker", sender: self)
    }
    
}
