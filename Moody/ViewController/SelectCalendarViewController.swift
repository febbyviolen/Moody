//
//  SelectCalendarViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit

protocol SelectCalendarDelegate {
    func dataPass(controller: SelectCalendarViewController)
}

class SelectCalendarViewController: UIViewController {

    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var decLabel: UILabel!
    @IBOutlet weak var novLabel: UILabel!
    @IBOutlet weak var octLabel: UILabel!
    @IBOutlet weak var septLabel: UILabel!
    @IBOutlet weak var augLabel: UILabel!
    @IBOutlet weak var julyLabel: UILabel!
    @IBOutlet weak var juneLabel: UILabel!
    @IBOutlet weak var mayLabel: UILabel!
    @IBOutlet weak var aprLabel: UILabel!
    @IBOutlet weak var marLabel: UILabel!
    @IBOutlet weak var febLabel: UILabel!
    @IBOutlet weak var janLabel: UILabel!
    @IBOutlet weak var calendarBackgroundView: UIView!
    @IBOutlet var backgroundView: UIView!
    
    let font = Font()
    var delegate : SelectCalendarDelegate! = nil
    let calendar = Calendar.current
    var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    var date = Date()
    var selectedMonth = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.isModalInPresentation = true
        self.navigationController?.navigationItem.backBarButtonItem?.isEnabled = false;
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
        
        
        setupUI()
        setupAction()
        
    }
    
    @objc private func dismissView() {
        self.dismiss(animated: true)
    }
    
    @IBAction func rightButton(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.year = +1
        
        if let nextYear = calendar.date(byAdding: dateComponents, to: date) {
            date = nextYear
            yearLabel.text = yearFormatter.string(from: nextYear)
        }
    }
    
    @IBAction func leftButton(_ sender: Any) {
        var dateComponents = DateComponents()
        dateComponents.year = -1
        
        if let lastYear = calendar.date(byAdding: dateComponents, to: date) {
            date = lastYear
            yearLabel.text = yearFormatter.string(from: lastYear)
        }
    }

}

extension SelectCalendarViewController {
    private func setupUI(){
        yearLabel.text = yearFormatter.string(from: date)
        yearLabel.font = font.subSize
        
        calendarBackgroundView.layer.cornerRadius = 10
        
        janLabel.layer.cornerRadius = 5
        janLabel.layer.borderColor = UIColor.black.cgColor
        janLabel.layer.borderWidth = 1
        
        febLabel.layer.cornerRadius = 5
        febLabel.layer.borderColor = UIColor.black.cgColor
        febLabel.layer.borderWidth = 1
        
        marLabel.layer.cornerRadius = 5
        marLabel.layer.borderColor = UIColor.black.cgColor
        marLabel.layer.borderWidth = 1
        
        aprLabel.layer.cornerRadius = 5
        aprLabel.layer.borderColor = UIColor.black.cgColor
        aprLabel.layer.borderWidth = 1
        
        mayLabel.layer.cornerRadius = 5
        mayLabel.layer.borderColor = UIColor.black.cgColor
        mayLabel.layer.borderWidth = 1
        
        juneLabel.layer.cornerRadius = 5
        juneLabel.layer.borderColor = UIColor.black.cgColor
        juneLabel.layer.borderWidth = 1
        
        julyLabel.layer.cornerRadius = 5
        julyLabel.layer.borderColor = UIColor.black.cgColor
        julyLabel.layer.borderWidth = 1
        
        augLabel.layer.cornerRadius = 5
        augLabel.layer.borderColor = UIColor.black.cgColor
        augLabel.layer.borderWidth = 1
        
        septLabel.layer.cornerRadius = 5
        septLabel.layer.borderColor = UIColor.black.cgColor
        septLabel.layer.borderWidth = 1
        
        octLabel.layer.cornerRadius = 5
        octLabel.layer.borderColor = UIColor.black.cgColor
        octLabel.layer.borderWidth = 1
        
        novLabel.layer.cornerRadius = 5
        novLabel.layer.borderColor = UIColor.black.cgColor
        novLabel.layer.borderWidth = 1
        
        decLabel.layer.cornerRadius = 5
        decLabel.layer.borderColor = UIColor.black.cgColor
        decLabel.layer.borderWidth = 1
        
    }
    
    private func setupAction() {
        janLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate1)))
        febLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate2)))
        marLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate3)))
        aprLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate4)))
        mayLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate5)))
        juneLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate6)))
        julyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate7)))
        augLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate8)))
        septLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate9)))
        octLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate10)))
        novLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate11)))
        decLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectDate12)))
    }
    
    @objc private func selectDate1() {
        selectedMonth = "01"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate2() {
        selectedMonth = "02"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate3() {
        selectedMonth = "03"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate4() {
        selectedMonth = "04"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate5() {
        selectedMonth = "05"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate6() {
        selectedMonth = "06"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate7() {
        selectedMonth = "07"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate8() {
        selectedMonth = "08"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate9() {
        selectedMonth = "09"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate10() {
        selectedMonth = "10"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate11() {
        selectedMonth = "11"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
    
    @objc private func selectDate12() {
        selectedMonth = "12"
        delegate.dataPass(controller: self)
        dismiss(animated: false)
    }
}
