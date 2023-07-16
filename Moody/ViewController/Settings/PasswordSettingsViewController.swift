//
//  PasswordSettingsViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/29.
//

import UIKit
import LocalAuthentication

class PasswordSettingsViewController: UIViewController, passwordDelegate {
    
    func passData(controller: PasswordViewController) {
        passSwitch.setOn(false, animated: true)
        changePassView.isHidden = true
    }

    @IBOutlet weak var changePassView: UIView!
    @IBOutlet weak var bioSwitch: UISwitch!
    @IBOutlet weak var passSwitch: UISwitch!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var changePassLabel: UILabel!
    @IBOutlet weak var passLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    let font = Font()
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = false
        setupFont()
        setupUI()
        
        changePassView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPasswordPad)))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPasswordPad" {
            if let VC = segue.destination as? PasswordViewController {
                if userDefault.string(forKey: "password") == nil {
                    VC.authMethod = "password"
                    VC.delegate = self
                } else {
                    VC.authMethod = "passwordChange"
                }
            }
        }
    }
    
    @objc private func showPasswordPad(){
        performSegue(withIdentifier: "showPasswordPad", sender: self)
    }
    
    @IBAction func passLabel(_ sender: Any) {
        if passSwitch.isOn {
            changePassView.isHidden = false
            performSegue(withIdentifier: "showPasswordPad", sender: self)
        } else {
            userDefault.set(nil, forKey: "password")
            changePassView.isHidden = true
        }
    }
    
    @IBAction func bioLabel(_ sender: Any) {
        if bioSwitch.isOn{
            authenticateWithFaceID()
        } else {
            userDefault.set("false", forKey: "bioPassword")
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension PasswordSettingsViewController {
    private func setupUI() {
        if userDefault.string(forKey: "password") != nil {
            changePassView.isHidden = false
            passSwitch.setOn(true, animated: false)
        }
    }
    
    private func setupFont() {
        changePassLabel.font = font.sub2Size
        passLabel.font = font.subSize
        changePassLabel.font = font.subSize
        descLabel.font = font.subSize
    }
    
    func authenticateWithFaceID() {
        DispatchQueue.main.async {
            let context = LAContext()
            var error: NSError?

            // Check if Face ID is available on the device
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = String(format: NSLocalizedString("Face ID를 사용하여 인증해주세요", comment: ""))

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                    DispatchQueue.main.async {
                        guard success, error == nil else {
                            // Face ID authentication failed
                            let alertController = UIAlertController(
                                title: String(format: NSLocalizedString("faceId.localizedAuthenticationFailed", comment: "")),
                                message: String(format: NSLocalizedString("faceId.localizedMismatch", comment: "")),
                                preferredStyle: .alert)
                            
                            
                            let messageFont = [NSAttributedString.Key.font: self.font.sub2Size]
                            
                            let attributedTitle = NSAttributedString(string: String(format: NSLocalizedString("faceId.localizedAuthenticationFailed", comment: "")), attributes: messageFont)
                            
                            alertController.setValue(attributedTitle, forKey: "attributedMessage")
                            
                            
                            let tryAgainAction = UIAlertAction(
                                title: String(format: NSLocalizedString("faceId.localizedFallbackTitle", comment: "")),
                                style: .default
                            ) { _ in
                                self.authenticateWithFaceID() // Retry Face ID authentication
                            }
                            
                            let cancelAction = UIAlertAction(
                                title: String(format: NSLocalizedString("취소", comment: "")),
                                style: .default
                            ) { _ in
                                self.bioSwitch.isOn = false
                            }
                            
                            tryAgainAction.setValue(UIColor.black, forKey: "titleTextColor")
                            cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                            
                            alertController.addAction(tryAgainAction)
                            alertController.addAction(cancelAction)
                            
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        self.userDefault.set("true", forKey: "bioPassword")
                    }
                }
            } else {
                // Face ID not available on the device or not configured
                // Handle the error accordingly
                let alertController = UIAlertController(
                    title: String(format: NSLocalizedString("biometricAuthentication.notAvailable", comment: "")),
                    message: "",
                    preferredStyle: .alert)
                
                let messageFont = [NSAttributedString.Key.font: self.font.subSize]
                let attributedMessage = NSAttributedString(string: String(format: NSLocalizedString("biometricAuthentication.notAvailable", comment: "")),
                                                           attributes: messageFont)
                
                alertController.setValue(attributedMessage, forKey: "attributedTitle")
               
                let cancelAction = UIAlertAction(
                    title: String(format: NSLocalizedString("네", comment: "")),
                    style: .default,
                    handler: { _ in
                        self.bioSwitch.isOn = false
                    })
                cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
                
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                
                self.bioSwitch.isOn =  false
            }
        }
    }
}
