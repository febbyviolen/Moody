//
//  GraphViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/25.
//

import UIKit
import GoogleMobileAds

class GraphViewController: UIViewController, SelectCalendarDelegate {
    
    //MARK: DELEGATE
    func dataPass(controller: SelectCalendarViewController) {
        let newDate = reloadCalendarFormatter.date(from: "\(controller.yearLabel.text ?? "2023").\(controller.selectedMonth)")
        date = newDate!
        
        dateLabel.text = reloadCalendarFormatter.string(from: date)
        item.removeAll()
        graphItem.removeAll()
        dataSetup()
    }
    
    //MARK: PROPERTIES
    @IBOutlet weak var fifthCountLabel: UILabel!
    @IBOutlet weak var fifthImg: UIImageView!
    @IBOutlet weak var fifthView: UIView!
    
    @IBOutlet weak var fourthCountLabel: UILabel!
    @IBOutlet weak var fourthImg: UIImageView!
    @IBOutlet weak var fourthView: UIView!
    
    @IBOutlet weak var thirdCountLabe: UILabel!
    @IBOutlet weak var thirdImg: UIImageView!
    @IBOutlet weak var thirdView: UIView!
    
    @IBOutlet weak var secondCountLabel: UILabel!
    @IBOutlet weak var secondImg: UIImageView!
    @IBOutlet weak var secondView: UIView!
    
    @IBOutlet weak var firstCountLabel: UILabel!
    @IBOutlet weak var firstImg: UIImageView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var rankTitleLabel: UILabel!
    @IBOutlet weak var rankingViewBackground: UIStackView!
    
    private var banner: GADBannerView!
    
    let font = Font()
    
    var calendarDataSource : [String:DiaryModel] = [:]
    var item: [DiaryModel] = []
    var graphItem : [String: Int] = [:]
    var date = Date()
    let calendar = Calendar.current
    
    
    //=== FORMATTER ===
    var reloadCalendarFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter
    }
    
    //MARK: LIFE CYCLE
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        
        dateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCalendarSelect)))
        setupFont()
        setupUI()
        
        dataSetup()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCalendarSelect" {
            if let VC = segue.destination as? SelectCalendarViewController {
                VC.date = date
                VC.delegate = self
            }
        }
    }

    //=== BUTTON ===
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func rightButton(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.month = +1
        
        if let nextMonth = calendar.date(byAdding: dateComponents, to: date) {
            date = nextMonth
            dateLabel.text = reloadCalendarFormatter.string(from: nextMonth)
        }
        item.removeAll()
        graphItem.removeAll()
        dataSetup()
    }
    
    @IBAction func leftButton(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.month = -1
        
        if let previousMonth = calendar.date(byAdding: dateComponents, to: date) {
            date = previousMonth
            dateLabel.text = reloadCalendarFormatter.string(from: previousMonth)
        }
        item.removeAll()
        graphItem.removeAll()
        dataSetup()
    }
    
    //=== OBJC FUNC ===
    @objc private func showCalendarSelect(){
        self.performSegue(withIdentifier: "showCalendarSelect", sender: self)
    }
}

extension GraphViewController {
    //MARK: SETUP UI
    private func setupFont(){
        rankTitleLabel.text = String(format: NSLocalizedString("감정 순위", comment: ""))
        rankTitleLabel.font = font.title2Size
    }
    
