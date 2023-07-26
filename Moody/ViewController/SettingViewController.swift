//
//  SettingViewController.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/27.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import StoreKit
import NVActivityIndicatorView

class SettingViewController: UIViewController, DatePickerDelegate {
    
    
    func passData(controller: DatePickerViewController) {
        time = controller.datePicker.date
        timeClockLabel.text = showTimeFormatter.string(from: time!)
        let string = timeClockLabel.text?.split(separator: ":")
        userdefault.set(Int(String(string![0]))!, forKey: "alarmTime")
        userdefault.set(Int(String(string![1]))!, forKey: "alarmMinute")
        updateNotificationHours(newHour: Int(String(string![0]))!, newMinute: Int(String(string![1]))!)
    }
    
    @IBOutlet weak var appleLabel: UILabel!
    @IBOutlet weak var appleVie: UIView!
    @IBOutlet weak var rateAppView: UIView!
    @IBOutlet weak var googleAuthView: UIView!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var alarmClockView: UIView!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var timeClockLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var appReviewLabel: UILabel!
    @IBOutlet weak var googleLabel: UILabel!
    @IBOutlet weak var lockLabel: UILabel!
    @IBOutlet weak var alarmClockLabel: UILabel!
    @IBOutlet weak var alarmLabel: UILabel!
    @IBOutlet weak var buySubscribeBackground: UIView!
    @IBOutlet weak var buySubscribeLable: UILabel!
    
    let font = Font()
    let fb = Firebase()
    let userdefault = UserDefaults.standard
    let appStoreID = ""
    
    var activityIndicatorView: NVActivityIndicatorView! = nil
    
    var showTimeFormatter : DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var time: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        setupFont()
        setupFunc()
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                // Update the switch based on notification authorization status
                self.alarmSwitch.isOn = settings.authorizationStatus == .authorized
                if self.alarmSwitch.isOn {
                    self.alarmClockView.isHidden = false
                    self.setupTime()
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDatePicker" {
            if let VC = segue.destination as? DatePickerViewController {
                VC.time = time!
                VC.delegate = self
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func alarmSwitch(_ sender: Any) {
        if alarmSwitch.isOn {
            // Check notification authorization status
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .authorized {
                        // Update user defaults with the new hour and minute values
                        self.userdefault.set(22, forKey: "alarmTime")
                        self.userdefault.set(0, forKey: "alarmMinute")
                        
                        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                        self.userdefault.set("true", forKey: "alarmSetting")
                        self.alarmClockView.isHidden = false
                        
                        self.setNotification()
                    } else {
                        // Notifications not allowed, show alert and turn off switch
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(settingsURL)
                        self.alarmSwitch.isOn = false
                    }
                }
            }
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            userdefault.set("false", forKey: "alarmSetting")
            alarmClockView.isHidden = true
            timeClockLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTimePicker)))
        }
    }
    
}

extension SettingViewController {
    private func setupFunc(){
        passwordView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLockSettings)))
        languageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLanguageSettings)))
        googleAuthView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(googleAuth)))
        rateAppView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rateApp)))
        buySubscribeBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSubscription)))
        appleVie.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(appleAuth)))
    }
    
    @objc private func showLanguageSettings() {
        performSegue(withIdentifier: "showLanguageSettings", sender: self)
    }
    
    @objc private func showLockSettings() {
        performSegue(withIdentifier: "showLockSettings", sender: self)
    }
   
    @objc private func showSubscription() {
        performSegue(withIdentifier: "showSubscriptionScreen", sender: self)
    }
    
    @objc private func appleAuth() {
        performSegue(withIdentifier: "showAppleConnect", sender: self)
    }
                                                    
    private func setupTime() {
        let timeString = "22:00"
        time = showTimeFormatter.date(from: timeString)
        timeClockLabel.text = showTimeFormatter.string(from: time!)
        timeClockLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTimePicker)))
    }
    
    private func setupUI(){
        buySubscribeBackground.layer.cornerRadius = 10
        buySubscribeLable.text = "\(String(format: NSLocalizedString("subscription.title", comment: ""))) "
        
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
    
    private func setupFont(){
        buySubscribeLable.font = font.title2Size
        alarmLabel.font = font.subSize
        alarmClockLabel.font = font.subSize
        lockLabel.font = font.subSize
        languageLabel.font = font.subSize
        googleLabel.font = font.subSize
        appReviewLabel.font = font.subSize
        timeClockLabel.font = font.subSize
        appleLabel.font = font.subSize
    }
    
    //MARK NOTIFICATION SETTINGS
    private func setNotification() {
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = String(format: NSLocalizedString("무디", comment: ""))
        content.body = String(format: NSLocalizedString("오늘 하루도 기록해보세요!", comment: ""))
        content.sound = UNNotificationSound.default
        
        // Create date components for 10 PM
        var dateComponents = DateComponents()
        dateComponents.hour = userdefault.integer(forKey: "alarmTime") == 0 ? 22 : userdefault.integer(forKey: "alarmTime")
        dateComponents.minute = userdefault.integer(forKey: "alarmMinute") == 0 ? 00 : userdefault.integer(forKey: "alarmMinute")
        
        // Create trigger for a daily recurring notification at 10 PM
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        // Create the request
        let request = UNNotificationRequest(identifier: "addDiaryNotification", content: content, trigger: trigger)
        
        // Schedule the notification
        UNUserNotificationCenter.current().add(request) { error in
            if let _ = error {
                // Handle error in notification scheduling
            } else {
                // Notification scheduled successfully
            }
        }
    }
    
    func updateNotificationHours(newHour: Int, newMinute: Int) {
        // Get the current list of notification requests
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            // Iterate over the notification requests
            for request in notificationRequests {
                // Check if the request has a trigger of type UNCalendarNotificationTrigger
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    // Delete the current notification request
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["addDiaryNotification"])
                    
                    // Get the date components from the current trigger
                    var dateComponents = trigger.dateComponents
                    
                    // Update the hour component to the new hour value
                    dateComponents.hour = newHour
                    dateComponents.minute = newMinute
                    
                    // Create a new trigger with the updated date components
                    let updatedTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: trigger.repeats)
                    
                    // Create a new notification request with the updated trigger
                    let updatedRequest = UNNotificationRequest(identifier: "addDiaryNotification", content: request.content, trigger: updatedTrigger)
                    
                    // Schedule the updated notification request
                    UNUserNotificationCenter.current().add(updatedRequest) { error in
                        if let _ = error {
                            // Handle error in notification scheduling
//                            print("Error updating notification request: \(error)")
                        } else {
                            // Notification updated successfully
//                            print("Notification updated successfully")
                        }
                    }
                }
            }
        }
    }

    @objc private func showTimePicker() {
        performSegue(withIdentifier: "showDatePicker", sender: self)
    }
    
}

//MARK: GOOGLE SETTINGS
extension SettingViewController {
    private func application(_ app: UIApplication,
                             open url: URL,
                             options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    @objc private func googleAuth() {
        performSegue(withIdentifier: "showConnectGoogle", sender: self)
        
    }
}


//MARK: RATE OUR APP SETTINGS
extension SettingViewController {
    
    @objc private func rateApp() {
        if #available(iOS 10.3, *) {
            activityIndicatorView.startAnimating()
            DispatchQueue.main.async {
                SKStoreReviewController.requestReview()
            }
            activityIndicatorView.stopAnimating()
        } else {
            // Older versions of iOS, you can redirect the user to the App Store manually
            if let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/{\(appStoreID)}") {
                UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
            }
        }
    }
}
