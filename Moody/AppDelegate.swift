//
//  AppDelegate.swift
//  Moody
//
//  Created by Ebbyy on 2023/06/15.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import GoogleMobileAds

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        let languageCodes = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String]
        languageCode = languageCodes?.first ?? "kor"
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

// Handle user's response to the notification (e.g., open a specific view)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle the response based on the actionIdentifier
        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            // The user tapped on the notification to open the app
            // Implement your desired action here
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let diaryDetailVC = storyboard.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController {
                // Customize the code below based on how you handle navigation, such as using a navigation controller
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate,
                   let window = sceneDelegate.window {
                    if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                        window.rootViewController = mainVC
                        window.makeKeyAndVisible()
                        diaryDetailVC.fromNotification()
                    }
                }
            }
        default:
            break
        }
        
        completionHandler()
    }
}
