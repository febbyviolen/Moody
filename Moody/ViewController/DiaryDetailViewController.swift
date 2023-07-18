//
//  AddStickerViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/16.
//

import UIKit
import KTCenterFlowLayout
import WidgetKit


protocol DiaryDetailDelegate {
    func diaryAdded(controller: DiaryDetailViewController)
    func diaryDeleted(controller: DiaryDetailViewController)
}

class DiaryDetailViewController: UIViewController, UIGestureRecognizerDelegate, StickerViewDelegate, StickerCellDelegate {
    
    //MARK: DELEGATE
    func deleteSticker(cell: StickerCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            print(indexPath)
            collectionView.performBatchUpdates({
                // Perform any additional deletion logic if needed
                collectionView.deleteItems(at: [indexPath])
                self.sticker.remove(at: indexPath.item)
                if sticker.count == 0 {
                    collectionView.isHidden = true
                } else {
                    collectionView.reloadData()
                }
            }, completion: nil)
        }
    }
    
    func stickerTapped(controller: StickerViewController) {
        if sticker.count < 5 {
            sticker.append(controller.selectedMoodSticker)
        } else if sticker.count == 5 {
            addStickerButton.isHidden = true 
        }
        collectionView.isHidden = false
        controller.dismiss(animated: true)
        collectionView.reloadData()
    }
    
    
    //MARK: PROPERTY
    @IBOutlet weak var addStickerButton: UIButton!
    @IBOutlet weak var pullDownButton: UIButton!
    @IBOutlet weak var diary: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var clockTabBarButton: UIBarButtonItem!
    
    var comeFromVC: String!
    var delegate : DiaryDetailDelegate! = nil
    let fb = Firebase()
    let formatter = DateFormatter()
    let font = Font()
    var date = Date()
    var selectedIndex: IndexPath?
    
    //=== DATE FORMATTER ===
    var dateString : String {
        formatter.dateFormat = "yyyy.MM.dd EEEE"
        return formatter.string(from: date)
    }
    
    var deleteButtonAction: (() -> Void)?
    
    var sticker: [String] = []
    var story = ""
    
    
    //MARK: LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        if sticker.isEmpty {
            performSegue(withIdentifier: "showSticker", sender: self)
        }
        if sticker.count >= 5 {
            addStickerButton.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionViewSetup()
        textViewSetup()
        setupPlaceholder()
        setup()
        fontSetup()
        setupTapGestureRecognizer()
        keyboardToolBar()
        
        //swipe back function
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSticker" {
            if let VC = segue.destination as? StickerViewController {
                VC.date = date
                VC.delegate = self
            }
        }
    }
    
    //when back swiped, perform back button action
    //returning false from this method ensures that the default swipe back gesture is canceled, and the action is perform instead
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == navigationController?.interactivePopGestureRecognizer {
            backButton(self)
            return false
        }
        return true
    }


    //MARK: BUTTON
    @IBAction func backButton(_ sender: Any) {
        guard let NC = navigationController?.viewControllers else {return}
        
        if let _ = NC[NC.count - 2] as? ViewController{
            if sticker.isEmpty && (diary.text == String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) || diary.text == "") {
                
                let ud = UserDefaults(suiteName: "group.widgetcache")
                ud?.setValue(sticker.last ?? "" , forKey: "img")
                
                self.fb.deleteDiary(date: self.date)
                self.delegate.diaryDeleted(controller: self)
            }
            
            if !sticker.isEmpty {
                if diary.text == String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) {
                    fb.addDiary(date: date, sticker: sticker, story: "")
                    
                    let ud = UserDefaults(suiteName: "group.widgetcache")
                    ud?.setValue(sticker.last, forKey: "img")
                    WidgetCenter.shared.reloadAllTimelines()
                } else {
                    fb.addDiary(date: date, sticker: sticker, story: diary.text)
                    
                    let ud = UserDefaults(suiteName: "group.widgetcache")
                    ud?.setValue(sticker.last, forKey: "img")
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                delegate.diaryAdded(controller: self)
            } else if (diary.text != String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) || diary.text != "") {
                fb.addDiary(date: date, sticker: [], story: diary.text)
            }
            
            navigationController?.popViewController(animated: true)
        }
        
        if let _ = NC[NC.count - 2] as? DiaryListViewController {
            if sticker.isEmpty && (diary.text == String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) || diary.text == "") {
                
                let ud = UserDefaults(suiteName: "group.widgetcache")
                ud?.setValue(sticker.last ?? "" , forKey: "img")
                
                self.fb.deleteDiary(date: self.date)
                self.delegate.diaryDeleted(controller: self)
            }
            
            if !sticker.isEmpty {
                if diary.text == String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) {
                    fb.addDiary(date: date, sticker: sticker, story: "")
                    
                    let ud = UserDefaults(suiteName: "group.widgetcache")
                    ud?.setValue(sticker.last, forKey: "img")
                    WidgetCenter.shared.reloadAllTimelines()
                } else {
                    fb.addDiary(date: date, sticker: sticker, story: diary.text)
                    
                    let ud = UserDefaults(suiteName: "group.widgetcache")
                    ud?.setValue(sticker.last, forKey: "img")
                    WidgetCenter.shared.reloadAllTimelines()
                }
                
                delegate.diaryAdded(controller: self)
            } else if (diary.text != String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) || diary.text != "") {
                fb.addDiary(date: date, sticker: [], story: diary.text)
            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addSticker(_ sender: Any) {  
        performSegue(withIdentifier: "showSticker", sender: self)
    }
}