    private func setupUI(){
        if UserDefaults.standard.string(forKey: "premiumPass") != "true"  {
            banner = GADBannerView(adSize: GADAdSizeFromCGSize(CGSize(width: view.frame.size.width, height: 50)))
            addBannerViewToView(banner)
            
            banner.adUnitID = "ca-app-pub-2267001621089435/8329415847"
            banner.backgroundColor = .secondarySystemBackground
            banner.rootViewController = self
            
            banner.load(GADRequest())
        }
        
        dateLabel.text = reloadCalendarFormatter.string(from: date)
        dateLabel.font = font.title2Size
        
        rankingViewBackground.layer.cornerRadius = 10
        rankingViewBackground.layer.borderColor = UIColor(named: "black")!.cgColor
        rankingViewBackground.layer.borderWidth = 1
    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
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
    
    
    //MARK: RANK DATA SETUP
    private func dataSetup(){
        item = calendarDataSource.filter({ (key, value) in
            return key.contains(dateLabel.text!)
        }).map({$0.value})
        
        for i in item {
            for j in i.sticker {
                if graphItem[j] == nil {
                    graphItem[j] = 1
                } else {
                    graphItem[j]! += 1
                }
            }
        }
        
        dateUI()
    }
    
    private func dateUI(){
        let graphItemTitleSorted = graphItem.sorted { (item1, item2) in
            if item1.value == item2.value {
                return item1.key < item2.key
            } else {
                return item1.value > item2.value
            }
        }.map { $0.key }

        let graphItemCountSorted = graphItem.sorted { (item1, item2) in
            if item1.value == item2.value {
                return item1.key < item2.key
            } else {
                return item1.value > item2.value
            }
        }.map { $0.value }
        
        switch graphItem.count {
        case 1:
            setupFont()
            firstView.isHidden = false
            secondView.isHidden = true
            thirdView.isHidden = true
            fourthView.isHidden = true
            fifthView.isHidden = true
            
            firstImg.image = UIImage(named: graphItemTitleSorted[0])
            firstCountLabel.text = String(graphItemCountSorted[0])
        case 2:
            setupFont()
            firstView.isHidden = false
            secondView.isHidden = false
            thirdView.isHidden = true
            fourthView.isHidden = true
            fifthView.isHidden = true
            
            firstImg.image = UIImage(named: graphItemTitleSorted[0])
            firstCountLabel.text = String(graphItemCountSorted[0])
            secondImg.image = UIImage(named: graphItemTitleSorted[1])
            secondCountLabel.text = String(graphItemCountSorted[1])
        case 3:
            setupFont()
            firstView.isHidden = false
            secondView.isHidden = false
            thirdView.isHidden = false
            fourthView.isHidden = true
            fifthView.isHidden = true
            
            firstImg.image = UIImage(named: graphItemTitleSorted[0])
            firstCountLabel.text = String(graphItemCountSorted[0])
            secondImg.image = UIImage(named: graphItemTitleSorted[1])
            secondCountLabel.text = String(graphItemCountSorted[1])
            thirdImg.image = UIImage(named: graphItemTitleSorted[2])
            thirdCountLabe.text = String(graphItemCountSorted[2])
        case 4:
            setupFont()
            firstView.isHidden = false
            secondView.isHidden = false
            thirdView.isHidden = false
            fourthView.isHidden = false
            fifthView.isHidden = true
            
            firstImg.image = UIImage(named: graphItemTitleSorted[0])
            firstCountLabel.text = String(graphItemCountSorted[0])
            secondImg.image = UIImage(named: graphItemTitleSorted[1])
            secondCountLabel.text = String(graphItemCountSorted[1])
            thirdImg.image = UIImage(named: graphItemTitleSorted[2])
            thirdCountLabe.text = String(graphItemCountSorted[2])
            fourthImg.image = UIImage(named: graphItemTitleSorted[3])
            fourthCountLabel.text = String(graphItemCountSorted[3])
        case 5...:
            setupFont()
            firstView.isHidden = false
            secondView.isHidden = false
            thirdView.isHidden = false
            fourthView.isHidden = false
            fifthView.isHidden = false
            
            firstImg.image = UIImage(named: graphItemTitleSorted[0])
            firstCountLabel.text = String(graphItemCountSorted[0])
            secondImg.image = UIImage(named: graphItemTitleSorted[1])
            secondCountLabel.text = String(graphItemCountSorted[1])
            thirdImg.image = UIImage(named: graphItemTitleSorted[2])
            thirdCountLabe.text = String(graphItemCountSorted[3])
            fourthImg.image = UIImage(named: graphItemTitleSorted[3])
            fourthCountLabel.text = String(graphItemCountSorted[3])
            fifthImg.image = UIImage(named: graphItemTitleSorted[4])
            fifthCountLabel.text = String(graphItemCountSorted[4])
        default:
            rankTitleLabel.text = String(format: NSLocalizedString("데이터 없음", comment: ""))
            rankTitleLabel.font = font.subSize
            firstView.isHidden = true
            secondView.isHidden = true
            thirdView.isHidden = true
            fourthView.isHidden = true
            fifthView.isHidden = true
        }
    }
}
