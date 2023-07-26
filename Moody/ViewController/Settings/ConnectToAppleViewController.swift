//
//  ConnectToAppleViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/26.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import NVActivityIndicatorView
import AuthenticationServices

class ConnectToAppleViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var stackView3: UIStackView!
    @IBOutlet weak var stackView2: UIStackView!
    @IBOutlet weak var stackView1: UIStackView!
    
    @IBOutlet weak var startConnectingButton: UIButton!
    @IBOutlet weak var secondRuleButton: UIButton!
    @IBOutlet weak var firstRuleButton: UIButton!
    
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label1: UILabel!
    
    let font = Font()
    let userDefault = UserDefaults.standard
    let fb = Firebase()
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    var firstRule = false
    var secondRule = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if userDefault.string(forKey: "userEmail") != nil {
            stackView1.isHidden = true
            stackView2.isHidden = true
            stackView3.isHidden = true
            label1.text = String(format: NSLocalizedString("connection.message", comment: ""))
            label1.textAlignment = .center
        } else {
            setupFont()
            setupUI()
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func firstRuleButton(_ sender: Any) {
        firstRule = !firstRule
        firstRuleButton.setImage(firstRule ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        
        if firstRule && secondRule {
            startConnectingButton.isEnabled = true
        } else {
            startConnectingButton.isEnabled = false
        }
    }
    
    @IBAction func secondRuleButton(_ sender: Any) {
        secondRule = !secondRule
        secondRuleButton.setImage(secondRule ? UIImage(systemName: "checkmark.circle") : UIImage(systemName: "circle"), for: .normal)
        
        if firstRule && secondRule {
            startConnectingButton.isEnabled = true
        } else {
            startConnectingButton.isEnabled = false
        }
    }
    
    @IBAction func startConnectingButton(_ sender: Any) {
        if firstRule && secondRule {
            
        }
    }
}

extension ConnectToAppleViewController {
    private func setupUI() {
        stackView1.layer.cornerRadius = 15
        stackView1.layer.borderColor = UIColor(named: "black")!.cgColor
        stackView1.layer.borderWidth = 1
        stackView1.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        startConnectingButton.layer.cornerRadius = 10
        startConnectingButton.isEnabled = false
        startConnectingButton.setTitleColor(UIColor.systemGray2, for: .disabled)
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let center = CGPoint(x: screenWidth/2, y: screenHeight/2)
        
        let frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let type = NVActivityIndicatorType.ballPulse
        let color = UIColor(named: "black")
        let padding: CGFloat = 0
        
        activityIndicatorView = NVActivityIndicatorView(frame: frame, type: type, color: color, padding: padding)
        
        activityIndicatorView.center = center
        self.view.addSubview(activityIndicatorView)
    }
    
    private func setupFont() {
        label1.font = font.subSize
        label2.font = font.subSize
        label3.font = font.sub2Size
        label4.font = font.subSize
        label5.font = font.sub2Size
        label6.font = font.subSize
        label7.font = font.sub2Size
        label8.font = font.subSize
        label9.font = font.sub2Size
        label10.font = font.subSize
        label11.font = font.dateSize
        
        firstRuleButton.titleLabel?.font = font.sub2Size
        secondRuleButton.titleLabel?.font = font.sub2Size
        startConnectingButton.titleLabel?.font = font.title2Size
    }
    
}
