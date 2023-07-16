//
//  LanguageViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/07/02.
//

import UIKit

class LanguageViewController: UIViewController {

    @IBOutlet weak var bahasaButton: UIButton!
    @IBOutlet weak var englishButton: UIButton!
    @IBOutlet weak var KoreanButton: UIButton!
    @IBOutlet weak var bahasaLabel: UILabel!
    @IBOutlet weak var englishLabel: UILabel!
    @IBOutlet weak var koreaLabel: UILabel!
    
    let font = Font()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupFont()
        setupUI()
    }

    @IBAction func koreaButton(_ sender: Any) {
        
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        let languageCode = languageCodes?.first ?? "kor"
        
        KoreanButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        
        if languageCode != "kor"{
            let selectedLanguageCode = "kor" // Replace with the language code for the selected language
            LanguageManager.shared.setAppLanguage(selectedLanguageCode)
            
            let alertController = UIAlertController(title: String(format: NSLocalizedString("language.restartInstruction", comment: "")), message: String(format: NSLocalizedString("language.restartMessage", comment: "")), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("language.restart", comment: ""), style: .default, handler: { _ in
                self.restartApplication()
            })
            let cancel = UIAlertAction(title: NSLocalizedString("language.later", comment: ""), style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func englishButton(_ sender: Any) {
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        let languageCode = languageCodes?.first ?? "kor"
        
        if languageCode != "en"{
            let selectedLanguageCode = "en" // Replace with the language code for the selected language
            LanguageManager.shared.setAppLanguage(selectedLanguageCode)
            
            KoreanButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            englishButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            
            let alertController = UIAlertController(title: String(format: NSLocalizedString("language.restartInstruction", comment: "")), message: String(format: NSLocalizedString("language.restartMessage", comment: "")), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("language.restart", comment: ""), style: .default, handler: { _ in
                self.restartApplication()
            })
            let cancel = UIAlertAction(title: NSLocalizedString("language.later", comment: ""), style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func bahasaButton(_ sender: Any) {
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        let languageCode = languageCodes?.first ?? "kor"
        
        KoreanButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        bahasaButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        
        if languageCode != "id"{
            let selectedLanguageCode = "id" // Replace with the language code for the selected language
            LanguageManager.shared.setAppLanguage(selectedLanguageCode)
            
            KoreanButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            englishButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            
            let alertController = UIAlertController(title: String(format: NSLocalizedString("language.restartInstruction", comment: "")), message: String(format: NSLocalizedString("language.restartMessage", comment: "")), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("language.restart", comment: ""), style: .default, handler: { _ in
                self.restartApplication()
            })
            let cancel = UIAlertAction(title: NSLocalizedString("language.later", comment: ""), style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension LanguageViewController {
    private func setupUI() {
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        let languageCode = languageCodes?.first ?? "kor"
        
        switch languageCode {
        case "kor" :
            KoreanButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        case "en":
            KoreanButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            englishButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        case "id":
            KoreanButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            bahasaButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
        default :
            self.KoreanButton.setImage(UIImage(systemName: "circle.inset.filled"), for: .normal)
            self.englishButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
            self.bahasaButton.setImage(UIImage(systemName: "circlebadge"), for: .normal)
        }
    }
    
    private func setupFont() {
        koreaLabel.font = font.subSize
        englishLabel.font = font.subSize
        bahasaLabel.font = font.subSize
    }
    
    private func restartApplication() {
            guard let appDelegate = UIApplication.shared.delegate else {
                return
            }

            if let sceneDelegate = appDelegate.window??.windowScene?.delegate {
                // For iOS 13 and later
                if let sceneSession = sceneDelegate as? UISceneSession {
                    UIApplication.shared.requestSceneSessionDestruction(sceneSession, options: nil, errorHandler: nil)
                }
            } else {
                // For earlier iOS versions
                exit(0)
            }
        }
    
}