extension DiaryDetailViewController: UITextViewDelegate {
    
    //MARK: FROM NOTIFICATION
    func fromNotification() {
        self.navigationController?.navigationBar.isHidden = false
        performSegue(withIdentifier: "showSticker", sender: self)
    }
    
    
    //MARK: SETUP
    private func fontSetup() {
        dateLabel.font = font.dateSize
        diary.font = font.subSize
    }

    private func setup() {
        dateLabel.text = dateString
        if story == "" {
            setupPlaceholder()
        } else {
            diary.textColor = UIColor(named: "black")
            diary.text = story
        }
        clockTabBarButton.target = self
        clockTabBarButton.action = #selector(addTime)
        
        pullDownButton.showsMenuAsPrimaryAction = true
        pullDownButton.menu = addMenuItems()
        
        navigationController?.navigationBar.tintColor = UIColor(named: "black")
    }
    
    private func keyboardToolBar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        
        let addTimeButton = UIBarButtonItem(title: "", image: UIImage(systemName: "clock"), target: self, action: #selector(addTime))
        addTimeButton.tintColor = UIColor(named: "black")
        
        let doneButton = UIBarButtonItem(title: String(NSLocalizedString("done.writting", comment: "")), style: .done, target: self, action: #selector(didTapDone))
        doneButton.tintColor = UIColor(named: "black")
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        toolbar.items = [addTimeButton, flexibleSpace, doneButton]
        toolbar.sizeToFit()
        diary.inputAccessoryView = toolbar
        
    }
    
    @objc private func didTapDone(){
        diary.resignFirstResponder()
        resetCellStates()
    }

    //=== BAR ITEM FUNC ===
    @objc private func addTime(){
        formatter.timeStyle = .short
        if diary.textColor == UIColor.lightGray {
            diary.textColor = UIColor(named: "black")
            diary.text = formatter.string(from: Date())
        }
        else { diary.text += formatter.string(from: Date()) }
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Resign first responder status of the text view when tapped outside
        if !diary.bounds.contains(gestureRecognizer.location(in: diary)) {
            diary.resignFirstResponder()
            resetCellStates()
        }
        resetCellStates()
    }
     
    //MARK: DIARY SETUP
    private func textViewSetup(){
        diary.delegate = self
        
        let padding = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        diary.textContainerInset = padding
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupPlaceholder() {
        let placeholderText = String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: ""))
        let placeholderColor = UIColor.lightGray
        
        diary.text = placeholderText
        diary.textColor = placeholderColor
    }
    
    //TEXT VIEW SETUP
    func textViewDidBeginEditing(_ textView: UITextView) {
        resetCellStates()
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor(named:"black")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setupPlaceholder()
        } else {
            story = diary.text
        }
    }

    //MARK: MENU
    private func addMenuItems() -> UIMenu {
        //deleteAction
        let deleteTitle = NSAttributedString(string: String(format: NSLocalizedString("삭제", comment: "")), attributes: [.foregroundColor: UIColor.red, .font: font.subSize])
        let deleteAction = UIAction(title: "", image: UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal), handler: { (_) in
            // Delete action handler
            self.fb.deleteDiary(date: self.date)
            self.delegate.diaryDeleted(controller: self)
            self.navigationController?.popViewController(animated: true)
        })
        deleteAction.setValue(deleteTitle, forKey: "attributedTitle")
        
        //shareAction
        let shareTitle = NSAttributedString(string: String(format: NSLocalizedString("공유", comment: "")), attributes: [.foregroundColor: UIColor(named: "black")!, .font: font.subSize])
        let shareAction = UIAction(title: String(format: NSLocalizedString("공유", comment: "")), image: UIImage(systemName: "square.and.arrow.up"), handler: { (_) in
            // Action action handler
        })
        shareAction.setValue(shareTitle, forKey: "attributedTitle")
        
        //menu items
        let menuItems = UIMenu(title: "", options: .displayInline, children: [
//            shareAction,
            deleteAction
        ])
        
        return menuItems
    }
}

//MARK: UICOLLECTIONVIEW
extension DiaryDetailViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private func collectionViewSetup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 8
        
        collectionView.collectionViewLayout = layout
        if sticker.count > 0 {
            collectionView.isHidden = false
        } else {
            collectionView.isHidden = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sticker.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "stickerCell", for: indexPath) as! StickerCell
        
        cell.delegate = self
        
        cell.stickerImg.image = UIImage(named: sticker[indexPath.item])
        cell.stickerImg.transform = CGAffineTransform.identity
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the desired size for each cell
        return CGSize(width: 60, height: 70)
    }
    
    private func resetCellStates() {
        for cell in collectionView.visibleCells {
            if let imageCell = cell as? StickerCell {
                imageCell.resetState()
            }
        }
    }
    
    // Add tap gesture recognizer to the collection view
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapSticker(_:)))
        collectionView.addGestureRecognizer(tapGesture)
        
    }
    
    // Handle the tap gesture on the collection view
    @objc private func handleTapSticker(_ gestureRecognizer: UITapGestureRecognizer) {
        // Tapped outside of an image cell, reset the cell states
        resetCellStates()
        diary.resignFirstResponder()
        resetCellStates()
    }
    
}
