//
//  DatePickerViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit

protocol DatePickerDelegate {
    func passData(controller: DatePickerViewController)
}

class DatePickerViewController: UIViewController {

    @IBOutlet weak var background: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var time = Date()
    let font = Font()
    var timeFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm a"
        return formatter
    }
    
    var delegate: DatePickerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        datePicker.date = time
        setupUI()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: false)
    }
    
    @IBAction func save(_ sender: Any) {
        delegate.passData(controller: self)
        self.dismiss(animated: false)
    }
    
    @objc private func dismissView(){
        self.dismiss(animated: false)
    }

}

extension DatePickerViewController {
    private func setupUI() {
        saveButton.titleLabel?.font = font.subSize
        cancelButton.titleLabel?.font = font.subSize
        background.layer.cornerRadius = 10
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
}
