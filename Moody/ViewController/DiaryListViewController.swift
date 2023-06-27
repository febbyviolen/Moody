//
//  DiaryListViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/22.
//

import UIKit

protocol DiaryListDelegate {
    func passDataBack(controller: DiaryListViewController)
}

class DiaryListViewController: UIViewController, UIGestureRecognizerDelegate, DiaryDetailDelegate, SelectCalendarDelegate {
    
    func diaryAdded(controller: DiaryDetailViewController) {
        let newDate = dataCalendarFormatter.string(from: controller.date)
        calendarDataSource[newDate] = DiaryModel(sticker: controller.sticker, story: controller.diary.text, date: newDate)
        tableViewSetupIndex(indexPath: controller.selectedIndex!)
    }
    
    func diaryDeleted(controller: DiaryDetailViewController) {
        let newDate = dataCalendarFormatter.string(from: controller.date)
        calendarDataSource.removeValue(forKey: newDate)
        tableViewSetupIndex(indexPath: controller.selectedIndex!)
    }
    
    func dataPass(controller: SelectCalendarViewController) {
        let newDate = reloadCalendarFormatter.date(from: "\(controller.yearLabel.text ?? "2023").\(controller.selectedMonth)")
        date = newDate!
        dateLabel.text = reloadCalendarFormatter.string(from: date)
        tableViewSetup()
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var calendarDataSource : [String:DiaryModel] = [:]
    var item: [DiaryModel] = []
    var date = Date()
    let calendar = Calendar.current
    var selectedDiary: DiaryModel!
    var selectedIndex: IndexPath!
    var delegate: DiaryListDelegate! = nil
    
    let font = Font()
    
    var dataCalendarFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    var reloadCalendarFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableViewSetup()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        dateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCalendarSelect)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailController" {
            if let VC = segue.destination as? DiaryDetailViewController {
                let selectedDate = dataCalendarFormatter.date(from: selectedDiary.date)
                VC.date = selectedDate ?? date
                VC.sticker = selectedDiary.sticker
                VC.story = selectedDiary.story
                VC.selectedIndex = selectedIndex
                VC.delegate = self
            }
        }
        if segue.identifier == "showCalendarSelect" {
            if let VC = segue.destination as? SelectCalendarViewController {
                VC.date = date
                VC.delegate = self
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        delegate.passDataBack(controller: self)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func rightButton(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.month = +1
        
        if let nextMonth = calendar.date(byAdding: dateComponents, to: date) {
            date = nextMonth
            dateLabel.text = reloadCalendarFormatter.string(from: nextMonth)
            tableViewSetup()
        }
    }
    
    @IBAction func leftButton(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        if let previousMonth = calendar.date(byAdding: dateComponents, to: date) {
            date = previousMonth
            dateLabel.text = reloadCalendarFormatter.string(from: previousMonth)
            tableViewSetup()
        }
    }
    
    @objc private func showCalendarSelect(){
        self.performSegue(withIdentifier: "showCalendarSelect", sender: self)
    }

}


extension DiaryListViewController {
    private func setupUI(){
        self.navigationController?.navigationBar.isHidden = true
        
        dateLabel.text = reloadCalendarFormatter.string(from: date)
        dateLabel.font = font.title2Size
    }
    
    private func tableViewSetup(){
        
        item = calendarDataSource.filter({ (key, value) in
            return key.contains(dateLabel.text!)
        }).map({$0.value}).sorted(by: {$0.date < $1.date})
        tableView.reloadData()
    }
   
    private func tableViewSetupIndex(indexPath: IndexPath) {
        item = calendarDataSource.filter({ (key, value) in
            return key.contains(dateLabel.text!)
        }).map({$0.value}).sorted(by: {$0.date < $1.date})
        tableView.reloadData()
    }
}

extension DiaryListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DiaryListCell
        
        cell.selectionStyle = .none
        
        cell.background.layer.cornerRadius = 10
        cell.background.layer.borderWidth = 1
        cell.background.layer.borderColor = UIColor.black.cgColor
        
        cell.item = item[indexPath.item].sticker
        if item[indexPath.item].sticker != [] {
            cell.item = item[indexPath.item].sticker
            cell.collectionView.isHidden = false
        } else {cell.collectionView.isHidden = true}
        
        cell.dateLabel.text = item[indexPath.item].date
        cell.dateLabel.font = font.dateSize
        cell.dateLabel.textColor = .systemGray
        
        if item[indexPath.item].story != "" {
            cell.storyLabel.text = item[indexPath.item].story
            cell.storyLabel.isHidden = false
        } else {cell.storyLabel.isHidden = true}
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDiary = item[indexPath.item]
        selectedIndex = indexPath
        performSegue(withIdentifier: "showDetailController", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0 + 10.0
    }
}

