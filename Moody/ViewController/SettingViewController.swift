//
//  SettingViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit

class SettingViewController: UIViewController, DatePickerDelegate {
    
    func passData(controller: DatePickerViewController) {
        time = controller.datePicker.date
        timeClockLabel.text = showTimeFormatter.string(from: time!)
    }
    
    @IBOutlet weak var alarmClockView: UIView!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var timeClockLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var appReviewLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var alarmClockLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var premiumLabel: UILabel!
    @IBOutlet weak var buySubscribeBackground: UIView!
   
    let font = Font()
    
    var showTimeFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var time: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setupTime()
        setupUI()
        setupFont()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDatePicker" {
            if let VC = segue.destination as? DatePickerViewController {
                VC.time = time!
                VC.delegate = self
            }
        }
    }
    
    @IBAction func alarmSwitch(_ sender: Any) {
        if alarmSwitch.isOn {
            alarmClockView.isHidden = false
        } else {
            alarmClockView.isHidden = true
            timeClockLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTimePicker)))
        }
    }
}

extension SettingViewController {
    private func setupTime() {
        let timeString = "22:00"
        time = showTimeFormatter.date(from: timeString)
        timeClockLabel.text = showTimeFormatter.string(from: time!)
        timeClockLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTimePicker)))
    }
    
    private func setupUI(){
        buySubscribeBackground.layer.cornerRadius = 10
        buySubscribeBackground.layer.borderColor = UIColor.black.cgColor
        buySubscribeBackground.layer.borderWidth = 1
        
    }
    
    private func setupFont(){
        premiumLabel.font = font.title2Size
        alarmLabel.font = font.subSize
        alarmClockLabel.font = font.subSize
        lockLabel.font = font.subSize
        languageLabel.font = font.subSize
        googleLabel.font = font.subSize
        appReviewLabel.font = font.subSize
        timeClockLabel.font = font.subSize
    }
    
    
    @objc private func showTimePicker() {
        performSegue(withIdentifier: "showDatePicker", sender: self)
    }
    
}
