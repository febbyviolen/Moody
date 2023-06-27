//
//  ViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/15.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController, DiaryDetailDelegate, DiaryListDelegate {
    
    func diaryAdded(controller: DiaryDetailViewController) {
        let newDate = dataCalendarFormatter.string(from: controller.date)
        calendarDataSource[newDate] = DiaryModel(sticker: controller.sticker, story: controller.diary.text, date: newDate)
        calendar.reloadDates([controller.date])
    }
    
    func diaryDeleted(controller: DiaryDetailViewController) {
        let deleteDate = dataCalendarFormatter.string(from: controller.date)
        calendarDataSource.removeValue(forKey: deleteDate)
        calendar.reloadDates([controller.date])
    }
    
    func passDataBack(controller: DiaryListViewController) {
        calendarDataSource = controller.calendarDataSource
    }
    
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    let font = Font()
    let fb = Firebase()
    let userdefault = UserDefaults.standard
    
    var dateSelected = Date()
    var selected : DiaryModel?
    
    var calendarDataSource: [String:DiaryModel] = [:]
    var currentYear: String = ""
    
    var dataCalendarFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    //MARK: LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        setupUser()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        calendar.ibCalendarDelegate = self
        calendar.ibCalendarDataSource = self
        calendarSetup()
        UISetup()
        FontSetup()
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSticker" {
            if let VC = segue.destination as? DiaryDetailViewController {
                VC.date = dateSelected
                VC.sticker = selected?.sticker ?? []
                VC.story = selected?.story ?? ""
                VC.delegate = self
                VC.comeFromVC = ViewController.description()
            }
        }
        if segue.identifier == "showListController" {
            if let VC = segue.destination as? DiaryListViewController {
                VC.calendarDataSource = calendarDataSource
                VC.delegate = self
            }
        }
        if segue.identifier == "showGraphView" {
            if let VC = segue.destination as? GraphViewController {
                VC.calendarDataSource = calendarDataSource
            }
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        dateSelected = Date()
        performSegue(withIdentifier: "showSticker", sender: self)
    }
    
    @IBAction func TodayButton(_ sender: Any) {
        calendar.scrollToDate(Date())
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: Date()).uppercased()
        
        //year label
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: Date())
        
        currentYear = formatter.string(from: Date())
        calendar.reloadData()
    }
    
}

extension ViewController {
    func setupUser(){
        if userdefault.string(forKey: "userID") != nil {
//            print(userdefault.string(forKey: "userID"))
        } else {
            fb.anonymSign()
        }
    }
    
    private func FontSetup() {
        UILabel.appearance().font = font.sub2Size
        yearLabel.font = font.sub2Size
        monthLabel.font = font.titleSize
        
    }
    
    private func populateDataSource(){
        calendarDataSource.removeAll()
        fb.getDiaryData(date: Date()) { sticker, story, date, ID in
            self.calendarDataSource[ID] = DiaryModel(sticker: sticker, story: story, date: date)
            self.calendar.reloadData()
        }
    }
    
    private func addDataSource(date: Date){
        calendarDataSource.removeAll()
        fb.getDiaryData(date: Date()) { sticker, story, date, ID in
            self.calendarDataSource[date] = DiaryModel(sticker: sticker, story: story, date: date)
        }
        
        calendar.reloadData()
    }
    
    private func UISetup(){
        todayButton.titleLabel?.font = font.sub2Size
        todayButton.titleLabel?.text = "오늘"
    }
}

extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate{
    
    private func calendarSetup() {
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.scrollDirection = .vertical
        calendar.showsVerticalScrollIndicator = false
        
        calendar.scrollToDate(Date())
        
        //month label
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: Date())
        
        //year label
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: Date())
        
        currentYear = formatter.string(from: Date())
        
        populateDataSource()
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2010 01 01")!
        let endDate = formatter.date(from: "2050 01 01")!
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTAppleCell?, cellState: CellState) {
        guard let cell = view as? DateCell  else { return }
        cell.dateLabel.text = cellState.text
        handleInOutDates(cell: cell, cellState: cellState)
        handleDateColor(cell: cell, cellState: cellState)
        handleEvents(cell: cell, cellState: cellState)
    }
    
    private func handleInOutDates(cell: DateCell, cellState: CellState) {
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            cell.isHidden = true
        }
    }
    
    private func handleDateColor(cell: DateCell, cellState: CellState) {
        if cellState.day == .sunday {
            cell.dateLabel.textColor = .red
        } else {
            cell.dateLabel.textColor = .black
        }
        
        if cellState.date > Date() {
            cell.dateLabel.textColor = .gray
        }
    }
    
    private func handleEvents(cell: DateCell, cellState: CellState) {
        let dateString = dataCalendarFormatter.string(from: cellState.date)
        if calendarDataSource[dateString] == nil {
            cell.stickerImage.isHidden = true
        } else {
            cell.stickerImage.image = UIImage(named: calendarDataSource[dateString]?.sticker.first ?? "happy")
            cell.stickerImage.isHidden = false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        dateSelected = cellState.date
        selected = calendarDataSource[dataCalendarFormatter.string(from: cellState.date)]
        performSegue(withIdentifier: "showSticker", sender: self)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if cellState.date > Date() {
            return false
        } else {
            return true
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        
        //month label when scrolled
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let month = formatter.string(from: visibleDates.monthDates.first!.date).uppercased()
        monthLabel.text = month
        
                
        //year label when scrolled
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: visibleDates.monthDates.first!.date)
        if year < currentYear {
            currentYear = year
            addDataSource(date: visibleDates.monthDates.first?.date ?? Date())
        }
            
        yearLabel.text = year
        
        formatter.dateFormat = "yyyy.MMMM"
        if formatter.string(from: visibleDates.monthDates.first!.date) != formatter.string(from: Date()) {
            todayButton.alpha = 1
            UISetup()
        } else {
            todayButton.alpha = 0
        }
        
    }
    
}
