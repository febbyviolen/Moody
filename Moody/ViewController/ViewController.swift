//
//  ViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/15.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    let font = Font()
    let fb = Firebase()
    let userdefault = UserDefaults.standard
    
    var dateSelected = Date()
    var calendarDataSource: [String:String] = [:]
    
    var dataCalendarFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        setupUser()
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
            }
        }
    }
    
    @IBAction func addButton(_ sender: Any) {
        dateSelected = Date()
        performSegue(withIdentifier: "showSticker", sender: self)
    }
    
}

extension ViewController {
    func setupUser(){
        if userdefault.string(forKey: "userID") != nil {
            //what to do
            print(userdefault.string(forKey: "userID"))
        } else {
            fb.anonymSign()
        }
    }
    
    func FontSetup() {
        UILabel.appearance().font = font.sub2Size
        yearLabel.font = font.sub2Size
        monthLabel.font = font.titleSize
        
    }
    
    func populateDataSource(){
        calendarDataSource = [
            "07-06-2023": "Happy",
            "15-06-2023": "Sad",
            "15-05-2023": "MoreData",
            "21-05-2023": "onlyData",
        ]
        
        calendar.reloadData()
    }
    
    private func UISetup(){
        addButton.layer.cornerRadius = 5
        addButton.layer.borderColor = UIColor.black.cgColor
        addButton.layer.borderWidth = 1
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
            cell.stickerImage.isHidden = false
            print(dateString)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        dateSelected = cellState.date
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
        yearLabel.text = formatter.string(from: visibleDates.monthDates.first!.date)
    }
    
}
