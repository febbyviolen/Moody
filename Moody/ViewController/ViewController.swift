//
//  ViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/15.
//

import UIKit
import JTAppleCalendar
import UserNotifications
import GoogleMobileAds

class ViewController: UIViewController, UIGestureRecognizerDelegate, DiaryDetailDelegate, DiaryListDelegate, passwordDelegate, SelectCalendarDelegate{
    
    //MARK: DELEGATE
    func dataPass(controller: SelectCalendarViewController) {
        let newDate = dataCalendarFormatter.date(from: "\(controller.yearLabel.text ?? "2023").\(controller.selectedMonth).\(15)")
        
        calendar.scrollToDate(newDate ?? Date(), animateScroll: true)
        
        //change to current month label
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: newDate ?? Date()).uppercased()

        //change to current year label
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: newDate ?? Date())
//
        currentYear = formatter.string(from: newDate ?? Date())
        
    }
    
    func diaryAdded(controller: DiaryDetailViewController) {
        let newDate = dataCalendarFormatter.string(from: controller.date)
        calendarDataSource[newDate] = DiaryModel(sticker: controller.sticker, story: controller.diary.text == String(format: NSLocalizedString("오늘 하루를 기록해보세요", comment: "")) ? "" : controller.diary.text, date: newDate)
        calendar.reloadDates([controller.date])
        
        formatter.dateFormat = "dd"
        let date = formatter.string(from: controller.date)
        
        if date == "01" || date == "1" {
            formatter.dateFormat = "yyyy.MMMM.dd"
            let newDate = formatter.date(from: "\(yearLabel.text!).\(monthLabel.text!).\(15)")
            calendar.scrollToDate(newDate ?? Date(), animateScroll: false)
        } else {
            calendar.scrollToDate(controller.date, animateScroll: false)
        }
    }
    
    func diaryDeleted(controller: DiaryDetailViewController) {
        let deleteDate = dataCalendarFormatter.string(from: controller.date)
        calendarDataSource.removeValue(forKey: deleteDate)
        calendar.reloadDates([controller.date])
    }
    
    func passDataBack(controller: DiaryListViewController) {
        calendarDataSource = controller.calendarDataSource
    }
    
    func passData(controller: PasswordViewController) {
        loggedIn = true
    }
     
    @IBOutlet weak var dateStackView: UIStackView!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    
    private var banner: GADBannerView!
    
    let formatter = DateFormatter()
    let font = Font()
    let fb = Firebase()
    let userdefault = UserDefaults.standard
    
    var dateSelected = Date()
    var selected : DiaryModel?
    
    var calendarDataSource: [String: DiaryModel] = [:]
    var currentYear: String = ""
    var loggedIn = false
    var sendFromAddSticker = false
    
    //=== DATE FORMATTER ===
    var dataCalendarFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }
    
    //MARK: LIFE CYCLE
    override func viewWillAppear(_ animated: Bool) {
        sendFromAddSticker = false
        
        if calendarDataSource.isEmpty {
            setupUser()
        }
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        checkPasscodeAvail()
        setNotification()
        calendar.ibCalendarDelegate = self
        calendar.ibCalendarDataSource = self
        UISetup()
        FontSetup()
        setFunc()
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSticker" {
            if let VC = segue.destination as? DiaryDetailViewController {
                VC.date = dateSelected
                VC.sticker = selected?.sticker ?? []
                VC.story = selected?.story ?? ""
                VC.delegate = self
                VC.comeFromVC = ViewController.description()
                VC.fromAddSticker = sendFromAddSticker
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
        if segue.identifier == "showPassword" {
            if let VC = segue.destination as? PasswordViewController {
                VC.delegate = self
                VC.navigationController?.isNavigationBarHidden = true
            }
        }
        if segue.identifier == "showCalendarSelect" {
            if let VC = segue.destination as? SelectCalendarViewController {
                VC.delegate = self
            }
        }
    }
    
    //MARK: BUTTON
    @IBAction func addButton(_ sender: Any) {
        dateSelected = Date()
        selected = calendarDataSource[dataCalendarFormatter.string(from: dateSelected)]
        sendFromAddSticker = true
        performSegue(withIdentifier: "showSticker", sender: self)
    }
    
    @IBAction func TodayButton(_ sender: Any) {
        
        formatter.dateFormat = "dd"
        let date = formatter.string(from: Date())
        if date == "01" || date == "1" {
            formatter.dateFormat = "yyyy.MMMM.dd"
            let newDate = formatter.date(from: "\(yearLabel.text!).\(monthLabel.text!).\(15)")
            calendar.scrollToDate(newDate ?? Date(), animateScroll: false)
        } else {
            calendar.scrollToDate(Date(), animateScroll: false)
        }
        
    }
}

extension ViewController {
    //MARK: APP OPENED FUNC
    //check if passcode is activated or not
    private func checkPasscodeAvail(){
        //if passcode is activated
        if userdefault.string(forKey: "password") != nil {
            if loggedIn == false {
                performSegue(withIdentifier: "showPassword", sender: self)
            } // if biopassword is activated
        } else if userdefault.string(forKey: "bioPassword") == "true" {
            if loggedIn == false {
                performSegue(withIdentifier: "showPassword", sender: self)
            }
        }
    }
    
    //calendar setup
    private func setupUser(){
        if userdefault.string(forKey: "userID") != nil{
            calendarSetup()
        } else {
            fb.anonymSign {
                self.calendarSetup()
            }
        }
    }
    
    //MARK: FIRST DOWNLOAD
    //if user allow the notification, and hasn't open the settings it will initially set alarm at 10pm
    private func setNotification() {
        if userdefault.string(forKey: "alarmSetting") == nil {
            
            
            // Request authorization for notifications
            UNUserNotificationCenter.current()
                .requestAuthorization(
                    options: [.alert, .sound, .badge]
                ) { (granted, error) in
                if granted {
                    // User granted permission
                    // Create notification content
                    let content = UNMutableNotificationContent()
                    content.title = "Moody"
                    content.body = String(format: NSLocalizedString("오늘 하루도 기록해보세요!", comment: ""))
                    content.sound = UNNotificationSound.default
                    
                    // Create date components for 10 PM
                    var dateComponents = DateComponents()
                    dateComponents.hour = self.userdefault.integer(forKey: "alarmTime") == 0 ? 22 : self.userdefault.integer(forKey: "alarmTime")
                    dateComponents.minute = self.userdefault.integer(forKey: "alarmMinute") == 0 ? 00 : self.userdefault.integer(forKey: "alarmMinute")
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    
                    let request = UNNotificationRequest(identifier: "addDiaryNotification", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request) { error in
                        if let _ = error {
//                            print("error")
                        } else {
//                            print("not error")
                        }
                    }
                } else {
                    // User denied permission or there was an error
//                    print("Notification permission denied or error: \(error?.localizedDescription ?? "")")
                }
            }
            
        }
    }
    
    //MARK: FUNC SETUP
    private func setFunc(){
        dateStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSelectCalendar)))
    }
    
    //MARK: OBJC FUNC
    @objc private func showSelectCalendar(){
        self.performSegue(withIdentifier: "showCalendarSelect", sender: self)
    }
    
    //MARK: UI SETUP
    private func UISetup(){
        todayButton.titleLabel?.font = font.sub2Size
        todayButton.titleLabel?.text = String(format: NSLocalizedString("오늘", comment: ""))
        
//        bannerSetup()
        
        //change navigationcontroller title font
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: font.subSize ]
    }
    
    private func bannerSetup(){
        banner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: view.frame.size.width, height: 50)))
        addBannerViewToView(banner)
        
        banner.adUnitID = "ca-app-pub-2267001621089435/8329415847"
        banner.backgroundColor = .secondarySystemBackground
        banner.rootViewController = self
        
        banner.load(GADRequest())
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        banner.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(banner)
        view.addConstraints(
          [NSLayoutConstraint(item: banner!,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .bottom,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: banner!,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
       }
    
    private func FontSetup() {
        UILabel.appearance().font = font.sub2Size
        yearLabel.font = font.sub2Size
        monthLabel.font = font.titleSize
    }
}

//MARK: JTAPPLECALENDAR
extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    //MARK: CALENDAR SETUP
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
    
    private func calendarSetup() {
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.scrollDirection = .vertical
        calendar.showsVerticalScrollIndicator = false
        
        //year label
        formatter.dateFormat = "yyyy"
        yearLabel.text = formatter.string(from: Date())
        
        //month label
        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: Date())
        
        formatter.dateFormat = "dd"
        let date = formatter.string(from: Date())
        if date == "01" || date == "1" {
            formatter.dateFormat = "yyyy.MMMM.dd"
            let newDate = formatter.date(from: "\(yearLabel.text!).\(monthLabel.text!).\(15)")
            calendar.scrollToDate(newDate ?? Date(), animateScroll: false)
        } else {
            calendar.scrollToDate(Date(), animateScroll: false)
        }
        
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
    
    //handle date belongs to this month or not
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
            cell.dateLabel.textColor = UIColor(named: "black")
        }
        
        if cellState.date > Date() {
            cell.dateLabel.textColor = .gray
        }
    }
    
    private func handleEvents(cell: DateCell, cellState: CellState) {
        let dateString = dataCalendarFormatter.string(from: cellState.date)
        if calendarDataSource[dateString] == nil {
            cell.stickerImage.isHidden = true
            cell.dateLabel.isHidden = false
        } else {
            
            if !(calendarDataSource[dateString]?.sticker.isEmpty)! {
                cell.stickerImage.image = UIImage(named: (calendarDataSource[dateString]?.sticker.first)!)
                cell.stickerImage.isHidden = false
                cell.dateLabel.isHidden = true
            } else {
                cell.dateLabel.isHidden = false
            }
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
